module sccpu_dataflow(clock, resetn, inst, mem, pc, wmem, alu, data, intr, inta);
input     [31:0]   inst, mem;
input         clock, resetn, intr;
output   [31:0]  pc, alu, data;
output wmem, inta;

wire  [31:0] p4 , npc, adr, ra, alua, alub, res, alu_mem, alu_mem_c0;
wire  [3:0] aluc;
wire  [4:0] reg_dest, wn;
wire  [1:0] pcsource;
wire  zero, wmem, wreg, regrt, m2reg, shift, aluimm, jal, sext;
wire  overflow;

// 移位量sa
wire  [31:0]  sa  =  {27'b0, inst[10:6]};

// 控制单元(新增 op1/rs, rd, ov, sta, intr 等端口)
sccu_dataflow cu  (inst[31:26], inst[25:21], inst[15:11], inst[5:0], zero, overflow, sta, intr,
                   wmem, wreg, regrt, m2reg, aluc, shift, aluimm, pcsource, jal, sext,
                   inta, exc, wsta, wcau, wepc, mtc0, mfc0, selpc, cause);

// 符号扩展偏移
wire   e  =  sext  &  inst[15];
wire   [15:0]       imm =  {16{e}};
wire  [31:0]       immediate  =  {imm, inst[15:0]};
// 注意:当前 CPU/ 已修正为完整16位符号扩展(教材参考代码用 imm[13:0] 是旧版bug)
wire  [31:0]  offset  =  {imm, inst[15:0], 2'b00};

wire co_unused;

// PC寄存器(输入改为 next_pc)
dff32  ip  (next_pc, clock, resetn, pc);
// PC+4
cla32  pcplus4   (pc, 32'h4, 1'b0, p4, co_unused);
// 分支目标地址
cla32  br_adr     (p4, offset, 1'b0, adr, co_unused);
// j/jal跳转地址
wire  [31:0]        jpc =  {p4[31:28], inst[25:0], 2'b00};

// ALU输入多路选择
mux2x32  alu_b  (data, immediate, aluimm, alub) ;
mux2x32  alu_a  (ra, sa, shift, alua);

// 写回结果选择
mux2x32  result   (alu, mem, m2reg, alu_mem);
// mfc0 选择 CP0 寄存器数据
mux4x32  fromc0   (alu_mem, sta, cau, epc, mfc0, alu_mem_c0);
// jal返回地址保存p4
mux2x32  link (alu_mem_c0, p4, jal, res);

// 目标寄存器选择
mux2x5  reg_wn   (inst[15:11], inst[20:16] , regrt, reg_dest);
// jal 强制写 r31
assign wn = jal ? 5'd31 : reg_dest;

// 下一条PC多路选择(正常流程)
mux4x32  nextpc  (p4, adr, ra, jpc, pcsource, npc);

// 通用寄存器堆
regfile  rf   (inst[25:21] , inst[20:16] , res, wn, wreg, clock, resetn, ra, data);
// ALU运算单元(新增 overflow 输出)
alu  al_unit   (alua, alub, aluc, alu, zero, overflow);

// ============================================================
// 异常/中断相关新增电路
// ============================================================
parameter EXC_BASE = 32'h00000008;

wire exc, wsta, wcau, wepc, mtc0;
wire [1:0] mfc0, selpc;
wire [31:0] sta, cau, epc, sta_in, cau_in, epc_in, sta_l1_a0, epc_l1_a0, next_pc;
wire [31:0] cause;

// 3 个 CP0 寄存器
dffe32  c0_Status  (sta_in, clock, resetn, wsta, sta);
dffe32  c0_Cause   (cau_in, clock, resetn, wcau, cau);
dffe32  c0_EPC     (epc_in, clock, resetn, wepc, epc);

// Status 输入选择: mtc0 写 data, 异常入口左移4位, eret 返回右移4位
mux2x32  sta_l1  (sta_l1_a0, data, mtc0, sta_in);
mux2x32  sta_l2  ({4'h0, sta[31:4]}, {sta[27:0], 4'h0}, exc, sta_l1_a0);

// Cause 输入选择: mtc0 写 data, 异常时写硬件生成的 cause
mux2x32  cau_l1  (cause, data, mtc0, cau_in);

// EPC 输入选择: mtc0 写 data, 异常时写 pc, 中断时写 npc
mux2x32  epc_l1  (epc_l1_a0, data, mtc0, epc_in);
mux2x32  epc_l2  (pc, npc, inta, epc_l1_a0);

// PC 最终选择: 00=正常 npc, 01=eret 返回 EPC, 10=异常入口 EXC_BASE
mux4x32  irq_pc  (npc, epc, EXC_BASE, 32'h0, selpc, next_pc);

endmodule
