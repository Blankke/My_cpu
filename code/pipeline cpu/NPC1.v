`include "ctrl_encode_def.v"
//// NPC control signal
//`define NPC_PLUS4   3'b000
//`define NPC_BRANCH  3'b001
//`define NPC_JUMP    3'b010
//`define NPC_JALR 3'b100

module NPC1 (PC,PC_EX, NPCOp, IMM, NPC,aluout,PCWrite,
              INT_Signal, EXL_set, INT_PEND, SEPC, MRET);  // next pc module
    
   input  [31:0] PC;        // pc
   input  [31:0] PC_EX;     // pc_EX
   input  [2:0]  NPCOp;     // next pc operation
   input  [31:0] IMM;       // immediate
   input  [31:0] aluout;
   input  PCWrite;
   output reg [31:0] NPC;   // next pc
   input  INT_Signal;       // interrupt signal
   input  EXL_set;
   input  [2:0] INT_PEND;   // interrupt pending signal (3-bit)
   input  [31:0] SEPC;      // saved exception program counter
   input  MRET;             // MRET instruction signal



   wire [31:0] PCPLUS4;
   
   assign PCPLUS4 = PC + 4; // pc + 4
   
   always @(*) begin
      if(PCWrite)
      begin
          // 中断处理具有最高优先级
          if(INT_Signal) begin
              // 发生中断时跳转到中断向量
              NPC = `INTERRUPT_VECTOR;
          end
          // MRET指令处理 - 从中断返回
          else if(MRET) begin
              NPC = SEPC;  // 返回到保存的异常PC
          end
          // 正常指令流控制
          else begin
              case (NPCOp)
                  `NPC_INTERRUPT: NPC = `INTERRUPT_VECTOR; // 中断向量（备用）
                  `NPC_PLUS4:     NPC = PCPLUS4;
                  `NPC_BRANCH:    NPC = PC_EX + IMM;
                  `NPC_JUMP:      NPC = PC_EX + IMM;
                  `NPC_JALR:      NPC = aluout;
                  default:        NPC = PCPLUS4;
              endcase
          end
      end
      else NPC = PC;
   end // end always
   
endmodule