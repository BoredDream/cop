module pipeemreg (ewreg,em2reg,ewmem,ealu,eb,ern,clk,clrn,mwreg,mm2reg,
                  mwmem,malu,mb,mrn);        // EXE/MEM流水线寄存器
    input         clk, clrn;                 // 时钟和复位信号
    input  [31:0] ealu;                      // EXE阶段的ALU控制信号
    input  [31:0] eb;                        // EXE阶段的b信号
    input   [4:0] ern;                       // EXE阶段的寄存器编号
    input         ewreg,em2reg,ewmem;        // EXE阶段的控制信号
    output [31:0] malu;                      // MEM阶段的ALU控制信号
    output [31:0] mb;                        // MEM阶段的b信号
    output  [4:0] mrn;                       // MEM阶段的寄存器编号
    output        mwreg,mm2reg,mwmem;        // MEM阶段的控制信号
    reg    [31:0] malu,mb;
    reg     [4:0] mrn;
    reg           mwreg,mm2reg,mwmem;
    always @(negedge clrn or posedge clk)
        if (!clrn) begin                     // 异步复位
            mwreg  <= 0;              mm2reg <= 0;
            mwmem  <= 0;              malu   <= 0;
            mb     <= 0;              mrn    <= 0;
        end else begin                       // 时钟上升沿寄存信号
            mwreg  <= ewreg;          mm2reg <= em2reg;
            mwmem  <= ewmem;          malu   <= ealu;
            mb     <= eb;             mrn    <= ern;
        end
endmodule