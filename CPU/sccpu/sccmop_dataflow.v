module sccomp_dataflow(clock, resetn, inst, pc, aluout, memout, mem_clk);
input  clock, resetn, mem_clk;
input  [31:0] inst, memout;  // ← 改为 input
output [31:0] pc, aluout;
// 删除 wire [31:0] data; 这一行，因为 data 在顶层声明
wire   wmem;
wire [31:0] data;  // 内部使用

sccpu_dataflow s (clock, resetn, inst, memout, pc, wmem, aluout, data);
scinstmem imem (pc, inst);    // ← 这里会报错，需要移除
scdatamem dmem (clock, memout, data, aluout, wmem, mem_clk, mem_clk); // ← 这里会报错，需要移除

endmodule