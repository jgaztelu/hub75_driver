module hub75_timer #(
    parameter int bpp_p = 8
) (
    input logic clk,
    input logic rst_n,
    // Config. inputs
    input logic                     i_timer_en,
    input logic [2*bpp_p-1:0]       i_base_wait,
    input logic [2*bpp_p-1:0]       i_blank_interval,
    input logic [$clog2(bpp_p)-1:0] i_pix_bit,
    // Outputs
    output logic o_out_en_n
);

    logic [2*bpp_p-1:0]         wait_cnt;
    logic [2*bpp_p-1:0]         wait_max;
    logic [2*bpp_p-1:0]         cnt_max;
    logic [$clog2(bpp_p)-1:0]   pix_bit;


    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            o_out_en_n <= 1;
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
                o_out_en_n <= 1'b0;
            // Blanking interval
            end else if (wait_cnt < cnt_max-1) begin
                wait_cnt <= wait_cnt + 1;
                o_out_en_n <= 1;
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

    
    assign wait_max = i_base_wait << pix_bit;
    assign cnt_max = wait_max + i_blank_interval;
endmodule