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
// IF ID stage
wire [31:0] if_pc, if_instr;
wire [31:0] id_pc, id_instr;
wire if_id_pause, if_id_flush;
//reg if id pipeline
if_id IF_ID(
    .clk(clk), 
    .rst(reset), 
    .pause(if_id_pause), 
    .flush(if_id_flush),
    .if_pc(if_pc), 
    .if_instr(if_instr),
    .id_pc(id_pc), 
    .id_instr(id_instr)
);

wire [6:0] Op = id_instr[6:0];
wire [2:0] Funct3 = id_instr[14:12];
wire [6:0] Funct7 = id_instr[31:25];
wire [4:0] rs1 = id_instr[19:15];
wire [4:0] rs2 = id_instr[24:20];
wire [4:0] rd = id_instr[11:7];

wire [31:0] immout;
wire [4:0] iimm_shamt;
wire [11:0] iimm,simm,bimm;
wire [19:0] uimm,jimm;
assign iimm_shamt=id_instr[24:20];
assign iimm=id_instr[31:20];
assign simm={id_instr[31:25],id_instr[11:7]};
assign bimm={id_instr[31],id_instr[7],id_instr[30:25],id_instr[11:8]};
assign uimm=id_instr[31:12];
assign jimm={id_instr[31],id_instr[19:12],id_instr[20],id_instr[30:21]};


//ID-Ex
wire  id_ex_pause, id_ex_flush;
wire RegWrite;
wire MemWrite;
wire [4:0] ALUOp ;
wire ALUSrc;
wire [1:0] GPRSel ;
wire [1:0] WDSel ;
wire [2:0] DMType_ID;
wire [2:0] NPCOp ;
wire [31:0] RD1 ;
wire [31:0] RD2  ;
reg [31:0] RF_WD;  
// EX stage

wire [31:0] aluout_EX;
wire Zero_EX;
wire RegWrite_EX;
wire MemWrite_EX;
wire [4:0] ALUOp_EX ;
wire ALUSrc_EX;
wire [1:0] GPRSel_EX ;
wire [1:0] WDSel_EX ;
wire [2:0] DMType_EX ;
wire [2:0] NPCOp_EX ;
wire [31:0] RD1_EX ;
wire [31:0] RD2_EX  ;  
wire [31:0] immout_EX ;
wire [4:0] rs1_EX ;
wire [4:0] rs2_EX;
wire [4:0] rd_EX ;
wire [31:0] PC_EX ;
wire [31:0] NPC; 

// ID-EX pipeline register
id_ex ID_EX(
    .clk(clk), 
    .rst(reset), 
    .pause(id_ex_pause), 
    .flush(id_ex_flush),
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
    .id_PC(id_pc),

    .ex_RegWrite(RegWrite_EX),
    .ex_MemWrite(MemWrite_EX),
    .ex_ALUop(ALUOp_EX),
    .ex_ALUsrc(ALUSrc_EX),
    .ex_GPRSel(GPRSel_EX),
    .ex_WDsel(WDSel_EX),
    .ex_DMType(DMType_EX),
    .ex_NPCOp(NPCOp_EX),
    .ex_RD1(RD1_EX),
    .ex_RD2(RD2_EX),
    .ex_immout(immout_EX),
    .ex_rs1(rs1_EX),
    .ex_rs2(rs2_EX),
    .ex_rd(rd_EX),
    .ex_PC(PC_EX)
);

wire[31:0] NPC;
wire Zero;
wire [5:0] EXTOp;
wire ID_EX_MemRead= WDSel_EX[0];
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

//Mem
    wire [31:0] PC_MEM ;
    wire RegWrite_MEM;
    wire MemWrite_MEM;
    wire [1:0] WDSel_MEM;
    wire [1:0] GPRSel_MEM;
    wire [2:0] DMType_MEM;
    wire [31:0] aluout_MEM;
    wire [31:0] RD2_MEM;
    wire [4:0] rd_MEM;
    wire [31:0] aluout_MEM;
//
wire ex_me_flush;

ex_me EX_ME(
    .clk(clk), 
    .rst(reset), 
    .flush(id_ex_flush),
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

assign Addr_out = aluout_MEM;
assign Data_out = RD2_MEM;
assign mem_w = MemWrite_MEM;
assign DMType = DMType_MEM;

wire [31:0]PC_WB;
wire RegWrite_WB;
wire [1:0] WDSel_WB;
wire [31:0] Data_in_WB;
wire [31:0] aluout_WB;
wire [4:0] rd_WB;

mem_wb MEM_WB(
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

PC1 u_PC (
    .clk(clk),
    .rst(reset),
    .NPC(NPC),
    .PC(PC_out)
);

RF1 u_RF (
    .clk(clk),
    .rst(reset),
    .RFWr(RegWrite_WB),  // 写使能信号
    .A1(rs1),            // 读地址1 → 输出RD1
    .A2(rs2),            // 读地址2 → 输出RD2  
    .A3(rd_WB),          // 写地址  ← 输入WD
    .WD(RF_WD),          // 写数据
    .RD1(RD1),           // 读数据1
    .RD2(RD2)            // 读数据2
);

wire stall_signal ;

HazardDetectionUnit u_hazard (
    .IF_ID_rs1(rs1),
    .IF_ID_rs2(rs2),
    .ID_EX_rd(rd_EX),
    .ID_EX_MemRead(ID_EX_MemRead),
    .ID_EX_NPCOp(NPCOp_EX),
    .stall(stall_signal),
    .IF_ID_flush(if_id_flush),
    .PCWrite(PCWrite)
);

wire [2:0] NPCOp_Final = {NPCOp_EX[2], NPCOp_EX[1], NPCOp_EX[0] & Zero_EX}; //NPCOp的最终值

wire Branch_or_Jump = |NPCOp_Final;
assign id_ex_flush = stall_signal | Branch_or_Jump;
assign if_id_pause = ~stall_signal;
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

wire [31:0] RD1_forwarded = (ForwardA == 2'b00)? RD1_EX :
                            (ForwardA == 2'b01)? RF_WD:     //ld指令wb前递
                            (ForwardA == 2'b10)? aluout_MEM : 32'b0;  //数据冒险mem前递
wire [31:0] RD2_forwarded = (ForwardB == 2'b00)? RD2_EX :
                            (ForwardB == 2'b01)? RF_WD:
                            (ForwardB == 2'b10)? aluout_MEM : 32'b0;

//alu 数据选择
wire [31:0] B_EX = ALUSrc_EX? immout_EX : RD2_forwarded;
   
alu1 u_alu (
    .A(RD1_forwarded),
    .B(B_EX),
    .ALUOp(ALUOp_EX),
    .C(aluout_EX),
    .Zero(Zero_EX),     
    .PC(PC_EX)
);

NPC1 u_NPC (
    .PC(PC_out),
    .PC_EX(PC_EX),
    .NPCOp(NPCOp_Final),
    .IMM(immout_EX),
    .NPC(NPC),
    .PCWrite(PCWrite),
    .aluout(aluout_EX)
);

    always @(*) begin
        case(WDSel_WB)  // WDSel???
            `WDSel_FromALU: RF_WD = aluout_WB;
            `WDSel_FromMEM: RF_WD = Data_in_WB;
            `WDSel_FromPC:  RF_WD = PC_WB + 4;
            default: RF_WD = 32'b0;
        endcase
    end


endmodule