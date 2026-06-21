`default_nettype none

module DE1_SOC_golden_top(
      input              CLOCK_50,
      output      [6:0]  HEX0,
      output      [6:0]  HEX1,
      output      [6:0]  HEX2,
      output      [6:0]  HEX3,
      output      [6:0]  HEX4,
      output      [6:0]  HEX5,
      input       [3:0]  KEY,
      output      [9:0]  LEDR,
      input       [9:0]  SW
);

wire clk_10MHz;
pll_cpu pll_cpu_inst(
    .refclk(CLOCK_50),   
    .rst(1'b0),      
    .outclk_0(clk_10MHz), 
    .locked()    
);

// ===== CPU内部信号 =====
wire [31:0] inst, pc, aluout, memout, data;
wire        wmem;
wire [5:0]  opcode = inst[31:26];
wire [5:0]  func   = inst[5:0];

// ============================================================
// ★★★ SignalTap 调试信号（在内部信号声明之后引用，便于阅读） ★★★
// ============================================================
wire [31:0] debug_pc /* synthesis keep */ = pc;
wire [31:0] debug_inst /* synthesis keep */ = inst;
wire [31:0] debug_aluout /* synthesis keep */ = aluout;
wire [31:0] debug_memout /* synthesis keep */ = memout;
wire [5:0]  debug_opcode /* synthesis keep */ = opcode;
wire [5:0]  debug_func /* synthesis keep */ = func;
wire        debug_wmem /* synthesis keep */ = wmem;

// ===== 慢速时钟分频（约1Hz） =====
reg [31:0] clk_div;
wire slow_clk;

always @(posedge clk_10MHz or negedge KEY[0]) begin
    if (!KEY[0])
        clk_div <= 0;
    else
        clk_div <= clk_div + 1;
end

// SW[3]=0: 快速(10MHz), SW[3]=1: 慢速(约1Hz)
assign slow_clk = clk_div[24];

// ===== CPU时钟选择 =====
wire cpu_clk = (SW[3] == 1'b0) ? clk_10MHz : slow_clk;

// ===== CPU实例化（完全不变） =====
sccpu_dataflow cpu (
    .clock(cpu_clk),
    .resetn(KEY[0]),
    .inst(inst),
    .mem(memout),
    .pc(pc),
    .wmem(wmem),
    .alu(aluout),
    .data(data)
);

scinstmem imem (.a(pc), .inst(inst));
scdatamem dmem (.clk(clk_10MHz), .dataout(memout), .datain(data), 
                .addr(aluout), .we(wmem), .inclk(clk_10MHz), .outclk(clk_10MHz));

// ===== 数码管显示 =====
// SW[1:0] 选择显示内容:
// 00: OPCODE + FUNC (证明指令类型)
// 01: PC (跟踪程序执行)
// 10: 完整指令码
// 11: ALU输出
wire [31:0] display_data;
assign display_data = (SW[1:0] == 2'b00) ? {20'b0, opcode, func} :
                      (SW[1:0] == 2'b01) ? pc :
                      (SW[1:0] == 2'b10) ? inst :
                      aluout;

hex7 seg0(.din(display_data[3:0]),   .seg(HEX0));
hex7 seg1(.din(display_data[7:4]),   .seg(HEX1));
hex7 seg2(.din(display_data[11:8]),  .seg(HEX2));
hex7 seg3(.din(display_data[15:12]), .seg(HEX3));
hex7 seg4(.din(display_data[19:16]), .seg(HEX4));
hex7 seg5(.din(display_data[23:20]), .seg(HEX5));

// ===== LED显示 =====
// LED[5:0]: OPCODE
// LED[6]: 保留
// LED[7]: 程序结束标志 (停在0x5C)
// LED[8]: 速度模式 (0=快速, 1=慢速)
// LED[9]: 复位状态
assign LEDR[5:0] = KEY[0] ? opcode : 6'b000000;
assign LEDR[6]   = 1'b0;
assign LEDR[7]   = (pc == 32'h0000005C);
assign LEDR[8]   = SW[3];
assign LEDR[9]   = KEY[0];


endmodule