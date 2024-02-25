module hub75_control #(
    parameter  hpixel_p     = 64,                   // Display width in pixels
    parameter  vpixel_p     = 64,                   // Display height in pixels
    parameter  bpp_p        = 8,                    // Bits per pixel color channel
    parameter  segments_p = 2,   // Number of display segments
    localparam frame_size_p = hpixel_p * vpixel_p,
    localparam addr_width_p = $clog2(frame_size_p),
    localparam pix_bit_width_p = $clog2(bpp_p)
    ) (
    input logic clk,
    input logic rst_n,
    // Config. inputs
    input logic [3:0]               i_clk_div,
    // Control interface
    output logic                     o_tx_start,
    output logic [addr_width_p-1:0]  o_init_addr,
    output logic [pix_bit_width_p-1:0] o_pix_bit,
    input logic                     i_tx_ready,
    // Output interface
    output logic                    o_out_en_n        // Output enable for display
);

localparam int min_wait = 4;

typedef enum {IDLE,FIRST,TX,WAIT} hub75_control_state_t;
hub75_control_state_t control_state;

// logic [$clog2(hpixel_p)-1:0] col_cnt;
logic [$clog2(vpixel_p)-1:0] row_cnt;
logic [pix_bit_width_p-1:0]  bit_cnt;

logic                                wait_ready;
logic [$clog2(min_wait-1)+bpp_p-1:0] wait_cnt;

always_ff @(posedge clk) begin
    if (!rst_n) begin
        o_tx_start <= 0;
        o_init_addr <= '0;
        o_out_en_n <= 1;
        row_cnt <= '0;
        bit_cnt <= '0;
        control_state <= IDLE;
    end else begin
        o_tx_start <= 0;
        case (control_state)
            IDLE: begin
                if (i_tx_ready) begin
                    o_tx_start <= 1;
                    control_state <= TX;
                end
            end

            TX: begin 
                if (i_tx_ready) begin
                    if (bit_cnt == bpp_p-1) begin
                        if (row_cnt == vpixel_p-1) begin
                            bit_cnt <= '0;
                            row_cnt <= '0;
                            control_state <= IDLE;
                        end else begin
                            bit_cnt <= '0;
                            row_cnt <= row_cnt + 1;
                        end
                    end else begin
                        bit_cnt <= bit_cnt + 1;
                    end
                    o_tx_start <= 1;
                    wait_cnt <= min_wait << bit_cnt;
                    control_state <= WAIT;
                end
            end            

            WAIT: begin
                if (wait_cnt == 0) begin
                    control_state <= TX;
                end else begin
                    wait_cnt <= wait_cnt - 1;
                end
            end
        endcase
    end
end

    assign o_pix_bit = bit_cnt;

endmodule