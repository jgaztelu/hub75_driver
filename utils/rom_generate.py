from PIL import Image
import os

class rom_generator():
    def __init__(self, name: str, width: int, height: int, segments: int):
        self.name = name
        self.width = width
        self.height = height
        self.segments = segments
        self.data = [(0,0,0) * (width*height) ]
        self.sv = ""
    def from_image(self, path):
        cur_path = os.path.dirname(os.path.realpath(__file__))
        img_path = cur_path + '/' + path
        image = Image.open(img_path)
        if image.mode != 'RGB':
            image = image.convert('RGB')
        if image.size != (self.width, self.height):            
            image = image.resize((self.width, self.height))
        print(image.size)
        # TODO: Save pil to array (getdata)
        self.data = list(image.getdata())[::-1]
        return self

    def gen_sv(self):
        sv_header = f"module {self.name} #("
        parameters = f"""
    parameter hpixel_p = {self.width},
    parameter vpixel_p = {self.height},
    parameter bpp_p = 8,
    parameter segments_p = {self.segments},
    localparam frame_size_p = hpixel_p*vpixel_p,
    localparam addr_width_p = $clog2(frame_size_p)
    ) (\n"""
        ports = """
    // Clock and reset
    input logic clk,
    input logic rst_n,

    /* Pixel read interface */
    input logic [addr_width_p-1:0] i_rd_addr,
    output logic [segments_p-1:0][2:0][bpp_p-1:0] o_rd_data
    );\n\n"""
        constant = f"\tlocalparam [frame_size_p-1:0][3*bpp_p-1:0] {self.name}_buf = {{\n"
        
        hex_values = ["\t\t0x{:02x}{:02x}{:02x},\n".format(r, g, b) for r, g, b in self.data[:-1]]
        hex_values.append("\t\t0x{:02x}{:02x}{:02x}\n\t}};\n".format(*self.data[-1]))
        hex_string = ''.join(hex_values)
        # print(hex_string)
        logic = f"""
    always_ff @(posedge clk) begin
        o_rd_data[0][2] <= {self.name}_buf[i_rd_addr][3*bpp_p-1-:8];
        o_rd_data[0][1] <= {self.name}_buf[i_rd_addr][2*bpp_p-1-:8];
        o_rd_data[0][0] <= {self.name}_buf[i_rd_addr][1*bpp_p-1-:8];

        o_rd_data[1][2] <= {self.name}_buf[i_rd_addr+frame_size_p/2][3*bpp_p-1-:8];
        o_rd_data[1][1] <= {self.name}_buf[i_rd_addr+frame_size_p/2][2*bpp_p-1-:8];
        o_rd_data[1][0] <= {self.name}_buf[i_rd_addr+frame_size_p/2][1*bpp_p-1-:8];
    end\n"""
        endmodule = 'endmodule'
        self.sv = sv_header + parameters + ports + constant + hex_string + logic + endmodule
        # print (sv_header + parameters + ports + constant + hex_string + logic + endmodule)
        return self
    
    def save_rom(self, path):
        cur_path = os.path.dirname(os.path.realpath(__file__))
        rom_path = cur_path + '/' + path
        f = open(rom_path,'w')
        f.write(self.sv)


img_path = 'test_images/bulbasaur_crop_64x64.png'
rom_path = 'test_images/bulbasaur_rom.sv'
width = 64
height = 64

rom = rom_generator('bulbasaur_rom', width, height, 2)

rom.from_image(img_path).gen_sv().save_rom(rom_path)


# img_data = from_image(img_path, width, height)
# Get the pixel values as a flat array
# pixels = list(img_data.getdata())
# print(['#{:02x}{:02x}{:02x}'.format(r, g, b) for r, g, b in pixels])
