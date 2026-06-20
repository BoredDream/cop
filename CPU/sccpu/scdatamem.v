/*module scdatamem (clk,dataout,datain,addr,we,inclk,outclk);
input	[31:0]	datain;
input	[31:0]	addr ;
input		clk, we, inclk, outclk;
output	[31:0]	dataout;
wire    write_enable = we & ~clk;
lpm_ram_dp ram(.data(datain),
	           .address (addr[6:2]),
			.we(write_enable),
			.outclock(outclk),
			.q(dataout));
defparam ram.lpm_width = 32;
defparam ram.lpm_widthad = 5;
defparam ram.lpm_indata = "registered";
defparam ram.lpm_outdata = "registered";
defparam ram.lpm_file = "scdatamem.mif";
defparam ram.lpm_address_control = "registered";
//defparam ram.lpm_rdaddress_control = "registered";
//defparam ram.lpm_wraddress_control = "registered";
endmodule*/

module scdatamem (clk,dataout,datain,addr,we,inclk,outclk);
input	[31:0]	datain;
input	[31:0]	addr ;
input		clk, we, inclk, outclk;
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
	ram[5'h14] = 32'h000000a3;
	ram[5'h15] = 32'h00000027;
	ram[5'h16] = 32'h00000079;
	ram[5'h17] = 32'h00000115;
end
endmodule
   