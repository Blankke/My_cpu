`timescale 1ns / 1ps

module ExceptionDetectionUnit_tb;

    // Testbench signals
    reg [31:0] instruction;
    reg [31:0] PC;
    reg [6:0] Op;
    reg [6:0] Funct7;
    reg [2:0] Funct3;
    reg valid_inst;
    
    wire [7:0] SCAUSE;
    wire INT_Signal;
    wire ECALL;
    wire MRET;

    // Instantiate the Unit Under Test (UUT)
    ExceptionDetectionUnit uut (
        .instruction(instruction),
        .PC(PC),
        .Op(Op),
        .Funct7(Funct7),
        .Funct3(Funct3),
        .valid_inst(valid_inst),
        .SCAUSE(SCAUSE),
        .INT_Signal(INT_Signal),
        .ECALL(ECALL),
        .MRET(MRET)
    );

    initial begin
        // Initialize inputs
        instruction = 32'h0;
        PC = 32'h0;
        Op = 7'h0;
        Funct7 = 7'h0;
        Funct3 = 3'h0;
        valid_inst = 1'b0;

        // Test case 1: Normal aligned address, no exception
        #10;
        PC = 32'h00001000;  // 4-byte aligned
        valid_inst = 1'b1;
        Op = 7'b0010011;    // I-type (addi)
        $display("Test 1 - Normal instruction: SCAUSE=%h, INT_Signal=%b, ECALL=%b, MRET=%b", 
                 SCAUSE, INT_Signal, ECALL, MRET);

        // Test case 2: Address misalignment
        #10;
        PC = 32'h00001001;  // Not 4-byte aligned
        $display("Test 2 - Address misaligned: SCAUSE=%h, INT_Signal=%b, ECALL=%b, MRET=%b", 
                 SCAUSE, INT_Signal, ECALL, MRET);

        // Test case 3: ECALL instruction
        #10;
        PC = 32'h00001004;  // Aligned again
        instruction = 32'h00000073; // ECALL: opcode=1110011, all other fields=0
        Op = 7'b1110011;    // SYSTEM opcode
        Funct7 = 7'b0000000;
        Funct3 = 3'b000;
        valid_inst = 1'b0;  // ECALL is not a "normal" instruction
        $display("Test 3 - ECALL instruction: SCAUSE=%h, INT_Signal=%b, ECALL=%b, MRET=%b", 
                 SCAUSE, INT_Signal, ECALL, MRET);

        // Test case 4: MRET instruction
        #10;
        instruction = 32'h30200073; // MRET: opcode=1110011, imm=0x302, funct3=000
        Op = 7'b1110011;
        Funct7 = 7'b0011000; // This comes from imm[11:5]
        Funct3 = 3'b000;
        $display("Test 4 - MRET instruction: SCAUSE=%h, INT_Signal=%b, ECALL=%b, MRET=%b", 
                 SCAUSE, INT_Signal, ECALL, MRET);

        // Test case 5: Illegal instruction
        #10;
        instruction = 32'hFFFFFFFF; // Invalid instruction
        Op = 7'b1111111;    // Invalid opcode
        valid_inst = 1'b0;
        $display("Test 5 - Illegal instruction: SCAUSE=%h, INT_Signal=%b, ECALL=%b, MRET=%b", 
                 SCAUSE, INT_Signal, ECALL, MRET);

        // End simulation
        #10;
        $finish;
    end

endmodule
