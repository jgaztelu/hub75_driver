from PIL import Image
import os
import numpy as np
import math

class rom_generator():
    def __init__(self, name: str, width: int, height: int, segments: int):
        self.name = name
        self.width = width
        self.height = height
        self.size = width*height
        self.addr_wd = math.ceil(math.log2(self.size))
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
        self.data = list(image.getdata())
        return self
    
    def test_bars(self):
        test_colors = [(255,255,255),(255,255,0),(0,255,255),(0,255,0),(255,0,255),(255,0,0),(0,0,255),(0,0,0)]
        bar_len = int(self.width/8)
        test_line = [pix for pix in test_colors for i in range(bar_len)]
        print(test_line)
        self.data = (test_line*self.height)
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
        
        self.hex_values = ["\t\t24'h{:02x}{:02x}{:02x},\n".format(r, g, b) for r, g, b in self.data[:-1]]
        self.hex_values.append("\t\t24'h{:02x}{:02x}{:02x}\n\t}};\n".format(*self.data[-1]))
        hex_string = ''.join(self.hex_values)
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
    
    def gen_sv2(self):
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
        signal = """logic [3*bpp-1:0] rd_data_0;\n
                    logic [3*bpp-1:0] rd_data_0;\n"""
        # constant = f"\tlocalparam [frame_size_p-1:0][3*bpp_p-1:0] {self.name}_buf = {{\n"
        
        self.hex_values = ["24'h{:02x}{:02x}{:02x}".format(r, g, b) for r, g, b in self.data]
        # self.hex_values.append("24'h{:02x}{:02x}{:02x}}}".format(*self.data[-1]))
        cases_0 = []
        cases_1 = []
        for i in range(int(self.size/2)):
            cases_0.append(f"\t\t{self.addr_wd}'d{i:04}: rd_data_0 <= {self.hex_values[i]};\n")
            cases_1.append(f"\t\t{self.addr_wd}'d{i:04}: rd_data_1 <= {self.hex_values[i+(int(self.size/2))]};\n")
        # print(cases_0)
        case0_string = ''.join(cases_0)
        case1_string = ''.join(cases_1)

        print(cases_0)

        logic = f"""
    always_ff @(posedge clk) begin
        case (i_rd_addr)
{case0_string}
        endcase

        case (i_rd_addr)
{case1_string}
        endcase
    end    
        assign o_rd_data[0][2] <= rd_data_0[3*bpp_p-1-:8];
        assign o_rd_data[0][1] <= rd_data_0[2*bpp_p-1-:8];
        assign o_rd_data[0][0] <= rd_data_0[bpp_p-1-:8];

        assign o_rd_data[1][2] <= rd_data_1[3*bpp_p-1-:8];
        assign o_rd_data[1][1] <= rd_data_1[2*bpp_p-1-:8];
        assign o_rd_data[1][0] <= rd_data_1[bpp_p-1-:8];
"""
        endmodule = 'endmodule'
        self.sv = sv_header + parameters + ports + logic + endmodule
        # print (sv_header + parameters + ports + constant + hex_string + logic + endmodule)
        return self
    
    def save_rom(self, path):
        cur_path = os.path.dirname(os.path.realpath(__file__))
        rom_path = cur_path + '/' + path
        f = open(rom_path,'w')
        f.write(self.sv)
        return self

    def recover_image(self, path = ''):
        cur_path = os.path.dirname(os.path.realpath(__file__))
        img_path = cur_path + '/' + path    
        # From string to list of hex values
        recover = [x.split("24'h",1)[1].rstrip(",\n\t};") for x in self.hex_values] # Cleanup the string for each RGB value
        recover = [[(s[i:i+2]) for i in range(0,len(s),2)] for s in recover]        # Split RGB string into R,G,B lists
        recover = [[int(val,16) for val in pix] for pix in recover]                 # Convert hex to int
        recover = np.array(recover, dtype=np.uint8)
        print(recover.shape)
        recover = recover.reshape((64,64,3))
        # print(recover)
        print(recover.shape)
        im = Image.fromarray(recover,mode='RGB')
        im.save(img_path)


img_path = 'test_images/bulbasaur_crop_64x64.png'
rom_path = 'test_images/testbars_rom_new.sv'
rec_path = 'test_images/testbars_recover_64x64.png'
width = 64
height = 64

rom = rom_generator('test_bars_rom_new', width, height, 2)

# rom.from_image(img_path).gen_sv().save_rom(rom_path).recover_image(rec_path)
rom.test_bars().gen_sv2().save_rom(rom_path)



# img_data = from_image(img_path, width, height)
# Get the pixel values as a flat array
# pixels = list(img_data.getdata())
# print(['#{:02x}{:02x}{:02x}'.format(r, g, b) for r, g, b in pixels])
