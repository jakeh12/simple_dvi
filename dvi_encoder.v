`timescale 1ns / 1ps

module dvi_encoder (
  input i_clk,
  input i_rstn,
  input i_pix,
  input i_de,
  input i_hs,
  input i_vs,
  output reg [9:0] o_tx_word
);

  localparam SYM_CTRL_0 = 10'b1101010100;
  localparam SYM_CTRL_1 = 10'b0010101011;
  localparam SYM_CTRL_2 = 10'b0101010100;
  localparam SYM_CTRL_3 = 10'b1010101011;

  localparam SYM_00_PD = 10'b1111111111;
  localparam SYM_00_ND = 10'b0100000000;
  localparam SYM_FF_PD = 10'b0011111111;
  localparam SYM_FF_ND = 10'b1000000000;

  reg r_disparity;

  always @(posedge i_clk, negedge i_rstn) begin
    if (!i_rstn) begin
      o_tx_word <= 10'b0;
      r_disparity <= 2'b0;
    end else begin
      if (i_de) begin
        // sending pixel symbol
        case ({i_pix, r_disparity})
          2'b00 : begin
            // current disparity is negative
            // send positive disparity zero intensity symbol
            // update disparity to positive
            o_tx_word   <= SYM_00_PD;
            r_disparity <= 1'b1;
          end
          2'b01 : begin
            // current disparity is positive
            // send negative disparity zero intensity symbol
            // update disparity to negative
            o_tx_word   <= SYM_00_ND;
            r_disparity <= 1'b0;
          end
          2'b10 : begin
            // current disparity is negative
            // send positive disparity full intensity symbol
            // update disparity to positive
            o_tx_word   <= SYM_FF_PD;
            r_disparity <= 1'b1;
          end
          2'b11 : begin
            // current disparity is positive
            // send negative disparity full intensity symbol
            // update disparity to negative
            o_tx_word   <= SYM_FF_ND;
            r_disparity <= 1'b0;
          end
        endcase
      end else begin
        // sending blanking symbol
        case ({i_vs, i_hs})
          2'b00 : o_tx_word <= SYM_CTRL_0;
          2'b01 : o_tx_word <= SYM_CTRL_1;
          2'b10 : o_tx_word <= SYM_CTRL_2;
          2'b11 : o_tx_word <= SYM_CTRL_3;
        endcase
        // control symbols have neutral disparity
        // reset disparity so we start with positive pixel symbol in active line
        r_disparity <= 1'b0;
      end
    end 
  end

endmodule
