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
    output logic                        o_tx_start,
    output logic                        o_timer_en,
    output logic [addr_width_p-1:0]     o_init_addr,
    output logic [pix_bit_width_p-1:0]  o_pix_bit,
    input logic                         i_tx_ready,
    input logic                         i_blanking

);

localparam int min_wait = 4;
localparam out_rows_p = vpixel_p/segments_p;


typedef enum {IDLE,FIRST_TX,TX,WAIT} hub75_control_state_t;
hub75_control_state_t control_state;

logic [$clog2(vpixel_p)-1:0] row_cnt;
logic [pix_bit_width_p-1:0]  bit_cnt;
logic blanking_d, blanking_pos, blanking_neg;
logic overflow, underflow;

logic started;
logic new_row;
logic new_frame;

// Under/over flow detection
logic tx_ready_d, tx_ready_pos;
logic [1:0] lines_in_buffer;

always_ff @(posedge clk) begin
    if (!rst_n) begin
        o_tx_start <= 0;
        o_init_addr <= '0;
        o_timer_en <= 0;
        row_cnt <= '0;
        bit_cnt <= '0;
        blanking_d <= 0;
        control_state <= IDLE;
        started <= 0;
        new_frame <= 0;
        new_row <= 0;
    end else begin
        o_tx_start <= 0;
        new_frame <= 0;
        new_row <= 0;
        blanking_d <= i_blanking;
        case (control_state)
            IDLE: begin
                o_timer_en <= 0;
                if (i_tx_ready) begin // Preload first row
                    started <= 1;
                    o_tx_start <= 1;
                    control_state <= FIRST_TX;
                end
            end

            FIRST_TX: begin // Wait until first TX is in progress
                if (!i_tx_ready) begin
                    bit_cnt <= bit_cnt + 1;
                    control_state <= TX;
                end
            end

            TX: begin 
                if (i_tx_ready) begin
                    o_timer_en <= 1;
                    if (bit_cnt == bpp_p-1) begin
                        new_row <= 1;
                        if (row_cnt == out_rows_p-1) begin
                            bit_cnt <= '0;
                            row_cnt <= '0;
                            new_frame <= 1;
                            control_state <= IDLE;
                        end else begin
                            bit_cnt <= '0;
                            row_cnt <= row_cnt + 1;
                        end
                    end else begin
                        bit_cnt <= bit_cnt + 1;
                    end
                    o_tx_start <= 1;
                    control_state <= WAIT;
                end
            end            

            WAIT: begin
                if (blanking_pos) begin
                    control_state <= TX;
                end
            end
        endcase
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tx_ready_d <= 0;
        lines_in_buffer <= '0;
    end else begin
        tx_ready_d <= i_tx_ready;
        if (started) begin
            // We can have up to 2 lines in buffer (sreg + latch). Limit counter to avoid under/overflow
            if (lines_in_buffer == 0 && blanking_neg) begin
                lines_in_buffer <= '0;
            end else if (lines_in_buffer == 2'b11 && tx_ready_pos) begin
                lines_in_buffer <= '1;
            end else begin
                lines_in_buffer <= lines_in_buffer + tx_ready_pos - blanking_neg;
            end
        end
    end    
end
    assign o_pix_bit = bit_cnt;
    assign blanking_pos = (~blanking_d) & i_blanking;
    assign blanking_neg = blanking_d & (~i_blanking);
    assign tx_ready_pos = ~tx_ready_d & i_tx_ready;
    assign underflow = (lines_in_buffer == 0) && blanking_neg;
    assign overflow = lines_in_buffer > 2;


endmodule