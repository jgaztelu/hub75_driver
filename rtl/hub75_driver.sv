module  #(
    parameter hpixel_p = 64,    // Display width in pixels
    parameter vpixel_p = 64,    // Display height in pixels
    parameter  = bpp_p = 8;     // Bits per pixel color channel
) hub75_driver (
    // Clock and reset
    input logic clk,
    input logic rst_n,

    /* Frame buffer write interface */
    input logic [3*bpp_p-1:0] framebuf_wr_data, // Pixel data packed as {R,G,B}
    input logic               framebuf_wr_en,   // Write enable

    /* HUB75 outputs */
    // Control signals
    output logic CLK,
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
    
endmodule