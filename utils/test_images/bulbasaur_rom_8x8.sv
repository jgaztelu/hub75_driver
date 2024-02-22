module bulbasaur_rom #(
    parameter hpixel_p = 8,
    parameter vpixel_p = 8,
    parameter bpp_p = 8,
    parameter segments_p = 2,
    localparam frame_size_p = hpixel_p*vpixel_p,
    localparam addr_width_p = $clog2(frame_size_p)
    ) (

    // Clock and reset
    input logic clk,
    input logic rst_n,

    /* Pixel read interface */
    input logic [addr_width_p-1:0] i_rd_addr,
    output logic [segments_p-1:0][2:0][bpp_p-1:0] o_rd_data
    );

	localparam [frame_size_p-1:0][3*bpp_p-1:0] bulbasaur_rom_buf = {
		24'h7f007f,
		24'h7f007f,
		24'h810080,
		24'h82007f,
		24'h810080,
		24'h810081,
		24'h7f007f,
		24'h7f007f,
		24'h7f007f,
		24'h7f007e,
		24'h780578,
		24'h731879,
		24'h6e177b,
		24'h7b0c7c,
		24'h800080,
		24'h7f007f,
		24'h80007e,
		24'h760679,
		24'h3d5a70,
		24'h3b7e7f,
		24'h456c6c,
		24'h654079,
		24'h7f007e,
		24'h7f007f,
		24'h800080,
		24'h730b73,
		24'h367361,
		24'h478683,
		24'h77948e,
		24'h6d9996,
		24'h77117c,
		24'h800080,
		24'h820082,
		24'h700c70,
		24'h4c8f57,
		24'h64b389,
		24'h6ec2ad,
		24'h70aeaa,
		24'h7a0d7d,
		24'h80007e,
		24'h800080,
		24'h7f007f,
		24'h653f66,
		24'h707077,
		24'h763382,
		24'h761381,
		24'h7e0280,
		24'h7f007f,
		24'h7f007f,
		24'h7f007f,
		24'h7f007e,
		24'h7e007d,
		24'h80007f,
		24'h7f007f,
		24'h7e007f,
		24'h80007e,
		24'h7f007f,
		24'h7f007f,
		24'h7f007f,
		24'h7f007f,
		24'h7f007f,
		24'h7f007f,
		24'h80007e,
		24'h810080
	};

    always_ff @(posedge clk) begin
        o_rd_data[0][2] <= bulbasaur_rom_buf[i_rd_addr][3*bpp_p-1-:8];
        o_rd_data[0][1] <= bulbasaur_rom_buf[i_rd_addr][2*bpp_p-1-:8];
        o_rd_data[0][0] <= bulbasaur_rom_buf[i_rd_addr][1*bpp_p-1-:8];

        o_rd_data[1][2] <= bulbasaur_rom_buf[i_rd_addr+frame_size_p/2][3*bpp_p-1-:8];
        o_rd_data[1][1] <= bulbasaur_rom_buf[i_rd_addr+frame_size_p/2][2*bpp_p-1-:8];
        o_rd_data[1][0] <= bulbasaur_rom_buf[i_rd_addr+frame_size_p/2][1*bpp_p-1-:8];
    end
endmodule