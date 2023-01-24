from PIL import Image
import os

img_folder = os.getcwd() + '/utils/test_images/'
rom_folder = os.getcwd() + '/utils/'
print(img_folder)

img_file = 'bulbasaur.webp'
rom_name = 'bulbasaur_rom'
segments = 2 #Display segments (1 or 2)

img_path = img_folder + img_file
rom_path = rom_folder + rom_name + '.sv'

print(f"Opening img_path {img_path}")

im = Image.open(img_path)

crop = im.crop((0,0,63,63))
crop.save((img_folder + 'bulbasaur_crop_64x64.png'))
width, height = crop.size


sv_header = f"module {rom_name} #(\n"
parameters = f"""\tparameter hpixel_p = {width+1},
    parameter vpixel_p = {height+1},
    parameter bpp_p = 8,
    parameter segments_p = {segments},
    localparam frame_size_p = hpixel_p*vpixel_p,
    localparam addr_width_p = $clog2(frame_size_p)
    ) (\n\n"""

ports = """// Clock and reset
        input logic clk,
        input logic rst_n,

        /* Pixel read interface */
        input logic [addr_width_p-1:0] i_rd_addr,
        output logic [segments_p-1:0][2:0][bpp_p-1:0] o_rd_data
        );\n\n"""

constant = f"localparam [frame_size_p-1:0][3*bpp_p-1:0] {rom_name}_buf = {{\n"
print(constant)
for v in range(height):
    for h in range(width):
        pix = crop.getpixel((h,v))
        pix_num = pix[0]*2**16 + pix[1] * 2**8 + pix[2]
        constant = constant + f"24'd{pix_num},\n"

constant = constant[0:len(constant)-2] # Remove last comma
constant += '};\n'

logic = f"""
    always_ff @(posedge clk) begin
        o_rd_data[0][2] <= bulbasaur_rom_buf[i_rd_addr][3*bpp_p-1-:8];
        o_rd_data[0][1] <= bulbasaur_rom_buf[i_rd_addr][2*bpp_p-1-:8];
        o_rd_data[0][0] <= bulbasaur_rom_buf[i_rd_addr][1*bpp_p-1-:8];

        o_rd_data[1][2] <= bulbasaur_rom_buf[i_rd_addr+frame_size_p/2][3*bpp_p-1-:8];
        o_rd_data[1][1] <= bulbasaur_rom_buf[i_rd_addr+frame_size_p/2][2*bpp_p-1-:8];
        o_rd_data[1][0] <= bulbasaur_rom_buf[i_rd_addr+frame_size_p/2][1*bpp_p-1-:8];
    end\n"""

endmodule = 'endmodule'

print(f"Writing to {rom_path}.sv")

f = open(rom_path,"w")
f.write(sv_header)
f.write(parameters)
f.write(ports)
f.write(constant)
f.write(logic)
f.write(endmodule)


