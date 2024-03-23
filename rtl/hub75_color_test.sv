module hub75_color_test #(
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

    
    logic [segments_p-1:0][addr_width_p-1:0] rd_addr;
    logic [$clog2(hpixel_p)-1:0] col;
    logic [$clog2(vpixel_p)-1:0] line;


    always_ff @(posedge clk) begin
        if (!rst_n) begin
            o_rd_data <= '0;
        end else begin
            o_rd_data <= '0;
        end
    end

    assign col = i_rd_addr[$clog2(hpixel_p)-1:0];
    assign line = i_rd_addr[addr_width_p-1:$clog2(hpixel_p)];

endmodule