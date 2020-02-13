`timescale 1ns / 1ps

module timing_generator (
    input i_clk,
    input i_rstn,
    output reg o_de,
    output reg o_hs,
    output reg o_vs,
    output reg [10:0] o_x,
    output reg [10:0] o_y
);
  
  // default timing for vga 640x480 at 60 hz (industry standard)
  parameter HAC = 640; // horizontal active area pixels
  parameter HFP =  16; // horizontal front porch pixels
  parameter HSP =  96; // horizontal sync pulse pixels
  parameter HBP =  48; // horizontal back porch pixels
  parameter VAC = 480; // vertical active area lines
  parameter VFP =  10; // vertical front porch lines
  parameter VSP =   2; // vertical sync pulse lines
  parameter VBP =  33; // vertical back porch lines
  
  // the timing generator generates timing signals according to this diagram
  //  _____________________________
  // |                             |____________________________________...*o_de
  // .                             .          _____________
  // ________________________________________|             |____________....o_hs
  // .                             .         .             .
  // .                             .         .             .                o_vs
  // .                             .         .             .                 :
  // |<------------HAC------------>|<--HFP-->|<----HSP---->|<---HBP--->|  -  |
  // |*****************************|         |             |           |  |  |
  // |*****************************|         |             |           |  |  |
  // |*****************************|         |             |           |  |  |
  // |*****************************|         |             |           |  |  |
  // |******* ACTIVE AREA *********|         |             |           | VAC |
  // |*****************************|         |             |           |  |  |
  // |*****************************|         |             |           |  |  |
  // |*****************************|         |             |           |  |  |
  // |*****************************|         |             |           |  |  |
  // |-----------------------------|---------|-------------|-----------|  -  |
  // |                             |         |             |           |  |  |
  // |                             |         |             |           | VFP |
  // |                             |         |             |           |  |  |
  // |-----------------------------|---------|-------------|-----------|  -  --
  // |                             |         |             |           | VSP   |
  // |-----------------------------|---------|-------------|-----------|  -  --
  // |                             |         |             |           |  |  |
  // |                             |         |             |           | VBP |
  // |                             |         |             |           |  |  |
  // |-----------------------------|---------|-------------|-----------|  -  |
  //
  // *o_de stays low during vertical blanking time (outside of VAC)
  
  // counters for rows and columns
  reg [10:0] r_col_cnt;
  reg [10:0] r_row_cnt;
  
  always @(posedge i_clk, negedge i_rstn) begin
    if (!i_rstn) begin
      // clear counters on reset
      r_col_cnt <= 0;
      r_row_cnt <= 0;
    end else begin
      // increment column counter on each rising edge of the clock
      r_col_cnt <= r_col_cnt + 1;
      if (r_col_cnt == HAC + HFP + HSP + HBP - 1) begin
        // end of line, clear column counter and increment row counter
        r_col_cnt <= 11'b0;
        r_row_cnt <= r_row_cnt + 1;
        if (r_row_cnt == VAC + VFP + VSP + VBP - 1) begin
          // end of frame, clear row counter
          r_row_cnt <= 0;
        end
      end
    end
  end
  
  // generate internal horizontal data enable and vertical data enable
  wire w_hde;
  wire w_vde;
  assign w_hde = r_col_cnt < HAC ? 1'b1 : 1'b0;
  assign w_vde = r_row_cnt < VAC ? 1'b1 : 1'b0;
  
  always @(posedge i_clk, negedge i_rstn) begin
    if (!i_rstn) begin
      o_de <= 1'b0;
      o_hs <= 1'b0;
      o_vs <= 1'b0;
      o_x  <= 11'b0;
      o_y  <= 11'b0;
    end else begin
      // generate output signals
      o_de <= i_rstn && w_hde && w_vde;
      o_hs <= r_col_cnt >= HAC + HFP && r_col_cnt < HAC + HFP + HSP ? 1'b1 : 1'b0;
      o_vs <= r_row_cnt >= VAC + VFP && r_row_cnt < VAC + VFP + VSP ? 1'b1 : 1'b0;
      // output the current column and row counter as x and y in the active area
      o_x <= w_hde && w_vde ? r_col_cnt : HAC - 1;
      o_y <= w_vde          ? r_row_cnt : VAC - 1;
    end
  end

endmodule
