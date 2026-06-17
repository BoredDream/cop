module regfile (rna, rnb, d, wn, we, clk, clrn, qa, qb);  // 32x32寄存器文件
    input  [31:0] d;                                     // 写端口的数据
    input   [4:0] rna;                                   // 读端口A的寄存器编号
    input   [4:0] rnb;                                   // 读端口B的寄存器编号
    input   [4:0] wn;                                    // 写端口的寄存器编号
    input         we;                                    // 写使能信号
    input         clk, clrn;                             // 时钟和复位信号
    output [31:0] qa, qb;                                // 读端口A和B的数据
    reg    [31:0] register [1:31];                       // 31个32位寄存器
    assign qa = (rna == 0)? 0 : register[rna];           // 读端口A的数据输出
    assign qb = (rnb == 0)? 0 : register[rnb];           // 读端口B的数据输出
    integer i;
    always @(posedge clk or negedge clrn)                // 写端口操作
        if (!clrn)
            for (i = 1; i < 32; i = i + 1)
                register[i]  <= 0;                       // 复位时将所有寄存器清零
        else
            if ((wn != 0) && we)                         // 写使能且目标寄存器不为0
                register[wn] <= d;                       // 将数据d写入目标寄存器
endmodule