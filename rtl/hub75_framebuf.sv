module hub75_framebuf #(
    parameter hpixel_p = 64,    // Display width in pixels
    parameter vpixel_p = 64,    // Display height in pixels
    parameter    bpp_p = 8,     // Bits per pixel color channel
    parameter segments_p = 2,   // Number of display segments
    localparam frame_size_p = 64*64,
    localparam addr_width_p = $clog2(frame_size_p)
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

  logic [frame_size_p-1:0][3*bpp_p-1:0] frame_buf;

  always_ff @(posedge clk) begin
    if (i_wr_en) frame_buf[i_wr_addr] <= i_wr_data;

    o_rd_data <= frame_buf[i_rd_addr];
  end


endmodule
