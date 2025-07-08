`include "ctrl_encode_def.v"
//// NPC control signal
//`define NPC_PLUS4   3'b000
//`define NPC_BRANCH  3'b001
//`define NPC_JUMP    3'b010
//`define NPC_JALR 3'b100

module NPC1 (PC,PC_EX, NPCOp, IMM, NPC,aluout,PCWrite,SEPC,MRET);  // next pc module
    input [31:0] SEPC;        // pc
   input  [31:0] PC;        // pc
   input  [31:0] PC_EX;        // pc_EX
   input  [2:0]  NPCOp;     // next pc operation
   input  [31:0] IMM;       // immediate
	input [31:0] aluout;
	input PCWrite;
   input MRET;
   output reg [31:0] NPC;   // next pc
   
   wire [31:0] PCPLUS4;
   
   assign PCPLUS4 = PC + 4; // pc + 4
   
   always @(*) begin
      if(PCWrite)
      begin
         if(SEPC != 32'b0 && MRET) begin
            NPC = SEPC; // MRET指令时，使用SEPC作为下一条指令地址
         end
         else if(NPCOp == `NPC_INT) begin
            NPC = 32'h00000a74; // Interrupt handling
         end
         else  case (NPCOp)
              `NPC_PLUS4:  NPC = PCPLUS4;
              `NPC_BRANCH: NPC = PC_EX+IMM;
              `NPC_JUMP:   NPC = PC_EX+IMM;
              `NPC_JALR:	NPC =aluout;
              default:     NPC = PCPLUS4;
         endcase
      end
      else NPC=PC;
   end // end always
   
endmodule