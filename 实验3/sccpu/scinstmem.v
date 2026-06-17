/*module scinstmem (a,inst);

	input [31:0] a;
	output [31:0] inst;
	lpm_rom lpm_rom_component (.address (a[6:2]),
				   .q (inst));
	defparam lpm_rom_component.lpm_width = 32,
                 lpm_rom_component.lpm_widthad = 5,
                 lpm_rom_component.lpm_numwords = "unused",
		         lpm_rom_component.lpm_file = "scinstmem.mif",
                 lpm_rom_component.lpm_indata = "unused", 
                 lpm_rom_component.lpm_outdata = "unregistered",
                 lpm_rom_component.lpm_address_control ="unregistered";
            
endmodule*/


module scinstmem (a,inst); 
	input [31:0] a; 
	output [31:0] inst; 
	wire [31:0] rom [0:31];
 	assign  rom[5'h00] = 32'h3c010000; // (00) main: lui r1,0
	assign  rom[5'h01] = 32'h34240050; // (04)      ori r4,r1,80
	assign  rom[5'h02] = 32'h20050004; // (08)      addi r5,r0, 4
	assign  rom[5'h03] = 32'h0c000018; // (0c)call: jal sum
	assign  rom[5'h04] = 32'hac820000; // (10)      sw r2,0(r4)
	assign	rom[5'h05] = 32'h8c890000;	//	(14)		lw	r9,	0(r4)
	assign	rom[5'h06] = 32'h01244022;	//	(18)		sub	r8,	r9.	r4
	assign	rom[5'h07] = 32'h20050003;	//	(lc)		addi	r5,	r0.	3
	assign	rom[5'h08] = 32'h20a5ffff;	//	(20)	loop2:	addi	r5,	r5,	-1
	assign	rom[5'h09] = 32'h34a8ffff;	//	(24)		ori	r8,	r5,	0xffff
	assign	rom[5'h0A] = 32'h39085555;	//	(28)		xori	r8.	r8,	0x5555
	assign	rom[5'h0B] = 32'h2009ffff;	//	(2c)		addi	r9,	rO,	-1
	assign	rom[5'h0C] = 32'h312affff;	//	(30)		andi	rlO,	r9,	0xffff
	assign	rom[5'h0D] = 32'h01493025;	//	(34)		or	r6.	rlO,	r9
	assign	rom[5'h0E] = 32'h01494026;	//	(38)		xor	r8,	rlO,	r9
	assign	rom[5'h0F] = 32'h01463824;	//	(3c)		and	r7,	rlO,	r6
	assign	rom[5'h10] = 32'h10a00001;	//	(40)		beq	r5,	r0,	shift
	assign	rom[5'h11] = 32'h08000008;	//	(44)		j	loop2	
	assign	rom[5'h12] = 32'h2005ffff;	//	(48)	shift:	addi	r5.	r0,	-1
	assign	rom[5'h13] = 32'h000543c0;	//	(4c)		sll	r8.	r5.	15
	assign	rom[5'h14] = 32'h00084400;	//	(50)		sll	r8,	r8,	16
	assign	rom[5'h15] = 32'h00084403;	//	(54)		sra	r8,	r8,	16
	assign	rom[5'h16] = 32'h000843c2;	//	(58)		srl	r8.	r8.	15
	assign	rom[5'h17] = 32'h08000017;	//	(5c)	finish:	j	finish	
	assign	rom[5'h18] = 32'h00004020;	//	(60)	sum:	add	r8,	r0,	r0
	assign	rom[5'h19] = 32'h8c890000;	//	(64)	loop:	lw	r9,	(r4)
	assign	rom[5'h1A] = 32'h20840004;	//	(68)		addi	r4,	r4,	4
	assign	rom[5'h1B] = 32'h01094020;	//	(6c)		add	r8,	r8,	r9
	assign	rom[5'h1C] = 32'h20a5ffff;	//	(70)		addi	r5,	r5,	-1
	assign	rom[5'h1D] = 32'h14a0fffb;	//	(74)		bne	rS,	r0,	loop
	assign	rom[5'h1E] = 32'h00081000;	//	(78)		sll	r2f	r8f	0
	assign	rom[5'h1F] = 32'h03e00008;	//	(7c)		jr	r31		
	assign inst = rom[a[6:2]];

endmodule