module scdatamem (clk,dataout,datain,addr,we,inclk,outclk);
	input	[31:0]	datain;
	input	[31:0]	addr ;
	input			clk, we, inclk, outclk;
	output	[31:0]	dataout;
	reg [31:0] ram	[0:31];
	assign	dataout	=ram[addr[6:2]];
	always @ (posedge clk) begin
		if (we) ram[addr[6:2]] = datain;
	end
	integer i;
	initial begin
		for (i = 0;i < 32;i = i + 1)
			ram[i] = 0;
		// 教材第6章异常/中断测试数据 (scd_intr.mif)
		// 散转表
		ram[5'h08] = 32'h00000030; // (20) int_entry
		ram[5'h09] = 32'h0000003c; // (24) sys_entry
		ram[5'h0a] = 32'h00000054; // (28) uni_entry
		ram[5'h0b] = 32'h00000068; // (2c) ovf_entry
		// 溢出测试数据
		ram[5'h12] = 32'h00000002; // (48) 2
		ram[5'h13] = 32'h7fffffff; // (4c) max_int
		// 外部中断循环测试数据
		ram[5'h14] = 32'h000000a3; // (50) data[0]
		ram[5'h15] = 32'h00000027; // (54) data[1]
		ram[5'h16] = 32'h00000079; // (58) data[2]
		ram[5'h17] = 32'h00000115; // (5c) data[3]
	end
endmodule
