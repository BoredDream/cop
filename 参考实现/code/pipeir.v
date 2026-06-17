module pipeir (pc4, ins, wir, clk, clrn, dpc4, inst);   // IF/ID流水线寄存器
    input         clk, clrn;                      // 时钟和复位信号
    input         wir;                            // 写使能信号
    input  [31:0] pc4;                            // IF阶段的PC+4
    input  [31:0] ins;                            // IF阶段的指令
    output [31:0] dpc4;                           // ID阶段的PC+4
    output [31:0] inst;                           // ID阶段的指令

    // dffe32模块：数据触发器，具有使能控制
    dffe32 pc_plus4    (pc4, clk, clrn, wir, dpc4);   // 存储PC+4值的寄存器
    dffe32 instruction (ins, clk, clrn, wir, inst);   // 存储指令的寄存器
endmodule