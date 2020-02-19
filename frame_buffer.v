module frame_buffer (
        input i_clk,
        input i_rstn,
        
        // input from timing generator
        input i_de,
        input i_hs,
        input i_vs,
        
        // output to display
        output reg o_de,
        output reg o_hs,
        output reg o_vs,
        output reg o_pix
);

  parameter WIDTH  = 128;
  parameter HEIGHT = 120;

  reg mem[0:WIDTH*HEIGHT-1];


  // tricks to make this frame buffer work on icestick
  //
  // 640 by 480 frame buffer would not fit
  // scale down by 4
  // 640/4 * 480/4 = 160 * 120 = 19200 bits =~ 5 block rams
  //
  //
  // to get liner address from rows and columns
  // we can use the following formula
  //
  // addr = row * 640 + col
  //
  // since the ice40hx1k does not have a hard multiplier
  // multiplication by 640 would take up too many resources
  //
  // let's make the actual horizontal active 512 to allow for bit shifting for
  // multiplication
  //
  // still scaling by 4
  // 512/4 = 128 by 480/4=120 => 128x120 = 15360 bits =~ 4 block rams
  //
  // addr = row/4 * 128 + col/4 = ((row >> 2) << 7) + (col >> 2)
  //
  // to map 512 (640) to 128 
  // count 0 to 127 with pclk while de==1
  // once overflow to 0 happens, output black pixels until next line of the input 
  // timing is reached and increment row count
  // 
  // the active resolution is 640 but only the first 512 is actually used, the rest
  // is padded black

  reg [9:0] q_col_cnt;
  reg [9:0] q_row_cnt;
  reg q_padding;
  reg q_de_0, q_hs_0, q_vs_0;
  always @(posedge i_clk, negedge i_rstn) begin
    if (!i_rstn) begin
      q_col_cnt <= 9'b0;
      q_padding <= 1'b0;
      q_row_cnt <= 9'b0;
      q_de_0    <= 1'b0;
      q_hs_0    <= 1'b0;
      q_vs_0    <= 1'b0;
    end else begin
      if (i_de) begin
        if (q_padding) begin
          q_col_cnt <= 9'b0;
        end else begin
          // update column counter on data enable high
          q_col_cnt <= q_col_cnt + 1'b1;
          // when 512th pixel is reach, output padding
          if (q_col_cnt == 9'b111111111) begin
            // increment row counter
            q_row_cnt <= q_row_cnt + 1'b1;
            q_padding <= 1'b1;
          end
        end
      end else begin
        q_padding <= 1'b0;
      end
      
      if (i_vs) begin
        // reset row counter on vsync
        q_row_cnt <= 9'b0;
      end
      
      q_de_0 <= i_de;
      q_hs_0 <= i_hs;
      q_vs_0 <= i_vs;
    end
  end
    
  reg [13:0] q_raddr;
  reg q_de_1, q_hs_1, q_vs_1;
  reg q_padding_1;
  always @(posedge i_clk, negedge i_rstn) begin
    if (!i_rstn) begin
      q_raddr <= 14'b0;
      q_de_1 <= 1'b0;
      q_hs_1 <= 1'b0;
      q_vs_1 <= 1'b0;
      q_padding_1 <= 1'b0;
    end else begin
      q_raddr <= q_row_cnt[9:2] << 7 + q_col_cnt[9:2];
      q_de_1 <= q_de_0;
      q_hs_1 <= q_hs_0;
      q_vs_1 <= q_vs_0;
      q_padding_1 <= q_padding;
    end
  end
  
  reg q_data;
  always @(posedge i_clk) begin
    q_data <= mem[q_raddr];
  end
  
  always @(posedge i_clk, negedge i_rstn) begin
    if (!i_rstn) begin
      o_de <= 1'b0;
      o_hs <= 1'b0;
      o_vs <= 1'b0;
      o_pix <= 1'b0;
    end else begin
      o_de <= q_de_1;
      o_hs <= q_hs_1;
      o_vs <= q_vs_1;
      if (i_de) begin
        if (q_padding_1) begin
          o_pix <= 1'b0;
        end else begin
          o_pix <= q_data;
        end
      end else begin
        o_pix <= 1'b0;
      end 
    end
  end
  
  
  // test writer fsm
  reg [13:0] q_waddr;
  reg q_wdata;
  reg [2:0] q_state;
    always @(posedge i_clk, negedge i_rstn) begin
    if (!i_rstn) begin
      q_state <= 3'b0;
    end else begin
      case (q_state)
        3'd0: begin
          q_waddr <= 14'd0;
          q_wdata <= 1'b1;
          q_state <= 3'd1;
        end
        3'd1: begin
          q_waddr <= 14'd127;
          q_wdata <= 1'b1;
          q_state <= 3'd2;
        end
        3'd2: begin
          q_waddr <= 14'd15232;
          q_wdata <= 1'b1;
          q_state <= 3'd3;
        end
        3'd3: begin
          q_waddr <= 14'd15359;
          q_wdata <= 1'b1;
          q_state <= 3'd0;
        end
      endcase
    end
  end
  
  always @(posedge i_clk) begin
    mem[q_waddr] <= q_wdata;
  end
  

endmodule
