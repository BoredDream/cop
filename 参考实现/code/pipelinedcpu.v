module pipelinedcpu (
    clk, clrn, pc, inst, ealu, malu, wdi
);  // 流水线CPU模块
    input         clk, clrn;    // 时钟和复位信号
    output [31:0] pc;           // 程序计数器
    output [31:0] inst;         // ID阶段的指令
    output [31:0] ealu;         // EXE阶段的ALU结果
    output [31:0] malu;         // MEM阶段的ALU结果
    output [31:0] wdi;          // 写入寄存器文件的数据
    // IF阶段信号
    wire   [31:0] pc4;          // IF阶段的PC+4
    wire   [31:0] ins;          // IF阶段的指令
    wire   [31:0] npc;          // IF阶段的下一个PC值
    // ID阶段信号
    wire   [31:0] dpc4;         // ID阶段的PC+4
    wire   [31:0] bpc;          // beq和bne指令的分支目标地址
    wire   [31:0] jpc;          // jr指令的跳转目标地址
    wire   [31:0] da, db;       // ID阶段的两个操作数a和b
    wire   [31:0] dimm;         // ID阶段的32位扩展立即数
    wire    [4:0] drn;          // ID阶段的目标寄存器编号
    wire    [3:0] daluc;        // ID阶段的ALU控制信号
    wire    [1:0] pcsrc;        // ID阶段的下一个PC选择信号
    wire          wpcir;        // pipepc和pipeir写使能信号
    wire          dwreg;        // ID阶段的寄存器文件写使能信号
    wire          dm2reg;       // ID阶段的内存到寄存器信号
    wire          dwmem;        // ID阶段的内存写使能信号
    wire          daluimm;      // ID阶段ALU输入b是否为立即数的信号
    wire          dshift;       // ID阶段的移位信号
    wire          djal;         // ID阶段的jal信号
    // EXE阶段信号
    wire   [31:0] epc4;         // EXE阶段的PC+4
    wire   [31:0] ea, eb;       // EXE阶段的两个操作数a和b
    wire   [31:0] eimm;         // EXE阶段的32位扩展立即数
    wire    [4:0] ern0;         // EXE阶段临时目标寄存器编号
    wire    [4:0] ern;          // EXE阶段的目标寄存器编号
    wire    [3:0] ealuc;        // EXE阶段的ALU控制信号
    wire          ewreg;        // EXE阶段的寄存器文件写使能信号
    wire          em2reg;       // EXE阶段的内存到寄存器信号
    wire          ewmem;        // EXE阶段的内存写使能信号
    wire          ealuimm;      // EXE阶段ALU输入b是否为立即数的信号
    wire          eshift;       // EXE阶段的移位信号
    wire          ejal;         // EXE阶段的jal信号
    // MEM阶段信号
    wire   [31:0] mb;           // MEM阶段的操作数b
    wire   [31:0] mmo;          // MEM阶段的内存输出数据
    wire    [4:0] mrn;          // MEM阶段的目标寄存器编号
    wire          mwreg;        // MEM阶段的寄存器文件写使能信号
    wire          mm2reg;       // MEM阶段的内存到寄存器信号
    wire          mwmem;        // MEM阶段的内存写使能信号
    // WB阶段信号
    wire   [31:0] wmo;          // WB阶段的内存输出数据
    wire   [31:0] walu;         // WB阶段的ALU结果
    wire    [4:0] wrn;          // WB阶段的目标寄存器编号
    wire          wwreg;        // WB阶段的寄存器文件写使能信号
    wire          wm2reg;       // WB阶段的内存到寄存器信号

    // 程序计数器
    pipepc prog_cnt (npc, wpcir, clk, clrn, pc);
    // IF阶段
    pipeif if_stage (pcsrc, pc, bpc, da, jpc, npc, pc4, ins);      
    // IF/ID流水线寄存器
    pipeir fd_reg (pc4, ins, wpcir, clk, clrn, dpc4, inst);
    // ID阶段
    pipeid id_stage (mwreg, mrn, ern, ewreg, em2reg, mm2reg, dpc4, inst, wrn, wdi,
                     ealu, malu, mmo, wwreg, clk, clrn, bpc, jpc, pcsrc, wpcir,
                     dwreg, dm2reg, dwmem, daluc, daluimm, da, db, dimm, drn,
                     dshift, djal);      
    // ID/EXE流水线寄存器
    pipedereg de_reg (dwreg, dm2reg, dwmem, daluc, daluimm, da, db, dimm, drn, 
                      dshift, djal, dpc4, clk, clrn, ewreg, em2reg, ewmem,
                      ealuc, ealuimm, ea, eb, eimm, ern0, eshift, ejal, epc4);
    // EXE阶段
    pipeexe exe_stage (ealuc, ealuimm, ea, eb, eimm, eshift, ern0, epc4, ejal,
                       ern, ealu);      
    // EXE/MEM流水线寄存器
    pipeemreg em_reg (ewreg, em2reg, ewmem, ealu, eb, ern, clk, clrn, mwreg,
                      mm2reg, mwmem, malu, mb, mrn);
    // MEM阶段
    pipemem mem_stage (mwmem, malu, mb, clk, mmo);      
    // MEM/WB流水线寄存器
    pipemwreg mw_reg (mwreg, mm2reg, mmo, malu, mrn, clk, clrn, wwreg, wm2reg,
                      wmo, walu, wrn);
    // WB阶段
    pipewb wb_stage (walu, wmo, wm2reg, wdi);      
endmodule