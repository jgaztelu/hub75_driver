module test_corners #(
    parameter hpixel_p = 64,
    parameter vpixel_p = 64,
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

    always_ff @(posedge clk) begin
		if (i_rd_addr == 0) begin // Top left
			o_rd_data[0][2] <= '1;
			o_rd_data[0][1] <= '1;
			o_rd_data[0][0] <= '1;
			o_rd_data[1][2] <= '1;
			o_rd_data[1][1] <= '1;
			o_rd_data[1][0] <= '1;
		end else if (i_rd_addr == hpixel_p-1) begin	// Top right
			o_rd_data[0][2] <= '1;
			o_rd_data[0][1] <= '0;
			o_rd_data[0][0] <= '0;
			o_rd_data[1][2] <= '1;
			o_rd_data[1][1] <= '0;
			o_rd_data[1][0] <= '0;
		end else if (i_rd_addr == (hpixel_p*vpixel_p-1)) begin	// Low left
			o_rd_data[0][2] <= '0;
			o_rd_data[0][1] <= '1;
			o_rd_data[0][0] <= '0;
			o_rd_data[1][2] <= '0;
			o_rd_data[1][1] <= '1;
			o_rd_data[1][0] <= '0;
		end else if (i_rd_addr == (hpixel_p*vpixel_p-1)) begin // Low right
			o_rd_data[0][2] <= '0;
			o_rd_data[0][1] <= '0;
			o_rd_data[0][0] <= '1;
			o_rd_data[1][2] <= '0;
			o_rd_data[1][1] <= '0;
			o_rd_data[1][0] <= '1;
		end else begin
			o_rd_data <= '0;
		end
			
    end
endmodule