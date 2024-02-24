import gamma_corr_pkg::*;

module gamma_corr #(
  parameter pixel_width_p = 8
  )
  (
    input logic clk,
    input logic [pixel_width_p-1:0] pixel_in,
    output logic [pixel_width_p-1:0] pixel_out
  );

  logic [7:0] gamma_pixel;

  // always_ff @(posedge clk) begin
  //   pixel_out <= gamma_corr_c[pixel_in];
  //   // pixel_out <= gamma_pixel;
  // end
  assign pixel_out = gamma_corr_c[pixel_in];
endmodule // gamma_corr
