module scinstmem (a,inst);
	input [31:0] a;
	output [31:0] inst;
	wire [31:0] rom [0:63];

	// 教材第6章异常/中断测试程序 (sci_intr.mif, 64字)
	assign rom[6'h00] = 32'h0800001d; // (00) reset: j start
	assign rom[6'h01] = 32'h00000000; // (04) nop
	assign rom[6'h02] = 32'h401a6800; // (08) EXC_BASE: mfc0 r26, CO_CAUSE
	assign rom[6'h03] = 32'h335b000c; // (0c) andi r27, r26, 0xc
	assign rom[6'h04] = 32'h8f7b0020; // (10) lw r27, j_table(r27)
	assign rom[6'h05] = 32'h00000000; // (14) nop
	assign rom[6'h06] = 32'h03600008; // (18) jr r27
	assign rom[6'h07] = 32'h00000000; // (1c) nop
	assign rom[6'h08] = 32'h00000000; // (20)
	assign rom[6'h09] = 32'h00000000; // (24)
	assign rom[6'h0a] = 32'h00000000; // (28)
	assign rom[6'h0b] = 32'h00000000; // (2c)
	assign rom[6'h0c] = 32'h00000000; // (30) int_entry: nop
	assign rom[6'h0d] = 32'h42000018; // (34) eret
	assign rom[6'h0e] = 32'h00000000; // (38) nop
	assign rom[6'h0f] = 32'h00000000; // (3c) sys_entry: nop
	assign rom[6'h10] = 32'h401a7000; // (40) epc_plus4: mfc0 r26, CO_EPC
	assign rom[6'h11] = 32'h235a0004; // (44) addi r26, r26, 4
	assign rom[6'h12] = 32'h409a7000; // (48) mtc0 r26, CO_EPC
	assign rom[6'h13] = 32'h42000018; // (4c) eret
	assign rom[6'h14] = 32'h00000000; // (50) nop
	assign rom[6'h15] = 32'h00000000; // (54) uni_entry: nop
	assign rom[6'h16] = 32'h08000010; // (58) j epc_plus4
	assign rom[6'h17] = 32'h00000000; // (5c) nop
	assign rom[6'h18] = 32'h00000000; // (60)
	assign rom[6'h19] = 32'h00000000; // (64)
	assign rom[6'h1a] = 32'h00000000; // (68) ovf_entry: nop
	assign rom[6'h1b] = 32'h08000010; // (6c) j epc_plus4
	assign rom[6'h1c] = 32'h00000000; // (70) nop
	assign rom[6'h1d] = 32'h2008000f; // (74) start: addi r8, r0, 0xf
	assign rom[6'h1e] = 32'h40886000; // (78) mtc0 r8, CO_STATUS
	assign rom[6'h1f] = 32'h8c080048; // (7c) lw r8, 0x48(r0)
	assign rom[6'h20] = 32'h8c09004c; // (80) lw r9, 0x4c(r0)
	assign rom[6'h21] = 32'h01094020; // (84) add r9, r9, r8  ; overflow
	assign rom[6'h22] = 32'h00000000; // (88) nop
	assign rom[6'h23] = 32'h0000000c; // (8c) Sys: syscall
	assign rom[6'h24] = 32'h00000000; // (90) nop
	assign rom[6'h25] = 32'h0128001a; // (94) Unimpl: div r9, r8
	assign rom[6'h26] = 32'h00000000; // (98) nop
	assign rom[6'h27] = 32'h34040050; // (9c) Int: ori r4, r1, 0x50
	assign rom[6'h28] = 32'h20050004; // (a0) addi r5, r0, 4
	assign rom[6'h29] = 32'h00004020; // (a4) add r8, r0, r0
	assign rom[6'h2a] = 32'h8c890000; // (a8) loop: lw r9, 0(r4)
	assign rom[6'h2b] = 32'h20840004; // (ac) addi r4, r4, 4
	assign rom[6'h2c] = 32'h01094020; // (b0) add r8, r8, r9
	assign rom[6'h2d] = 32'h20a5ffff; // (b4) addi r5, r5, -1
	assign rom[6'h2e] = 32'h14a0fffb; // (b8) bne r5, r0, loop
	assign rom[6'h2f] = 32'h00000000; // (bc) nop
	assign rom[6'h30] = 32'h08000030; // (c0) finish: j finish
	assign rom[6'h31] = 32'h00000000; // (c4)
	assign rom[6'h32] = 32'h00000000; // (c8)
	assign rom[6'h33] = 32'h00000000; // (cc)
	assign rom[6'h34] = 32'h00000000; // (d0)
	assign rom[6'h35] = 32'h00000000; // (d4)
	assign rom[6'h36] = 32'h00000000; // (d8)
	assign rom[6'h37] = 32'h00000000; // (dc)
	assign rom[6'h38] = 32'h00000000; // (e0)
	assign rom[6'h39] = 32'h00000000; // (e4)
	assign rom[6'h3a] = 32'h00000000; // (e8)
	assign rom[6'h3b] = 32'h00000000; // (ec)
	assign rom[6'h3c] = 32'h00000000; // (f0)
	assign rom[6'h3d] = 32'h00000000; // (f4)
	assign rom[6'h3e] = 32'h00000000; // (f8)
	assign rom[6'h3f] = 32'h00000000; // (fc)

	assign inst = rom[a[7:2]];
endmodule
