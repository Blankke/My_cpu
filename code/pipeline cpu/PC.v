module PC( clk, rst, NPC, PC, stall );

  input              clk;
  input              rst;
  input       [31:0] NPC;
  input              stall;  // 添加停顿信号
  output reg  [31:0] PC;

  always @(posedge clk, posedge rst)
    if (rst) 
      PC <= 32'h0000_0000;
//      PC <= 32'h0000_3000;
    else if (!stall)  // 只有在不停顿时才更新PC
      PC <= NPC;
      
endmodule

