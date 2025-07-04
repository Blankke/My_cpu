`include "ctrl_encode_def.v"

module SCPU2(
    input      clk,            // clock
    input      reset,          // reset
    input [31:0]  inst_in,     // instruction
    input [31:0]  Data_in,     // data from data memory
    input INT,
    input MIO_ready,
    output    mem_w,          // output: memory write signal
    output [31:0] PC_out,     // PC address
      // memory write
    output [31:0] Addr_out,   // ALU output
    output [31:0] Data_out,// data to data memory
    output CPU_MIO,

//    input  [4:0] reg_sel,    // register selection (for debug use)
//    output [31:0] reg_data , // selected register data (for debug use)
    output [2:0] DMType
);

    // 流水线寄存器控制信号
    wire IF_ID_write_enable;    //only if will be stalled
    wire IF_ID_flush;   // id and ex will be flushed
    wire ID_EX_flush;
    reg [31:0] RF_WD;  // Data that will be written to the register file
    
    // 流水线寄存器实例化
    // IF/ID 流水线寄存器
    wire [31:0] IF_ID_PC, IF_ID_inst; 
    if_id u_if_id (
       .clk(clk),
       .rst(reset),
       .pause(~IF_ID_write_enable),
       .flush(IF_ID_flush),
       .if_pc(PC_out),
       .if_instr(inst_in),
       .id_pc(IF_ID_PC),
       .id_instr(IF_ID_inst)
    );

    wire PCWrite;
    // ID stage
    //instruction fields
    wire [6:0] Op = IF_ID_inst[6:0];
    wire [2:0] Funct3 = IF_ID_inst[14:12];
    wire [6:0] Funct7 = IF_ID_inst[31:25];
    wire [4:0] rs1 = IF_ID_inst[19:15];
    wire [4:0] rs2 = IF_ID_inst[24:20];
    wire [4:0] rd = IF_ID_inst[11:7];
    // immediate extension
    wire [31:0] immout;
    wire [4:0] iimm_shamt;
	wire [11:0] iimm,simm,bimm;
	wire [19:0] uimm,jimm;
	assign iimm_shamt=IF_ID_inst[24:20];
	assign iimm=IF_ID_inst[31:20];
	assign simm={IF_ID_inst[31:25],IF_ID_inst[11:7]};
	assign bimm={IF_ID_inst[31],IF_ID_inst[7],IF_ID_inst[30:25],IF_ID_inst[11:8]};
	assign uimm=IF_ID_inst[31:12];
	assign jimm={IF_ID_inst[31],IF_ID_inst[19:12],IF_ID_inst[20],IF_ID_inst[30:21]};
    
    // EX stage
    wire [31:0] aluout_EX;  //result from ALU first come out in ex stage
    wire Zero_EX;    //same as above
    // ID_EX 
    wire RegWrite_EX, MemWrite_EX, ALUSrc_EX;  //stored in ID_EX register
    wire [4:0] ALUOp_EX;     //stored in ID_EX register,used in alu
    wire [1:0] GPRSel_EX, WDSel_EX;     //used later in WB stage
    wire [2:0] DMType_EX, NPCOp_EX_temp; //used in NPC and data memory
    // use the tmp wire to avoid the Zero_EX signal
    // 0: PC + 4, 1: Branch target address, 2: Jump address, 3: JALR address

    wire [2:0] NPCOp_EX = {NPCOp_EX_temp[2:1], NPCOp_EX_temp[0] & Zero_EX};   
    wire [31:0] RD1_EX, RD2_EX, immout_EX, PC_EX; //stored in ID_EX register used in alu or detect hazard
    wire [4:0] rs1_EX, rs2_EX, rd_EX;
    wire [31:0] NPC; 
    
    // EX/MEM 流水线寄存器信号
    wire RegWrite_MEM, MemWrite_MEM;  //used in data memory and WB stage
    wire [1:0] WDSel_MEM, GPRSel_MEM;  //used in WB stage
    wire [2:0] DMType_MEM;
    wire [31:0] aluout_MEM, RD2_MEM, PC_MEM;
    wire [4:0] rd_MEM;

    assign Addr_out = aluout_MEM;
    assign Data_out = RD2_MEM;
    assign mem_w = MemWrite_MEM;
    assign DMType = DMType_MEM;
    
    // MEM/WB 流水线寄存器信号
    wire RegWrite_WB;
    wire [1:0] WDSel_WB;
    wire [31:0] Data_in_WB, aluout_WB, PC_WB;
    wire [4:0] rd_WB;
    PC u_PC (
       .clk(clk),
       .rst(reset),
       .NPC(NPC),
       .PC(PC_out)
    );



    // ???????????
    wire RegWrite, MemWrite, ALUSrc;
    wire [1:0] WDSel, GPRSel;
    wire [4:0] ALUOp;
    wire [2:0] NPCOp, DMType_ID;
    wire [5:0] EXTOp;
    wire Zero;  // ?????EX??��?????????????
    wire ID_EX_MemRead; // ??��?????????????????
//    assign ID_EX_MemRead = (ID_EX_out[159] == 1'b0) && (ID_EX_out[150:149] == `WDSel_FromMEM); // ???????????��?
    assign ID_EX_MemRead = WDSel_EX[0]; // ???????????��?
    
    ctrl1 u_ctrl (
       .Op(Op),
       .Funct7(Funct7),
       .Funct3(Funct3),
       .Zero(Zero),
       .RegWrite(RegWrite),
       .MemWrite(MemWrite),
       .EXTOp(EXTOp),
       .ALUOp(ALUOp),
       .NPCOp(NPCOp),
       .ALUSrc(ALUSrc),
       .GPRSel(GPRSel),
       .WDSel(WDSel),
       .DMType(DMType_ID)
    );


 	EXT1 u_EXT(
		.iimm_shamt(iimm_shamt), .iimm(iimm), .simm(simm), .bimm(bimm),
		.uimm(uimm), .jimm(jimm),
		.EXTOp(EXTOp), .immout(immout)
	);

    // 寄存器堆
    wire [31:0] RD1, RD2;
    RF1 u_RF (
       .clk(clk),
       .rst(reset),
       .RFWr(RegWrite_WB),
       .A1(rs1),
       .A2(rs2),
       .A3(rd_WB),
       .WD(RF_WD),
       .RD1(RD1),
       .RD2(RD2)
    );

    // ID/EX 流水线寄存器
    id_ex u_id_ex (
       .clk(clk),
       .rst(reset),
       .flush(ID_EX_flush),
       .id_RegWrite(RegWrite),
       .id_MemWrite(MemWrite),
       .id_ALUop(ALUOp),
       .id_ALUsrc(ALUSrc),
       .id_GPRSel(GPRSel),
       .id_WDsel(WDSel),
       .id_DMType(DMType_ID),
       .id_NPCOp(NPCOp),
       .id_RD1(RD1),
       .id_RD2(RD2),
       .id_immout(immout),
       .id_rs1(rs1),
       .id_rs2(rs2),
       .id_rd(rd),
       .id_PC(IF_ID_PC),
       .ex_RegWrite(RegWrite_EX),
       .ex_MemWrite(MemWrite_EX),
       .ex_ALUop(ALUOp_EX),
       .ex_ALUsrc(ALUSrc_EX),
       .ex_GPRSel(GPRSel_EX),
       .ex_WDsel(WDSel_EX),
       .ex_DMType(DMType_EX),
       .ex_NPCOp(NPCOp_EX_temp),
       .ex_RD1(RD1_EX),
       .ex_RD2(RD2_EX),
       .ex_immout(immout_EX),
       .ex_rs1(rs1_EX),
       .ex_rs2(rs2_EX),
       .ex_rd(rd_EX),
       .ex_PC(PC_EX)
    );
    HazardDetectionUnit u_hazard (
       .IF_ID_rs1(rs1),
       .IF_ID_rs2(rs2),
       .ID_EX_rd(rd_EX),
       .ID_EX_MemRead(ID_EX_MemRead),
       .ID_EX_NPCOp(NPCOp_EX),
       .stall(stall_signal),
       .IF_ID_flush(IF_ID_flush),
       .PCWrite(PCWrite)
    );
    // 冲突检测和控制信号
    wire stall_signal;
    wire Branch_or_Jump = |NPCOp_EX;
    assign ID_EX_flush = stall_signal | Branch_or_Jump;
    assign IF_ID_write_enable = ~stall_signal;

    

    // ?????
    wire [1:0] ForwardA, ForwardB;
    ForwardingUnit u_forward (
       .MEM_RegWrite(RegWrite_MEM),
       .MEM_rd(rd_MEM),
       .WB_RegWrite(RegWrite_WB),
       .WB_rd(rd_WB),
       .EX_rs1(rs1_EX),
       .ForwardA(ForwardA),
       .EX_rs2(rs2_EX),
       .ForwardB(ForwardB)
    );


