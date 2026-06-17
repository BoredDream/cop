module pipepc (npc, wpc, clk, clrn, pc); // 程序计数器

    input         clk, clrn;              // 时钟和复位信号
    input         wpc;                    // 程序计数器写使能信号
    input  [31:0] npc;                    // 下一个程序计数器的值
    output [31:0] pc;                     // 程序计数器的当前值

    // dffe32 模块实例化，参数依次为: d - 输入数据, clk - 时钟, clrn - 复位, e - 使能, q - 输出数据
    dffe32 prog_cntr (
        npc, clk, clrn, wpc, pc
    ); // 程序计数器

endmodule