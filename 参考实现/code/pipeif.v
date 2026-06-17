module pipeif (
    pcsrc, pc, bpc, rpc, jpc, npc, pc4, ins
);    // IF阶段模块
    input  [31:0] pc;      // 程序计数器
    input  [31:0] bpc;     // 分支目标地址
    input  [31:0] rpc;     // jr指令的跳转目标地址
    input  [31:0] jpc;     // j/jal指令的跳转目标地址
    input   [1:0] pcsrc;   // 下一个PC（npc）选择信号
    output [31:0] npc;     // 下一个PC值
    output [31:0] pc4;     // 当前PC值加4
    output [31:0] ins;     // 从指令存储器获取的指令

    // 4选1多路复用器，用于选择下一个PC值
    mux4x32 next_pc (pc4, bpc, rpc, jpc, pcsrc, npc);

    // 32位加法器，用于计算当前PC值加4
    cla32  pc_plus4 (pc, 32'h4, 1'b0, pc4);

    // 指令存储器，用于根据PC值获取指令
    pl_inst_mem inst_mem (pc, ins);
endmodule
