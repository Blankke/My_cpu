module ExceptionUnit(
    input [7:0] STATUS,
    input [7:0] EX_SCAUSE,
    input [7:0] INTMASK,
    output EXL_Set,
    output INT_Signal,
    output [2:0] INT_PEND
);

    // STATUS寄存器位定义
    wire IE = STATUS[0];   // 全局中断使能位
    wire EXL = STATUS[1];  // 异常级别位，为1时在异常状态，不响应中断
    
    // 检测是否有中断请求
    wire [7:0] interrupt_requests = EX_SCAUSE & INTMASK;
    wire has_interrupt = |interrupt_requests;
    
    // 只有在全局中断使能且不在异常状态时才响应中断
    assign INT_Signal = has_interrupt & IE & ~EXL;
    
    // 设置异常级别位
    assign EXL_Set = INT_Signal;
    
    // 中断优先级编码器 - 选择最高优先级的中断
    //TODO : 此处没有按照scause的值进行排序，需要改进
    assign INT_PEND = (interrupt_requests[0]) ? 3'b000 :
                      (interrupt_requests[1]) ? 3'b001 :
                      (interrupt_requests[2]) ? 3'b010 :
                      (interrupt_requests[3]) ? 3'b011 :
                      (interrupt_requests[4]) ? 3'b100 :
                      (interrupt_requests[5]) ? 3'b101 :
                      (interrupt_requests[6]) ? 3'b110 :
                      (interrupt_requests[7]) ? 3'b111 : 3'b000;

endmodule
