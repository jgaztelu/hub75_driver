module hub75_display #(
    parameter hpixel_p = 64,    // Display width in pixels
    parameter vpixel_p = 64,    // Display height in pixels
    parameter    bpp_p = 8,     // Bits per pixel color channel
    parameter segments_p = 2,   // Number of display segments
    localparam frame_size_p = 64*64,
    localparam addr_width_p = $clog2(frame_size_p)
) (
    // Clock and reset
    input logic clk,
    input logic rst_n,

    // Config inputs
    input logic i_enable,
    input logic [3:0] i_clk_div,
    /* Pixel read interface */
    output logic [addr_width_p-1:0] o_rd_addr,
    input logic [segments_p-1:0][2:0][bpp_p-1:0] i_rd_data,

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
    output logic E,

    // RGB outputs
    output logic R1,
    output logic R2,
    output logic G1,
    output logic G2,
    output logic B1,
    output logic B2
);

  logic [$clog2(vpixel_p)-1:0] row_sel;  // Row select
  logic                        clk_hub75;  // Output clock
  logic                        out_en;  // Output enable, used for display blanking
  logic                        out_stb;  // Strobe/latch signal

  // Row and column counters
  logic [$clog2(hpixel_p)-1:0] hcount;
  logic [$clog2(vpixel_p)-1:0] vcount;

  logic [$clog2(2**bpp_p)-1:0] wait_cnt;

  logic [   $clog2(bpp_p)-1:0] pixel_bit;  // Current bit to shift out

  logic [segments_p-1:0][bpp_p-1:0] r, g, b;  // Register RGB pixels from framebuf
  logic [segments_p-1:0] r_out, g_out, b_out;  // Output RGB bits

  logic [3:0] clk_div_cnt;  // Clock divider counter
  logic       clk_pulse;  // Pulse for output clock generation
  logic sync_pulse;       // Pulse to keep FSM in sync with output clock. Pulses every 2nd clk_pulse
  logic pulse_cnt;

  typedef enum {
    IDLE,
    PREFETCH,
    COLOR_TX,
    LATCH,
    WAIT
  } hub75_display_state_t;

  hub75_display_state_t disp_state;

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      disp_state <= IDLE;
      row_sel <= '0;
      out_en <= 0;
      out_stb <= 0;
      hcount <= '0;
      vcount <= '0;
      wait_cnt <= '0;
      pixel_bit <= '0;
      r <= '0;
      g <= '0;
      b <= '0;
      r_out <= 0;
      g_out <= 0;
      b_out <= 0;
    end else begin
      if (sync_pulse) begin
        case (disp_state)
          IDLE: begin
            row_sel <= '0;
            out_en <= 0;
            out_stb <= 0;
            hcount <= '0;
            vcount <= '0;
            wait_cnt <= '0;
            pixel_bit <= '0;
            r <= '0;
            g <= '0;
            b <= '0;
            r_out <= 0;
            g_out <= 0;
            b_out <= 0;
            o_rd_addr <= '0;
            if (i_enable) begin
              disp_state <= PREFETCH;
            end
          end

          PREFETCH: begin
            disp_state <= COLOR_TX;
            // Prefetch first pixel
            // for (int i = 0; i < segments_p; i++) begin
            //   r[i] <= i_rd_data[i][0];
            //   g[i] <= i_rd_data[i][1];
            //   b[i] <= i_rd_data[i][2];
            // end

            for (int i = 0; i < segments_p; i++) begin
              r_out[i] <= i_rd_data[i][0][pixel_bit];
              g_out[i] <= i_rd_data[i][1][pixel_bit];
              b_out[i] <= i_rd_data[i][2][pixel_bit];
            end
            hcount <= hcount + 1;
          end

          COLOR_TX: begin
            if (hcount < hpixel_p - 1) begin
              // // Shift data out for all segments
              // for (int i = 0; i < segments_p; i++) begin
              //   r_out[i] <= r[i][pixel_bit];
              //   g_out[i] <= g[i][pixel_bit];
              //   b_out[i] <= b[i][pixel_bit];
              // end

              // Shift data out for all segments
              for (int i = 0; i < segments_p; i++) begin
                r_out[i] <= i_rd_data[i][0][pixel_bit];
                g_out[i] <= i_rd_data[i][1][pixel_bit];
                b_out[i] <= i_rd_data[i][2][pixel_bit];
              end

              // // Fetch next pixel
              // for (int i = 0; i < segments_p; i++) begin
              //   r[i] <= i_rd_data[i][0];
              //   g[i] <= i_rd_data[i][1];
              //   b[i] <= i_rd_data[i][2];
              // end
              hcount <= hcount + 1;
            end else begin
              // Blank display before latching
              out_en <= 0;
              disp_state <= LATCH;
            end
            o_rd_addr <= vcount * hpixel_p + hcount;

          end

          LATCH: begin
            out_stb <= 1;
            row_sel <= vcount;
            disp_state <= WAIT;
          end

          WAIT: begin
            out_stb <= 0;
            out_en  <= 1;
            if (wait_cnt < 2 ** pixel_bit - 1) begin
              wait_cnt <= wait_cnt + 1;
            end else begin
              wait_cnt <= '0;
              if (pixel_bit == bpp_p - 1) begin
                if (vcount == vpixel_p - 1) begin
                  disp_state <= IDLE;
                end else begin
                  vcount <= vcount + 1;
                  pixel_bit <= '0;
                  hcount <= '0;
                  disp_state <= PREFETCH;
                end
              end else begin
                pixel_bit  <= pixel_bit + 1;
                disp_state <= PREFETCH;
              end
            end
          end
        endcase
      end
    end
  end

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      clk_div_cnt <= '0;
      clk_hub75   <= 0;
      clk_pulse  <= 0;
      sync_pulse <= 0;
      pulse_cnt <= 1;
    end else begin
      clk_pulse <= 0;
      if (clk_div_cnt == i_clk_div - 1) begin
        clk_div_cnt <= '0;
        clk_pulse  <= 1;
      end else begin
        clk_div_cnt <= clk_div_cnt + 1;
      end

      pulse_cnt <= pulse_cnt + clk_pulse;
      sync_pulse <= clk_pulse & pulse_cnt;
      if (clk_pulse) begin
        clk_hub75 <= !clk_hub75;
      end
    end
  end

  // Assign display outputs
  assign O_CLK = clk_hub75;
  assign STB = out_stb;
  assign OE = !out_en;
  assign A = row_sel[4];
  assign B = row_sel[3];
  assign C = row_sel[2];
  assign D = row_sel[1];
  assign E = row_sel[0];

  assign R1 = r_out[0];
  assign R2 = r_out[1];
  assign G1 = g_out[0];
  assign G2 = g_out[1];
  assign B1 = b_out[0];
  assign B2 = b_out[1];
endmodule
