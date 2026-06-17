module shift (d, sa, right, arith, sh);  // 桶式移位器
    input  [31:0] d;                    // 输入：32位待移位数据
    input   [4:0] sa;                   // 输入：移位量，5位
    input         right;                // 1：右移；0：左移
    input         arith;                // 1：算术移位；0：逻辑移位
    output [31:0] sh;                   // 输出：移位结果
    reg    [31:0] sh;                   // 注册变量：移位结果，将会是组合逻辑
    always @* begin                     // always 块，组合逻辑
        if (!right) begin               // 如果是左移操作
            sh = d << sa;               //    左移 sa 位
        end else if (!arith) begin      // 如果是逻辑右移
            sh = d >> sa;               //    逻辑右移 sa 位
        end else begin                  // 如果是算术右移
            sh = $signed(d) >>> sa;     //    算术右移 sa 位
        end
    end
endmodule