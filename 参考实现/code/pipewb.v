module pipewb (walu, wmo, wm2reg, wdi); // 写回（WB）阶段

    input  [31:0] walu;                   // 写回阶段的ALU结果或pc+8
    input  [31:0] wmo;                    // 写回阶段的内存输出数据
    input         wm2reg;                 // 写回阶段的内存到寄存器信号
    output [31:0] wdi;                    // 要写入寄存器文件的数据

    mux2x32 wb (walu, wmo, wm2reg, wdi);  // 选择wdi的数据来源

endmodule
