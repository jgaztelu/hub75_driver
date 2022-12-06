module  #(
    parameter hpixel_p = 64,    // Display width in pixels
    parameter vpixel_p = 64,    // Display height in pixels
    parameter    bpp_p = 8;     // Bits per pixel color channel
) hub75_framebuf (
    // Clock and reset
    input logic clk,
    input logic rst_n,

    /* Write interface */
    input logic             i_wr_en,
    input logic [3*bpp-1:0] i_wr_data,

    /* Pixel read interface */
    input logic                 i_rd_en,
    output logic [2:0][bpp-1:0] o_rd_data
);

endmodule