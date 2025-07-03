module id_ex(
    input clk, rst, pause, flush,

    input id_RegWrite,
    input id_MemWrite,
    input [4:0] id_ALUop,
    input id_ALUsrc,
    input [1:0]id_GPRSel,
    input [1:0]id_WDsel,
    input [2:0]id_DMType,
    input [2:0]id_NPCOp,
    input [31:0]id_RD1,
    input [31:0]id_RD2,
    input [31:0]id_immout,
    input [4:0]id_rs1,
    input [4:0]id_rs2,
    input [4:0]id_rd,
    input [31:0]id_PC,
    output reg ex_RegWrite,
    output reg ex_MemWrite,
    output reg [4:0] ex_ALUop,
    output reg ex_ALUsrc,
    output reg [1:0] ex_GPRSel,
    output reg [1:0] ex_WDsel,
    output reg [2:0] ex_DMType,
    output reg [2:0] ex_NPCOp,
    output reg [31:0] ex_RD1,
    output reg [31:0] ex_RD2,
    output reg [31:0] ex_immout,
    output reg [4:0] ex_rs1,
    output reg [4:0] ex_rs2,
    output reg [4:0] ex_rd,
    output reg [31:0] ex_PC
);

always @(posedge clk) begin
    if(rst || pause || flush)begin
        ex_ALUop = 5'b00000;
        ex_ALUsrc = 1'b0;
        ex_GPRSel = 2'b00;
        ex_WDsel = 2'b00;
        ex_DMType = 3'b000;
        ex_NPCOp = 3'b000;
        ex_RD1 = 32'b0;
        ex_RD2 = 32'b0;
        ex_immout = 32'b0;
        ex_rs1 = 5'b0;
        ex_rs2 = 5'b0;
        ex_rd = 5'b0;
        ex_RegWrite = 1'b0;
        ex_MemWrite = 1'b0;
        ex_PC = 32'b0;
    end else begin
        ex_ALUop <= id_ALUop;
        ex_ALUsrc <= id_ALUsrc;
        ex_GPRSel <= id_GPRSel;
        ex_WDsel <= id_WDsel;
        ex_DMType <= id_DMType;
        ex_NPCOp <= id_NPCOp;
        ex_RD1 <= id_RD1;
        ex_RD2 <= id_RD2;
        ex_immout <= id_immout;
        ex_rs1 <= id_rs1;
        ex_rs2 <= id_rs2;
        ex_rd <= id_rd;
        ex_RegWrite <= id_RegWrite;
        ex_MemWrite <= id_MemWrite;
        ex_PC <= id_PC;
    end
    
end
endmodule