`timescale 1ns/1ps

module tb_intr;
    reg clock, resetn, intr;
    wire [31:0] inst, pc, aluout, memout, data;
    wire wmem, inta;

    sccpu_dataflow cpu (
        .clock(clock),
        .resetn(resetn),
        .inst(inst),
        .mem(memout),
        .pc(pc),
        .wmem(wmem),
        .alu(aluout),
        .data(data),
        .intr(intr),
        .inta(inta)
    );

    scinstmem imem (.a(pc), .inst(inst));
    scdatamem dmem (.clk(clock), .dataout(memout), .datain(data),
                    .addr(aluout), .we(wmem), .inclk(clock), .outclk(clock));

    initial begin
        clock = 0;
        forever #5 clock = ~clock; // 100MHz for simulation
    end

    initial begin
        $dumpfile("tb_intr.vcd");
        $dumpvars(0, tb_intr);

        intr = 0;
        resetn = 0;
        #20;
        resetn = 1;

        // 运行到进入外部中断循环后,再触发外部中断
        // 外部中断测试代码在 PC=0x9c 开始,loop 在 0xa8
        #600;
        intr = 1; // 触发外部中断
        #20;
        intr = 0;

        #400;
        $finish;
    end

    // 打印 PC 变化,便于对照教材图6.12-6.19
    initial begin
        $monitor("time=%0t pc=%h inst=%h aluout=%h inta=%b", $time, pc, inst, aluout, inta);
    end
endmodule
