
module hub75_test_bars #(
    parameter hpixel_p = 64,    // Display width in pixels
    parameter vpixel_p = 64,    // Display height in pixels
    parameter    bpp_p = 8,     // Bits per pixel color channel
    parameter segments_p = 2,   // Number of display segments
    localparam frame_size_p = hpixel_p*vpixel_p,
    localparam addr_width_p = $clog2(frame_size_p),
    localparam bar_size_p = hpixel_p/8 // 8 Test bars
) (
    // Clock and reset
    input logic clk,
    input logic rst_n,

    /* Write interface */
    input logic [addr_width_p-1:0] i_wr_addr,
    input logic [     3*bpp_p-1:0] i_wr_data,
    input logic                    i_wr_en,

    /* Pixel read interface */
    input logic [addr_width_p-1:0] i_rd_addr,
    output logic [segments_p-1:0][2:0][bpp_p-1:0] o_rd_data
);

  logic [31:0] cur_bar;
  generate
    for (genvar i = 0; i < segments_p; i++) begin
      always_ff @(posedge clk) begin
        if (!rst_n) begin
          o_rd_data[i] <= '0;
        end else begin
          case  (cur_bar[2:0])
            // RGB Values
            0: o_rd_data[i] <= {{bpp_p{1'b1}}, {bpp_p{1'b1}}, {bpp_p{1'b1}}}; // White
            1: o_rd_data[i] <= {{bpp_p{1'b1}}, {bpp_p{1'b1}}, {bpp_p{1'b0}}}; // Yellow
            2: o_rd_data[i] <= {{bpp_p{1'b0}}, {bpp_p{1'b1}}, {bpp_p{1'b1}}}; // Cyan
            3: o_rd_data[i] <= {{bpp_p{1'b0}}, {bpp_p{1'b1}}, {bpp_p{1'b0}}}; // Green
            4: o_rd_data[i] <= {{bpp_p{1'b1}}, {bpp_p{1'b0}}, {bpp_p{1'b1}}}; // Magenta
            5: o_rd_data[i] <= {{bpp_p{1'b1}}, {bpp_p{1'b0}}, {bpp_p{1'b0}}}; // Red
            6: o_rd_data[i] <= {{bpp_p{1'b0}}, {bpp_p{1'b0}}, {bpp_p{1'b1}}}; // Blue
            7: o_rd_data[i] <= {{bpp_p{1'b0}}, {bpp_p{1'b0}}, {bpp_p{1'b0}}}; // Black
          endcase
        end
      end
    end
  endgenerate

  assign cur_bar = ((i_rd_addr % hpixel_p) / bar_size_p);  // Get column for current read pixel
endmodule
