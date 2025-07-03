module mem_wb(
    input clk,
    input rst,
    input [31:0] mem_PC,
    input mem_RegWrite,
    input [1:0]mem_WDsel,
    input [31:0] mem_Datain,
    input [31:0] mem_aluout,
    input [4:0] mem_rd,
    output reg wb_RegWrite,
    output reg [1:0] wb_WDsel,
    output reg [31:0] wb_Datain,
    output reg [31:0] wb_aluout,
    output reg [4:0] wb_rd,
    output reg [31:0] wb_PC
);
always @(posedge clk or posedge rst) begin
    if (rst) begin
        wb_RegWrite <= 1'b0;
        wb_WDsel <= 2'b00;
        wb_Datain <= 32'b0;
        wb_aluout <= 32'b0;
        wb_rd <= 5'b0;
        wb_PC <= 32'b0;
    end else begin
        wb_RegWrite <= mem_RegWrite;
        wb_WDsel <= mem_WDsel;
        wb_Datain <= mem_Datain;
        wb_aluout <= mem_aluout;
        wb_rd <= mem_rd;
        wb_PC <= mem_PC;
    end
end
endmodule