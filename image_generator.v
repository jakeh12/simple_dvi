`timescale 1ns / 1ps

module image_generator (
  input             i_clk,
  input             i_rstn,
  input             i_de,
  input             i_hs,
  input             i_vs,
  input      [10:0] i_x,
  input      [10:0] i_y,
  output reg        o_de,
  output reg        o_hs,
  output reg        o_vs,
  output reg        o_pix
);
  
  always @(posedge i_clk, negedge i_rstn) begin
    if (!i_rstn) begin
      o_de  <= 0;
      o_hs  <= 0;
      o_vs  <= 0;
      o_pix <= 0;
    end else begin
      o_de  <= i_de;
      o_hs  <= i_hs;
      o_vs  <= i_vs;
      if (i_x == 0 || i_x == 639 || i_y == 0 || i_y == 479) begin
        o_pix <= 1'b1;
      end else begin
        o_pix <= 1'b0;
      end
    end
  end
  
endmodule
