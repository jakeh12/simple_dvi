`timescale 1ns / 1ps

module ddr_serializer(
  input       i_pxlclk, // pixel clock
  input       i_serclk, // serial clock (5x pxlclk)
  input       i_rstn,   // async inv reset
  input [9:0] i_data,   // input data
  output reg  o_ser_re, // serial output rising edge
  output reg  o_ser_fe  // serial output falling edge
);

  // both the rising edge and falling edge 
  // data should be sampled at the rising edge of the serial clock by the ddr
  // register input and outputted at their corresponding edges.
  //
  //                  ____      ____      ____      ____      ____      ____
  // i_serclk    ____|    |____|    |____|    |____|    |____|    |____|    |
  //
  //                 0         0         1_________1_________0         0
  // o_ser_re    _______________________|                   |_______________
  //
  //                 0         1_________0         0         0         0
  // o_ser_fe    ______________|         |___________________________________
  //
  //                           0    0    0    1____1____0    1____0    0    0
  // ddr_output  _____________________________|         |____|    |__________
  //
  
  // register input on pixel clock
  reg [9:0] r_pxlclk;
  
  always @(posedge i_pxlclk, negedge i_rstn) begin
    if (!i_rstn) begin
      r_pxlclk <= 0;
    end else begin
      r_pxlclk <= i_data;
    end
  end
  
	// mod 5 counter
  reg [2:0] r_bit_cnt;
	
	// output 10 bits serially at serclk rate
  reg [9:0] r_serclk;
  
  always @(posedge i_serclk, negedge i_rstn) begin
    if (!i_rstn) begin // asynchronous reset
      r_serclk  <= 0;
      r_bit_cnt <= 0;
    end else begin
      // increment mod 5 counter
      r_bit_cnt <= r_bit_cnt + 1;
      
      // load pxlclk domain register into serclk domain register 
      // when counter reaches four (5th beat)
      if (r_bit_cnt == 4) begin
        r_bit_cnt  <= 0; // mod 5 counter reset
        r_serclk <= r_pxlclk;
      end
      
      // assign rising edge data (index 0, 2, or 4)
      o_ser_re <= r_serclk[{r_bit_cnt, 1'b0}];
      
      // assign falling edge data (index 1, 3, or 5)
      o_ser_fe <= r_serclk[{r_bit_cnt, 1'b0} + 1];
    end
  end
  
endmodule
