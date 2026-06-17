module pipedereg (
    dwreg, dm2reg, dwmem, daluc, daluimm, da, db, dimm, drn, dshift,
    djal, dpc4, clk, clrn, ewreg, em2reg, ewmem, ealuc, ealuimm, ea,
    eb, eimm, ern, eshift, ejal, epc4
); // ID/EXE 流水线寄存器

    input         clk, clrn;                // 时钟和复位
    input  [31:0] da, db;                   // ID阶段的a和b
    input  [31:0] dimm;                     // ID阶段的立即数
    input  [31:0] dpc4;                     // ID阶段的pc+4
    input   [4:0] drn;                      // ID阶段的寄存器号
    input   [3:0] daluc;                    // ID阶段的ALU控制信号
    input         dwreg, dm2reg, dwmem, daluimm, dshift, djal; // ID阶段的控制信号

    output [31:0] ea, eb;                   // EXE阶段的a和b
    output [31:0] eimm;                     // EXE阶段的立即数
    output [31:0] epc4;                     // EXE阶段的pc+4
    output  [4:0] ern;                      // EXE阶段的寄存器号
    output  [3:0] ealuc;                    // EXE阶段的ALU控制信号
    output        ewreg, em2reg, ewmem, ealuimm, eshift, ejal; // EXE阶段的控制信号

    reg    [31:0] ea, eb, eimm, epc4;
    reg     [4:0] ern;
    reg     [3:0] ealuc;
    reg           ewreg, em2reg, ewmem, ealuimm, eshift, ejal;

    // 时钟上升沿或复位信号的下降沿触发
    always @(negedge clrn or posedge clk)
        if (!clrn) begin                    // 清除
            ewreg   <= 0;              em2reg  <= 0;
            ewmem   <= 0;              ealuc   <= 0;
            ealuimm <= 0;              ea      <= 0;
            eb      <= 0;              eimm    <= 0;
            ern     <= 0;              eshift  <= 0;
            ejal    <= 0;              epc4    <= 0;
        end else begin                      // 寄存
            ewreg   <= dwreg;          em2reg  <= dm2reg;
            ewmem   <= dwmem;          ealuc   <= daluc;
            ealuimm <= daluimm;        ea      <= da;
            eb      <= db;             eimm    <= dimm;
            ern     <= drn;            eshift  <= dshift;
            ejal    <= djal;           epc4    <= dpc4;
        end
endmodule