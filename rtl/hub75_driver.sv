module hub75_driver #(
    parameter  hpixel_p     = 64,                   // Display width in pixels
    parameter  vpixel_p     = 64,                   // Display height in pixels
    parameter  bpp_p        = 8,                    // Bits per pixel color channel
    parameter segments_p = 2,   // Number of display segments
    localparam frame_size_p = hpixel_p * vpixel_p,
    localparam addr_width_p = $clog2(frame_size_p)
) (
    // Clock and reset
    input logic clk,
    input logic rst_n,

    input logic i_enable,
    input logic [3:0] i_clk_div,
    
    /* Frame buffer write interface */
    input logic [addr_width_p-1:0] i_framebuf_wr_addr,  // Framebuf write address
    input logic [     3*bpp_p-1:0] i_framebuf_wr_data,  // Pixel data packed as {R,G,B}
    input logic                    i_framebuf_wr_en,    // Write enable

    /* HUB75 outputs */
    // Control signals
    (* mark_debug = "true" *) output logic O_CLK,
    output logic STB,
    output logic OE,

    // Row select
    output logic A,
    output logic B,
    output logic C,
    output logic D,
    output logic E,

    // RGB outputs
    output logic R1,
    output logic R2,
    output logic G1,
    output logic G2,
    output logic B1,
    output logic B2
);

  (* mark_debug = "true" *) logic [addr_width_p-1:0] framebuf_rd_addr;
  (* mark_debug = "true" *) logic [segments_p-1:0][2:0][bpp_p-1:0] framebuf_rd_data;

//   hub75_framebuf #(
//       .hpixel_p(hpixel_p),
//       .vpixel_p(vpixel_p),
//       .bpp_p   (bpp_p),
//       .segments_p(segments_p)
//   ) hub75_framebuf_i (
//       .clk(clk),
//       .rst_n(rst_n),
//       /* Write interface */
//       .i_wr_addr(i_framebuf_wr_addr),
//       .i_wr_data(i_framebuf_wr_data),
//       .i_wr_en(i_framebuf_wr_en),

//       /* Pixel read interface */
//       .i_rd_addr(framebuf_rd_addr),
//       .o_rd_data(framebuf_rd_data)
//   );

//     hub75_test_bars #(
//       .hpixel_p(hpixel_p),
//       .vpixel_p(vpixel_p),
//       .bpp_p   (bpp_p),
//       .segments_p(segments_p)
//     ) hub75_test_bars_i (
//       .clk(clk),
//       .rst_n(rst_n),
//       /* Write interface */
//       .i_wr_addr(i_framebuf_wr_addr),
//       .i_wr_data(i_framebuf_wr_data),
//       .i_wr_en(i_framebuf_wr_en),

//       /* Pixel read interface */
//       .i_rd_addr(framebuf_rd_addr),
//       .o_rd_data(framebuf_rd_data)
//   );

      bulbasaur_rom #(
      .hpixel_p(hpixel_p),
      .vpixel_p(vpixel_p),
      .bpp_p   (bpp_p),
      .segments_p(segments_p)
    ) bulbasaur_rom_i (
      .clk(clk),
      .rst_n(rst_n),

      /* Pixel read interface */
      .i_rd_addr(framebuf_rd_addr),
      .o_rd_data(framebuf_rd_data)
  );

  hub75_display #(
      .hpixel_p(hpixel_p),
      .vpixel_p(vpixel_p),
      .bpp_p   (bpp_p),
      .segments_p(segments_p)

  ) hub75_display_i (
      .clk(clk),
      .rst_n(rst_n),

      //Config inputs
      .i_enable(i_enable),
      .i_clk_div(4'd10),
      /* Pixel read interface */
      .o_rd_addr(framebuf_rd_addr),
      .i_rd_data(framebuf_rd_data),

      /* HUB75 output interface */
      // Control signals
      .O_CLK(O_CLK),
      .STB(STB),
      .OE(OE),

      // Row select
      .A(A),
      .B(B),
      .C(C),
      .D(D),
      .E(E),

      // RGB outputs
      .R1(R1),
      .R2(R2),
      .G1(G1),
      .G2(G2),
      .B1(B1),
      .B2(B2)

  );

endmodule
