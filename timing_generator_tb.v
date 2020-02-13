`timescale 1ns / 1ps

module timing_generator_tb ();

reg i_clk, i_rstn;
wire o_de, o_hs, o_vs;
wire [10:0] o_x, o_y;

  timing_generator dut (
    .i_clk  (i_clk),
    .i_rstn (i_rstn),
    .o_de   (o_de),
    .o_hs   (o_hs),
    .o_vs   (o_vs),
    .o_x    (o_x),
    .o_y    (o_y)
  );


  always begin
    i_clk = 1'b1;
    #5;
    i_clk = 1'b0;
    #5;
  end

  initial begin
    i_rstn = 1'b0;
    #20;
    i_rstn = 1'b1;
  end

endmodule
