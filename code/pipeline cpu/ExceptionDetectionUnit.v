`include "ctrl_encode_def.v"

module ExceptionDetectionUnit(
    input [31:0] instruction,    // 当前指令
    input [31:0] PC,            // 当前PC值
    input [6:0] Op,             // 操作码
    input [6:0] Funct7,         // funct7域
    input [2:0] Funct3,         // funct3域
    input       valid_inst,     // 指令是否有效（来自控制器）
    
    output [7:0] SCAUSE,        // 异常原因码
    output       INT_Signal,    // 中断信号
    output       ECALL,         // ECALL指令检测
    output       MRET          // MRET指令检测
);

    // 异常原因码定义
    parameter ECALL_SCAUSE = 8'h08;           // Environment call
    parameter ILLEGAL_INST_SCAUSE = 8'h02;    // Illegal instruction
    parameter INST_ADDR_MISALIGN = 8'h00;     // Instruction address misaligned
    parameter MRET_SCAUSE = 8'h00;            // MRET doesn't generate exception, just for detection

    // ECALL和MRET指令识别
    wire system_type = Op[6]&Op[5]&Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0]; // 1110011
    
    // ECALL: opcode=1110011, funct3=000, rs1=00000, rs2=00000, funct7=0000000
    wire i_ecall = system_type & 
                   ~Funct3[2] & ~Funct3[1] & ~Funct3[0] & // funct3 = 000
                   ~instruction[19] & ~instruction[18] & ~instruction[17] & ~instruction[16] & ~instruction[15] & // rs1 = 00000
                   ~instruction[24] & ~instruction[23] & ~instruction[22] & ~instruction[21] & ~instruction[20] & // rs2 = 00000
                   ~Funct7[6] & ~Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0]; // funct7 = 0000000
    
    // MRET: opcode=1110011, funct3=000, imm[11:0]=001100000010 (0x302)
    wire i_mret = system_type & 
                  ~Funct3[2] & ~Funct3[1] & ~Funct3[0] & // funct3 = 000
                  ~instruction[31] & ~instruction[30] & instruction[29] & instruction[28] & // imm[11:8] = 0011
                  ~instruction[27] & ~instruction[26] & ~instruction[25] & ~instruction[24] & // imm[7:4] = 0000  
                  ~instruction[23] & ~instruction[22] & instruction[21] & ~instruction[20]; // imm[3:0] = 0010
    
    // 指令地址未对齐检测 (PC必须是4字节对齐)
    wire addr_misaligned = PC[1] | PC[0];
    
    // 非法指令检测
    // 这里简化处理：如果不是已知的合法指令且不是ECALL/MRET，则认为是非法指令
    wire illegal_instruction = ~valid_inst & ~i_ecall & ~i_mret;
    
    // 异常优先级：地址未对齐 > 非法指令 > ECALL
    // MRET不产生异常，只是用于检测
    assign SCAUSE = addr_misaligned ? INST_ADDR_MISALIGN :
                   illegal_instruction ? ILLEGAL_INST_SCAUSE :
                   i_ecall ? ECALL_SCAUSE : 8'h00;
    
    // 中断信号：当检测到任何异常时产生
    assign INT_Signal = addr_misaligned | illegal_instruction | i_ecall;
    
    // 输出指令检测信号
    assign ECALL = i_ecall;
    assign MRET = i_mret;

endmodule
