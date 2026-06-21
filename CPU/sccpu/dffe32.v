module dffe32(d,clk,clrn,en,q);
	input [31:0] d;
	input clk,clrn,en;
	output [31:0] q;
	reg [31:0] q;
	always @ (negedge clrn or posedge clk)
		if (clrn == 0) begin
			q <= 0;
		end else if (en) begin
			q <= d;
		end
endmodule
