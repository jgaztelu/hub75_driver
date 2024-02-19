from PIL import Image
import os

class rom_generateor():
    def __init__(self, name: str, width: int, height: int, segments: int):
        self.name = name
        self.width = width
        self.height = height
        self.segments = segments
        self.data = [(0,0,0) * (width*height) ]

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
        sv_header = f"module {self.name} #(\n"
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
        
        hex_values = ["0x{:02x}{:02x}{:02x},\n".format(r, g, b) for r, g, b in self.data[:-1]]
        hex_values.append("0x{:02x}{:02x}{:02x}\n}};\n".format(*self.data[-1]))
        hex_string = ''.join(hex_values)
        print(hex_string)
        

        print (sv_header + parameters + ports + constant)
    


img_path = 'test_images/bulbasaur_crop_64x64.png'
width = 64
height = 64

rom = rom_generateor('bulbasaur_rom', width, height, 2)

rom.from_image(img_path).gen_sv()


# img_data = from_image(img_path, width, height)
# Get the pixel values as a flat array
# pixels = list(img_data.getdata())
# print(['#{:02x}{:02x}{:02x}'.format(r, g, b) for r, g, b in pixels])
