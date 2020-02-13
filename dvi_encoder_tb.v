`timescale 1ns / 1ps

module dvi_encoder_tb ();

  reg i_clk, i_rstn, i_pix, i_de, i_hs, i_vs;
  wire [9:0] o_tx_word;

  dvi_encoder dut (
    .i_clk     (i_clk),
    .i_rstn    (i_rstn),
    .i_pix     (i_pix),
    .i_de      (i_de),
    .i_hs      (i_hs),
    .i_vs      (i_vs),
    .o_tx_word (o_tx_word)
  );


  always begin
    i_clk = 1'b1;
    #5;
    i_clk = 1'b0;
    #5;
  end

  initial begin
    i_rstn = 1'b0; i_pix = 1'b0; i_de = 1'b0; i_hs = 1'b0; i_vs = 1'b0;
    #20;
    i_rstn = 1'b1;
    #20;
    i_de = 1'b1;
    #40;
    i_pix = 1'b1;
    #40;
    i_pix = 1'b0;
    #40;
    i_de = 1'b0;
    #20;
    i_hs = 1'b1;
    #20;
    i_hs = 1'b0;
    #20;
    i_vs = 1'b1;
    #20;
    i_vs = 1'b0;
    #20;
    i_hs = 1'b1;
    i_vs = 1'b1;
    #20;
    i_hs = 1'b0;
    i_vs = 1'b0;
  end

endmodule
