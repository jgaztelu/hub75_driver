module hub75_display #(
    parameter hpixel_p = 64,    // Display width in pixels
    parameter vpixel_p = 64,    // Display height in pixels
    parameter    bpp_p = 8,     // Bits per pixel color channel
    localparam frame_size_p = 64*64,
    localparam addr_width_p = $clog2(frame_size_p)
) (
    // Clock and reset
    input logic clk,
    input logic rst_n,

    /* Pixel read interface */
    output logic [addr_width_p-1:0] o_rd_addr,
    input logic [2:0][bpp_p-1:0] i_rd_data,

    /* HUB75 output interface */
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

logic [$clog2(vpixel_p)-1:0] row_sel;
logic                        clk_hub75;
logic                        out_en;
logic                        out_stb;

typedef enum {IDLE, COLOR_TX, LATCH, WAIT} hub75_display_state_t;

hub75_display_state_t disp_state;

always_ff @(posedge clk) begin
    if (!rst_n) begin
        disp_state <= IDLE;
        clk_hub75 <= 0;
        row_sel <= '0;
        out_en <= 0;
        out_stb <= 0;
    end else begin
        case (disp_state)
            IDLE: begin
                clk_hub75 <= 0;
                row_sel <= '0;
                out_en <= 0;
                out_stb <= 0;
            end

            COLOR_TX: begin
            end

            LATCH: begin
            end

            WAIT: begin
            end
        endcase
    end
end


endmodule