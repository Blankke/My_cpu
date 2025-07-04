module ex_mem(
    input clk, rst, flush,
    input [31:0]ex_PC,
    input ex_RegWrite,
    input ex_MemWrite,
    input [1:0] ex_WDsel,
    input [1:0] ex_GPRSel,
    input [2:0] ex_DMType,
    input [31:0] ex_aluout,
    input [31:0] ex_RD2,
    input [4:0] ex_rd,
    output reg me_RegWrite,
    output reg me_MemWrite,
    output reg [1:0] me_WDsel,
    output reg [1:0] me_GPRSel,
    output reg [2:0] me_DMType,
    output reg [31:0] me_aluout,
    output reg [31:0] me_RD2,
    output reg [4:0] me_rd,
    output reg [31:0] me_PC
);
always @(posedge clk or posedge rst) begin
    if (rst || flush) begin
        me_RegWrite <= 1'b0;
        me_MemWrite <= 1'b0;
        me_WDsel <= 2'b00;
        me_GPRSel <= 2'b00;
        me_DMType <= 3'b000;
        me_aluout <= 32'b0;
        me_RD2 <= 32'b0;
        me_rd <= 5'b0;
        me_PC <= 32'b0;
    end else begin
        me_RegWrite <= ex_RegWrite;
        me_MemWrite <= ex_MemWrite;
        me_WDsel <= ex_WDsel;
        me_GPRSel <= ex_GPRSel;
        me_DMType <= ex_DMType;
        me_aluout <= ex_aluout;
        me_RD2 <= ex_RD2;
        me_rd <= ex_rd;
        me_PC <= ex_PC;
    end
end
endmodule