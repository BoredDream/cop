// ============================================================================
// Copyright (c) 2013 by Terasic Technologies Inc.
// ============================================================================
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// ============================================================================
//           
//  Terasic Technologies Inc
//  9F., No.176, Sec.2, Gongdao 5th Rd, East Dist, Hsinchu City, 30070. Taiwan
//  
//  
//                     web: http://www.terasic.com/  
//                     email: support@terasic.com
//
// ============================================================================
//Date:  Thu Jul 11 11:26:45 2013
// ============================================================================

//`define ENABLE_HPS

module DE1_SOC_golden_top(

      ///////// CLOCK2 /////////
      input              CLOCK2_50,

      ///////// CLOCK3 /////////
      input              CLOCK3_50,

      ///////// CLOCK4 /////////
      input              CLOCK4_50,

      ///////// CLOCK /////////
      input              CLOCK_50,



      ///////// HEX0 /////////
      output      [6:0]  HEX0,

      ///////// HEX1 /////////
      output      [6:0]  HEX1,

      ///////// HEX2 /////////
      output      [6:0]  HEX2,

      ///////// HEX3 /////////
      output      [6:0]  HEX3,

      ///////// HEX4 /////////
      output      [6:0]  HEX4,

      ///////// HEX5 /////////
      output      [6:0]  HEX5,

      ///////// KEY /////////
      input       [3:0]  KEY,

      ///////// LEDR /////////
      output      [9:0]  LEDR,


      ///////// SW /////////
      input       [9:0]  SW
);


//=======================================================
//  REG/WIRE declarations
//=======================================================

reg [31:0] pattern_a;
reg [31:0] pattern_b;


//=======================================================
//  Structural coding
//=======================================================

always @ (posedge CLOCK_50)
begin 
   if(!KEY[0]) 
	  begin  
	    pattern_a <= 32'h000_000a;
		 pattern_b <= 32'h000_000b;
	  end
	else
	  begin
	    if(SW[4]) // enable patten change
		   begin
	       pattern_a <= pattern_a + 32'h1;
		    pattern_b <= pattern_b + 32'h3;
			end
		 else  // patttern keep the same value
		   begin
	       pattern_a <= pattern_a;
		    pattern_b <= pattern_b;
			end
	  end
end
 

alu alu_inst(
 	/*input  [31:0] */    .a(pattern_a),
 	/*input  [31:0] */    .b(pattern_b),
	/*input  [3:0]  */    .aluc(SW[3:0]),
	/*output [31:0] */    .r(),
	/*output        */    .z()
	);





endmodule
