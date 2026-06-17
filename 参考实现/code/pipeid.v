module pipeid (mwreg,mrn,ern,ewreg,em2reg,mm2reg,dpc4,inst,wrn,wdi,ealu,
               malu,mmo,wwreg,clk,clrn,bpc,jpc,pcsrc,nostall,wreg,m2reg,
               wmem,aluc,aluimm,a,b,dimm,rn,shift,jal);// ID阶段
    input         clk, clrn;                           // 时钟和复位信号
    input  [31:0] dpc4;                                // ID阶段的PC+4
    input  [31:0] inst;                                // ID阶段的指令
    input  [31:0] wdi;                                 // WB阶段写回的数据
    input  [31:0] ealu;                                // EXE阶段ALU的结果
    input  [31:0] malu;                                // MEM阶段ALU的结果
    input  [31:0] mmo;                                 // MEM阶段存储器输出
    input   [4:0] ern;                                 // EXE阶段目标寄存器号
    input   [4:0] mrn;                                 // MEM阶段目标寄存器号
    input   [4:0] wrn;                                 // WB阶段目标寄存器号
    input         ewreg;                               // EXE阶段的写寄存器控制信号
    input         em2reg;                              // EXE阶段的内存到寄存器控制信号
    input         mwreg;                               // MEM阶段的写寄存器控制信号
    input         mm2reg;                              // MEM阶段的内存到寄存器控制信号
    input         wwreg;                               // WB阶段的写寄存器控制信号
    output [31:0] bpc;                                 // 分支目标地址
    output [31:0] jpc;                                 // 跳转目标地址
    output [31:0] a, b;                                // 操作数a和b
    output [31:0] dimm;                                // 32位立即数
    output  [4:0] rn;                                  // 目标寄存器号
    output  [3:0] aluc;                                // ALU控制信号
    output  [1:0] pcsrc;                               // 下一条指令PC选择信号
    output        nostall;                             // 无流水线暂停信号
    output        wreg;                                // 写寄存器控制信号
    output        m2reg;                               // 内存到寄存器控制信号
    output        wmem;                                // 写存储器控制信号
    output        aluimm;                              // ALU的b输入是立即数
    output        shift;                               // 指令是移位指令
    output        jal;                                 // 指令是jal
    wire    [5:0] op   = inst[31:26];                  // 操作码
    wire    [4:0] rs   = inst[25:21];                  // 源寄存器rs
    wire    [4:0] rt   = inst[20:16];                  // 源寄存器rt
    wire    [4:0] rd   = inst[15:11];                  // 目标寄存器rd
    wire    [5:0] func = inst[05:00];                  // 功能码
    wire   [15:0] imm  = inst[15:00];                  // 立即数
    wire   [25:0] addr = inst[25:00];                  // 地址
    wire          regrt;                               // 目标寄存器号是rt
    wire          sext;                                // 符号扩展
    wire   [31:0] qa, qb;                              // 寄存器文件输出
    wire    [1:0] fwda, fwdb;                          // 前递a和b
    wire   [15:0] s16  = {16{sext & inst[15]}};        // 16位符号扩展
    wire   [31:0] dis  = {dimm[29:0],2'b00};           // 分支偏移量
    wire          rsrtequ = ~|(a^b);                   // 寄存器rs等于寄存器rt
    pipeidcu cu (mwreg,mrn,ern,ewreg,em2reg,mm2reg,    // 控制单元
                 rsrtequ,func,op,rs,rt,wreg,m2reg,
                 wmem,aluc,regrt,aluimm,fwda,fwdb,
                 nostall,sext,pcsrc,shift,jal);
    regfile r_f (rs,rt,wdi,wrn,wwreg,~clk,clrn,qa,qb); // 寄存器文件
    mux2x5  d_r (rd,rt,regrt,rn);                      // 选择目标寄存器号
    mux4x32 s_a (qa,ealu,malu,mmo,fwda,a);             // a前递选择
    mux4x32 s_b (qb,ealu,malu,mmo,fwdb,b);             // b前递选择
    cla32 b_adr (dpc4,dis,1'b0,bpc);                   // 计算分支目标地址
    assign dimm = {s16,imm};                           // 32位立即数
    assign jpc  = {dpc4[31:28],addr,2'b00};            // 计算跳转目标地址
endmodule