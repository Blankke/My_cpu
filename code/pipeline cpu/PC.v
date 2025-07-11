module PC1( clk, rst, NPC, PC );

  input              clk; 
  input              rst;
  input       [31:0] NPC;
  output reg  [31:0] PC;

  always @(posedge clk, posedge rst)
    if (rst) 
      PC <= 32'h0000_0000; // Reset PC to 0
//      PC <= 32'h0000_3000;
    else  
      PC <= NPC; // Update PC with the next PC value
      
endmodule

