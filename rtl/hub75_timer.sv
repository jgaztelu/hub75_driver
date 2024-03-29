module hub75_timer #(
    parameter int vpixel_p = 64,
    parameter int bpp_p = 8,
    parameter int segments_p = 2,
    parameter int base_wait_wd_p = 12,
    localparam int cnt_wd_p = base_wait_wd_p + bpp_p
) (
    input logic clk,
    input logic rst_n,
    // Config. inputs
    input logic                                 i_timer_en,
    input logic [base_wait_wd_p-1:0]            i_base_wait,
    input logic [2*bpp_p-1:0]                   i_blank_interval,
    input logic [$clog2(bpp_p)-1:0]             i_pix_bit,
    // Outputs
    output logic [$clog2(vpixel_p)-1:0] o_row_sel,
    output logic o_out_en_n
);
    localparam out_rows_p = vpixel_p/segments_p;

    logic                       out_en;
    logic [cnt_wd_p-1:0]         wait_cnt;
    logic [cnt_wd_p-1:0]         wait_max;
    logic [cnt_wd_p-1:0]         cnt_max;
    logic                       new_row;
    logic [2*bpp_p-1:0]         new_row_cnt; // Counter value where row select should be updated (in the middle of blanking interval)
    logic [$clog2(bpp_p)-1:0]   pix_bit;
    logic [$clog2(vpixel_p)-1:0] cur_row;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out_en <= 1;
            wait_cnt <= '0;
            pix_bit <= '0;
        end else begin
            // Reset counters
            if (!i_timer_en) begin
                wait_cnt <= '0;
                pix_bit <= '0;
            // Active low interval
            end else if (wait_cnt < wait_max) begin
                wait_cnt <= wait_cnt + 1;
                out_en <= 1'b0;
            // Blanking interval
            end else if (wait_cnt < cnt_max-1) begin
                wait_cnt <= wait_cnt + 1;
                out_en <= 1;
            // Update bit weight
            end else begin
                wait_cnt <= '0;
                if (pix_bit == bpp_p-1) begin
                    pix_bit <= '0;
                end else begin
                    pix_bit <= pix_bit + 1;
                end
            end
        end    
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cur_row <= '0;
        end else begin
            if (!i_timer_en) begin
                cur_row <= '0;
            end else if (new_row) begin
                if (cur_row == out_rows_p-1) begin
                    cur_row <= '0;
                end else begin
                    cur_row <= cur_row + 1;
                end
            end
        end
    end

    
    assign wait_max = i_base_wait << pix_bit;
    assign cnt_max = wait_max + i_blank_interval;
    assign new_row_cnt = wait_max + i_blank_interval/2;
    assign new_row = (pix_bit == bpp_p-1) && (wait_cnt == new_row_cnt);
    assign o_out_en_n = out_en;
    assign o_row_sel = cur_row;
endmodule