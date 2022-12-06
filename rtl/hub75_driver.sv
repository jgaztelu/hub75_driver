module hub75_driver #(
    parameter  hpixel_p     = 64,                   // Display width in pixels
    parameter  vpixel_p     = 64,                   // Display height in pixels
    parameter  bpp_p        = 8,                    // Bits per pixel color channel
    localparam frame_size_p = 64 * 64,
    localparam addr_width_p = $clog2(frame_size_p)
) (
    // Clock and reset
    input logic clk,
    input logic rst_n,

    /* Frame buffer write interface */
    input logic [addr_width_p-1:0] i_framebuf_wr_addr,  // Framebuf write address
    input logic [     3*bpp_p-1:0] i_framebuf_wr_data,  // Pixel data packed as {R,G,B}
    input logic                    i_framebuf_wr_en,    // Write enable

    /* HUB75 outputs */
    // Control signals
    output logic O_CLK,
    output logic STB,
    output logic OE,

    // Row select
    output logic A,
    output logic B,
    output logic C,
    output logic D,

    // RGB outputs
    output logic R1,
    output logic R2,
    output logic G1,
    output logic G2,
    output logic B1,
    output logic B2
);

  hub75_framebuf #(
      .hpixel_p(64),
      .vpixel_p(64),
      .bpp_p   (8)
  ) hub75_framebuf_i (
      .clk(clk),
      .rst_n(rst_n),
      /* Write interface */
      .i_wr_addr(i_framebuf_wr_addr),
      .i_wr_data(i_framebuf_wr_data),
      .i_wr_en(i_framebuf_wr_en),

      /* Pixel read interface */
      .i_rd_addr('0),
      .o_rd_data()
  );

endmodule
