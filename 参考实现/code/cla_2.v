module cla_2 (a, b, c_in, g_out, p_out, s);   // 2位超前进位加法器
    input  [1:0] a, b;                        // 输入：2位二进制数 a 和 b
    input        c_in;                        // 输入：进位输入 c_in
    output       g_out, p_out;                // 输出：生成进位 g_out 和传递进位 p_out
    output [1:0] s;                           // 输出：2位二进制和 s
    wire   [1:0] g, p;                        // 内部连线：生成进位 g 和传递进位 p
    wire         c_out;                       // 内部连线：进位输出 c_out
    // add (a,    b,    c,     g,    p,    s); // 生成 g, p, s 的 add 模块实例
    add a0 (a[0], b[0], c_in,  g[0], p[0], s[0]); // 位 0 的加法操作
    add a1 (a[1], b[1], c_out, g[1], p[1], s[1]); // 位 1 的加法操作
    // gp  (g, p, c_in, g_out, p_out, c_out);  // 更高层次的 g, p
    gp gp0 (g, p, c_in, g_out, p_out, c_out); // 更高层次的 g, p 模块实例
endmodule