//forwarding
    // Forwarding logic for RD1 and RD2
    wire [31:0] RD1_forwarded = (ForwardA == 2'b00)? RD1_EX :
                                (ForwardA == 2'b01)? RF_WD:
                                (ForwardA == 2'b10)? aluout_MEM : 32'b0;
    wire [31:0] RD2_forwarded = (ForwardB == 2'b00)? RD2_EX :
                                (ForwardB == 2'b01)? RF_WD:
                                (ForwardB == 2'b10)? aluout_MEM : 32'b0;
    wire [31:0] B_EX = ALUSrc_EX? immout_EX : RD2_forwarded;

    alu u_alu (
       .A(RD1_forwarded),
       .B(B_EX),
       .ALUOp(ALUOp_EX),
       .C(aluout_EX),
       .Zero(Zero_EX),     
       .PC(PC_EX)
    );

    // 下一个PC的计算
    NPC1 u_NPC (
       .PC(PC_out),
       .PC_EX(PC_EX),
       .NPCOp(NPCOp_EX),
       .IMM(immout_EX),
       .NPC(NPC),
       .PCWrite(PCWrite),
       .aluout(aluout_EX)
    );

    // EX/MEM 流水线寄存器
    ex_mem u_ex_mem (
       .clk(clk),
       .rst(reset),
       .flush(1'b0),
       .ex_PC(PC_EX),
       .ex_RegWrite(RegWrite_EX),
       .ex_MemWrite(MemWrite_EX),
       .ex_WDsel(WDSel_EX),
       .ex_GPRSel(GPRSel_EX),
       .ex_DMType(DMType_EX),
       .ex_aluout(aluout_EX),
       .ex_RD2(RD2_forwarded),
       .ex_rd(rd_EX),
       .me_RegWrite(RegWrite_MEM),
       .me_MemWrite(MemWrite_MEM),
       .me_WDsel(WDSel_MEM),
       .me_GPRSel(GPRSel_MEM),
       .me_DMType(DMType_MEM),
       .me_aluout(aluout_MEM),
       .me_RD2(RD2_MEM),
       .me_rd(rd_MEM),
       .me_PC(PC_MEM)
    );

    // MEM/WB 流水线寄存器
    mem_wb u_mem_wb (
       .clk(clk),
       .rst(reset),
       .mem_PC(PC_MEM),
       .mem_RegWrite(RegWrite_MEM),
       .mem_WDsel(WDSel_MEM),
       .mem_Datain(Data_in),
       .mem_aluout(aluout_MEM),
       .mem_rd(rd_MEM),
       .wb_RegWrite(RegWrite_WB),
       .wb_WDsel(WDSel_WB),
       .wb_Datain(Data_in_WB),
       .wb_aluout(aluout_WB),
       .wb_rd(rd_WB),
       .wb_PC(PC_WB)
    );

    // WB阶段 - 写回数据选择
    always @(*) begin
        case(WDSel_WB)
            `WDSel_FromALU: RF_WD = aluout_WB;
            `WDSel_FromMEM: RF_WD = Data_in_WB;
            `WDSel_FromPC:  RF_WD = PC_WB + 4;
            default: RF_WD = 32'b0;
        endcase
    end


endmodule