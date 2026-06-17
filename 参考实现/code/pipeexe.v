module pipeexe (
    ealuc, ealuimm, ea, eb, eimm, eshift, ern0, epc4, ejal, ern, ealu
);
    input  [31:0] ea, eb;        // EXE阶段使用的寄存器值
    input  [31:0] eimm;          // 立即数
    input  [31:0] epc4;          // 当前指令地址加4（PC+4）
    input   [4:0] ern0;          // 暂时的目标寄存器编号
    input   [3:0] ealuc;         // ALU控制信号
    input         ealuimm;       // ALU输入b是否为立即数的信号
    input         eshift;        // 当前指令是否为移位指令
    input         ejal;          // 当前指令是否为jal指令
    output [31:0] ealu;          // EXE阶段的结果
    output  [4:0] ern;           // 目标寄存器编号

    wire   [31:0] alua;          // ALU输入a
    wire   [31:0] alub;          // ALU输入b
    wire   [31:0] ealu0;         // ALU中间结果
    wire   [31:0] epc8;          // 当前指令地址加8（PC+8）
    wire          z;             // ALU零标志（未使用）
    wire   [31:0] esa = {eimm[5:0],eimm[31:6]};  // 移位数量

    // 计算PC+8
    cla32 ret_addr (epc4, 32'h4, 1'b0, epc8);  

    // 选择ALU输入a
    mux2x32 alu_in_a (ea, esa, eshift, alua); 

    // 选择ALU输入b
    mux2x32 alu_in_b (eb, eimm, ealuimm, alub); 

    // 选择ALU结果或PC+8
    mux2x32 save_pc8 (ealu0, epc8, ejal, ealu); 

    // 确定目标寄存器编号，若为jal指令则设为31
    assign ern = ern0 | {5{ejal}};  

    // ALU操作
    alu al_unit (alua, alub, ealuc, ealu0, z);  

endmodule
