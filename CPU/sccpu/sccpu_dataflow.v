module sccpu_dataflow(clock, resetn, inst, mem, pc, wmem, alu, data);
input     [31:0]   inst, mem;
input         clock, resetn;
output   [31:0]  pc, alu, data;
output wmem;

wire  [31:0] p4 , bpc, npc, adr, ra, alua, alub, res, alu_mem;
wire  [3:0] aluc;
wire  [4:0] reg_dest, wn;
wire  [1:0] pcsource;
wire  zero, wmem, wreg, regrt, m2reg, shift, aluimm, jal, sext;

// 移位量sa
wire  [31:0]  sa  =  {27'b0, inst[10:6]};

// 控制单元
sccu_dataflow cu  (inst[31:26] , inst[5:0] , zero, wmem, wreg, regrt, m2reg, aluc, shift, aluimm, pcsource, jal, sext);

// 符号扩展偏移
wire   e  =  sext  &  inst[15];
wire   [15:0]       imm =  {16{e}};
wire  [31:0]       immediate  =  {imm, inst[15:0]};
wire  [31:0]  offset  =  {imm, inst[15:0], 2'b00};

// PC寄存器
dff32  ip  (npc, clock, resetn, pc);
// PC+4
cla32  pcplus4   (pc, 32'h4, 1'b0, p4);
// 分支目标地址
cla32  br_adr     (p4, offset, 1'b0, adr);
// j/jal跳转地址
wire  [31:0]        jpc =  {p4[31:28], inst[25:0], 2'b00};

// ALU输入多路选择
mux2x32  alu_b  (data, immediate, aluimm, alub) ;
mux2x32  alu_a  (ra, sa, shift, alua);

// 写回结果选择
mux2x32  result   (alu, mem, m2reg, alu_mem);
// jal返回地址保存p4
mux2x32  link (alu_mem, p4, jal, res);

// 目标寄存器选择
mux2x5  reg_wn   (inst[15:11], inst[20:16] , regrt, reg_dest);
// 修复jal强制写r31
assign wn = jal ? 5'd31 : reg_dest;

// 下一条PC多路选择
mux4x32  nextpc  (p4, adr, ra, jpc, pcsource, npc);

// 通用寄存器堆
regfile  rf   (inst[25:21] , inst[20:16] , res, wn, wreg, clock, resetn, ra, data);
// ALU运算单元
alu  al_unit   (alua, alub, aluc, alu, zero); 

endmodule