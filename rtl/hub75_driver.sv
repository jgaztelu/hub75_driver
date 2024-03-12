module hub75_driver #(
    parameter  hpixel_p     = 64,                   // Display width in pixels
    parameter  vpixel_p     = 64,                   // Display height in pixels
    parameter  bpp_p        = 8,                    // Bits per pixel color channel
    parameter segments_p = 2,   // Number of display segments
    parameter clk_div_wd_p = 8, // Maximum width for clock divider
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

	localparam int clk_divider = 8;
	localparam int blanking = clk_divider*2;
	localparam int base_wait = clk_divider*16;
  (* mark_debug = "true" *) logic [addr_width_p-1:0] framebuf_rd_addr;
  (* mark_debug = "true" *) logic [segments_p-1:0][2:0][bpp_p-1:0] framebuf_rd_data;
  logic [segments_p-1:0][2:0][bpp_p-1:0] gamma_rd_data;

	logic tx_start;
	logic tx_ready;
	logic [$clog2(bpp_p)-1:0] pix_bit;
	logic [addr_width_p-1:0] init_addr;
	logic out_en;
	logic timer_en;
  


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

  //   hub75_test_bars #(
  //     .hpixel_p(hpixel_p),
  //     .vpixel_p(vpixel_p),
  //     .bpp_p   (bpp_p),
  //     .segments_p(segments_p)
  //   ) hub75_test_bars_i (
  //     .clk(clk),
  //     .rst_n(rst_n),
  //     /* Write interface */
  //     .i_wr_addr(i_framebuf_wr_addr),
  //     .i_wr_data(i_framebuf_wr_data),
  //     .i_wr_en(i_framebuf_wr_en),

  //     /* Pixel read interface */
  //     .i_rd_addr(framebuf_rd_addr),
  //     .o_rd_data(framebuf_rd_data)
  // );

      // bulbasaur_rom #(
      // .hpixel_p(hpixel_p),
      // .vpixel_p(vpixel_p),
      // .bpp_p   (bpp_p),
      // .segments_p(segments_p)
    // ) bulbasaur_rom_i (
      // .clk(clk),
      // .rst_n(rst_n),

      // /* Pixel read interface */
      // .i_rd_addr(framebuf_rd_addr),
      // .o_rd_data(framebuf_rd_data)
  // );

  //   test_corners #(
  //     .hpixel_p(hpixel_p),
  //     .vpixel_p(vpixel_p),
  //     .bpp_p   (bpp_p),
  //     .segments_p(segments_p)
  //   ) test_corners_i (
  //     .clk(clk),
  //     .rst_n(rst_n),

  //     /* Pixel read interface */
  //     .i_rd_addr(framebuf_rd_addr),
  //     .o_rd_data(framebuf_rd_data)
  // );
  
	test_bars_rom #(
      .hpixel_p(hpixel_p),
      .vpixel_p(vpixel_p),
      .bpp_p   (bpp_p),
      .segments_p(segments_p)
    ) test_bars_rom_i (
      .clk(clk),
      .rst_n(rst_n),

      /* Pixel read interface */
      .i_rd_addr(framebuf_rd_addr),
      .o_rd_data(framebuf_rd_data)
  );

  // Instantiate gamma correction for R,G,B
  generate;
    for (genvar i=0; i<segments_p; i++) begin
      gamma_corr #(
        .pixel_width_p(bpp_p)
      ) gamma_corr_r (
        .clk(clk),
        .pixel_in(framebuf_rd_data[i][2]),
        .pixel_out(gamma_rd_data[i][2])
      );

      gamma_corr #(
        .pixel_width_p(bpp_p)
      ) gamma_corr_g (
        .clk(clk),
        .pixel_in(framebuf_rd_data[i][1]),
        .pixel_out(gamma_rd_data[i][1])
      );

      gamma_corr #(
        .pixel_width_p(bpp_p)
      ) gamma_corr_b (
        .clk(clk),
        .pixel_in(framebuf_rd_data[i][0]),
        .pixel_out(gamma_rd_data[i][0])
      );    
    end
  endgenerate
  

  // hub75_display #(
  //     .hpixel_p(hpixel_p),
  //     .vpixel_p(vpixel_p),
  //     .bpp_p   (bpp_p),
  //     .segments_p(segments_p)

  // ) hub75_display_i (
  //     .clk(clk),
  //     .rst_n(rst_n),

  //     //Config inputs
  //     .i_enable(i_enable),
  //     .i_clk_div(4'd10),
  //     /* Pixel read interface */
  //     .o_rd_addr(/*framebuf_rd_addr*/),
  //     .i_rd_data(/*framebuf_rd_data*/),

  //     /* HUB75 output interface */
  //     // Control signals
  //     .O_CLK(O_CLK),
  //     .STB(STB),
  //     .OE(OE),

  //     // Row select
  //     .A(A),
  //     .B(B),
  //     .C(C),
  //     .D(D),
  //     .E(E),

  //     // RGB outputs
  //     .R1(R1),
  //     .R2(R2),
  //     .G1(G1),
  //     .G2(G2),
  //     .B1(B1),
  //     .B2(B2)
  // );

  hub75_color_tx #(
    .hpixel_p(hpixel_p),
    .vpixel_p(vpixel_p),
    .bpp_p   (bpp_p),
    .segments_p(segments_p)
  ) hub75_color_tx_i (
    .clk(clk),
    .rst_n(rst_n),
    .i_clk_div(clk_divider),
    .i_tx_start(tx_start),
    .i_init_addr(init_addr),
    .i_pix_bit(pix_bit),
    .o_ready(tx_ready),
    .o_rd_addr(framebuf_rd_addr),
    .i_rd_data(framebuf_rd_data),
    .o_serial_clk(O_CLK),
    .o_red({R2,R1}),
    .o_green({G2,G1}),
    .o_blue({B2,B1}),
    .o_latch_en(STB)
  );

  hub75_control #(
    .hpixel_p(hpixel_p),
    .vpixel_p(vpixel_p),
    .bpp_p   (bpp_p),
    .segments_p(segments_p)
  ) hub75_control_i (
    .clk(clk),
    .rst_n(rst_n),
    .i_clk_div(clk_divider),
    .o_tx_start(tx_start),
    .o_timer_en(timer_en),
    .o_init_addr(init_addr),
    .o_pix_bit(pix_bit),
    .i_tx_ready(tx_ready),
    .i_blanking(out_en)
  );


  hub75_timer #(
    .bpp_p(bpp_p)
  ) hub75_timer_i (
    .clk(clk),
    .rst_n(rst_n),
    .i_timer_en(timer_en),
    .i_base_wait(base_wait),
    .i_blank_interval(blanking),
    .i_pix_bit(pix_bit),
    .o_out_en_n(out_en),
    .o_row_sel({A,B,C,D,E})
  );
  

  assign OE = out_en;
endmodule
