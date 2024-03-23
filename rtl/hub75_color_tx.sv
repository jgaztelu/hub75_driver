module hub75_color_tx #(
    parameter  hpixel_p     = 64,                   // Display width in pixels
    parameter  vpixel_p     = 64,                   // Display height in pixels
    parameter  bpp_p        = 8,                    // Bits per pixel color channel
    parameter  segments_p = 2,   // Number of display segments
    parameter clk_div_wd_p = 8, // Maximum width for clock divider

    localparam frame_size_p = hpixel_p * vpixel_p,
    localparam addr_width_p = $clog2(frame_size_p),
    localparam pix_bit_width_p = $clog2(bpp_p)
    ) (
    input logic clk,
    input logic rst_n,
    // Config. inputs
    input logic [clk_div_wd_p-1:0]  i_clk_div,
    // Control interface
    input logic                     i_tx_start,
    input logic [addr_width_p-1:0]  i_init_addr,
    input logic [pix_bit_width_p-1:0] i_pix_bit,
    output logic                    o_ready,
    // Mem interface
    output logic [addr_width_p-1:0] o_rd_addr,
    input logic  [segments_p-1:0][2:0][bpp_p-1:0] i_rd_data,
    // Output interface
    output logic o_serial_clk,
    output logic [segments_p-1:0] o_red,
    output logic [segments_p-1:0] o_green,
    output logic [segments_p-1:0] o_blue,
    output logic                  o_latch_en     // Latch enable for shift register
    
);
    localparam logic [$clog2(hpixel_p)-1:0] max_cnt = hpixel_p-1;

    typedef enum {IDLE,TX_LOW,TX_HIGH,LATCH} tx_state_t;
    tx_state_t tx_state;

    logic [$clog2(hpixel_p)-1:0]    tx_cnt;
    logic [clk_div_wd_p-1:0]        clk_cnt;
    logic [clk_div_wd_p-1:0]        latch_cnt;
    logic tx_start_d, tx_start_pos;
    logic [addr_width_p-1:0]        init_addr_int;
    logic [clk_div_wd_p-1:0]        clk_div_int;
    logic [pix_bit_width_p-1:0]     pix_bit_int;
    logic [addr_width_p-1:0]        rd_addr;


    always_ff @(posedge clk) begin
        if (!rst_n) begin
            tx_cnt <= '0;
            clk_cnt <= '0;
            latch_cnt <= '0;
            o_ready <= 0;
            o_serial_clk <= 0;
            o_red <= '0;
            o_green <= '0;
            o_blue <= '0;
            o_latch_en <= 0;
            tx_state <= IDLE;
            tx_start_d <= 0;
            init_addr_int <= '0;
            pix_bit_int <= '0;
            rd_addr <= '0;
        end else begin
            tx_start_d <= i_tx_start;
            case (tx_state)
                IDLE: begin
                    o_red <= '0;
                    o_green <= '0;
                    o_blue <= '0;
                    o_ready <= 1;
                    o_serial_clk <= 0;
                    rd_addr <= i_init_addr;
                    if (i_tx_start) begin
                        o_ready <= 0;
                        // Sample control inputs
                        init_addr_int <= i_init_addr;
                        clk_div_int <= i_clk_div;
                        pix_bit_int <= i_pix_bit;
                        tx_state <= TX_LOW;
                    end
                end
                
                TX_LOW: begin
                    clk_cnt <= clk_cnt + 1;
                    if (clk_cnt == clk_div_int/2 - 1) begin
                        o_serial_clk <= 1;
                        tx_state <= TX_HIGH;
                    end else begin                    
                        o_serial_clk <= 0;
                        for (int i=0; i<segments_p; i++) begin
                            o_red[i] <= i_rd_data[i][2][pix_bit_int];
                            o_green[i] <= i_rd_data[i][1][pix_bit_int];
                            o_blue[i] <= i_rd_data[i][0][pix_bit_int];
                        end
                    end
                end

                TX_HIGH: begin
                    if (clk_cnt == clk_div_int-2 && tx_cnt < max_cnt) begin
                        // Read new pixels
                        rd_addr <= rd_addr + 1;
                    end
                    if (clk_cnt == clk_div_int-1) begin
                        clk_cnt <= 0;
                        if (tx_cnt == max_cnt) begin
                            o_serial_clk <= 0; 
                            o_latch_en <= 1;
                            latch_cnt <= clk_div_int-1;
                            tx_cnt <= '0;
                            rd_addr <= i_init_addr;
                            tx_state <= LATCH;
                        end else begin
                            tx_cnt <= tx_cnt + 1;
                            o_serial_clk <= 0;
                            tx_state <= TX_LOW;
                        end
                    end else begin
                        clk_cnt <= clk_cnt + 1;
                    end
                end

                LATCH: begin
                    if (latch_cnt > 0) begin
                        o_latch_en <= 1;
                        latch_cnt <= latch_cnt - 1;
                    end else begin
                        o_latch_en <= 0;
                        tx_state <= IDLE;
                    end
                end
            endcase
        end
    end

    assign tx_start_pos = i_tx_start & !tx_start_d;
    assign o_rd_addr = rd_addr;
endmodule