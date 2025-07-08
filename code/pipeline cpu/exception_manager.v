// Reg [31:0] SEPC;
// Reg [7:0] STATUS;
// Reg [7:0] INTMASK;
module ExceptionUnit(
    input[7:0] STATUS, 
    input [7:0] EX_SCAUSE, 
    input [7:0] INTMASK, 
    output EXL_Set, 
    output INT_Signal, 
    output reg [2:0] INT_PEND);

    wire [7:0] SCAUSE_PEND;
    assign SCAUSE_PEND = INTMASK & EX_SCAUSE;
    assign INT_Signal = (|SCAUSE_PEND) & STATUS[1] & ~STATUS[0]; 
    assign EXL_Set = INT_Signal;

    always @(*) begin
        case (SCAUSE_PEND)
            8'b00000001: INT_PEND <= 3'b000; // Timer Interrupt
            8'b00000010: INT_PEND <= 3'b001; // 非法指令
            8'b00000100: INT_PEND <= 3'b010; // 先设置这个是系统调用
            8'b00001000: INT_PEND <= 3'b011; // Reserved
            8'b00010000: INT_PEND <= 3'b100; // Reserved
            8'b00100000: INT_PEND <= 3'b101; // Reserved
            8'b01000000: INT_PEND <= 3'b110; // Reserved
            8'b10000000: INT_PEND <= 3'b111; // Reserved
            default: INT_PEND <= 3'b111; // No Interrupt Pending
        endcase
    end


endmodule
