module pipeidcu (mwreg,mrn,ern,ewreg,em2reg,mm2reg,rsrtequ,func,op,rs,rt,
                 wreg,m2reg,wmem,aluc,regrt,aluimm,fwda,fwdb,nostall,sext,
                 pcsrc,shift,jal); // ID阶段的控制单元
    input   [5:0] op,func;  // 指令中的op和func字段
    input   [4:0] rs,rt;    // 指令中的rs和rt字段
    input   [4:0] ern;      // EXE阶段的目标寄存器号
    input   [4:0] mrn;      // MEM阶段的目标寄存器号
    input         ewreg;    // EXE阶段的寄存器写使能信号
    input         em2reg;   // EXE阶段的内存到寄存器信号
    input         mwreg;    // MEM阶段的寄存器写使能信号
    input         mm2reg;   // MEM阶段的内存到寄存器信号
    input         rsrtequ;  // reg[rs] == reg[rt]信号
    output  [3:0] aluc;     // ALU控制信号
    output  [1:0] pcsrc;    // 下一PC选择信号
    output  [1:0] fwda;     // 前递信号A: 00:qa; 01:exe; 10:mem; 11:mem_mem
    output  [1:0] fwdb;     // 前递信号B: 00:qb; 01:exe; 10:mem; 11:mem_mem
    output        wreg;     // 寄存器写使能信号
    output        m2reg;    // 内存到寄存器信号
    output        wmem;     // 内存写使能信号
    output        aluimm;   // ALU输入B是立即数
    output        shift;    // ID阶段的指令是移位指令
    output        jal;      // ID阶段的指令是JAL
    output        regrt;    // 目标寄存器号是rt
    output        sext;     // 符号扩展
    output        nostall;  // 无停顿（pipepc和pipeir写使能）
    // 指令译码
    wire rtype,i_add,i_sub,i_and,i_or,i_xor,i_sll,i_srl,i_sra,i_jr;
    wire i_addi,i_andi,i_ori,i_xori,i_lw,i_sw,i_beq,i_bne,i_lui,i_j,i_jal;
    and (rtype,~op[5],~op[4],~op[3],~op[2],~op[1],~op[0]);       // R格式指令
    and (i_add,rtype ,func[5],~func[4],~func[3],~func[2],~func[1],~func[0]); // ADD指令
    and (i_sub,rtype, func[5],~func[4],~func[3],~func[2], func[1],~func[0]); // SUB指令
    and (i_and,rtype, func[5],~func[4],~func[3], func[2],~func[1],~func[0]); // AND指令
    and (i_or, rtype, func[5],~func[4],~func[3], func[2],~func[1], func[0]); // OR指令
    and (i_xor,rtype, func[5],~func[4],~func[3], func[2], func[1],~func[0]); // XOR指令
    and (i_sll,rtype,~func[5],~func[4],~func[3],~func[2],~func[1],~func[0]); // SLL指令
    and (i_srl,rtype,~func[5],~func[4],~func[3],~func[2], func[1],~func[0]); // SRL指令
    and (i_sra,rtype,~func[5],~func[4],~func[3],~func[2], func[1], func[0]); // SRA指令
    and (i_jr, rtype,~func[5],~func[4], func[3],~func[2],~func[1],~func[0]); // JR指令
    and (i_addi,~op[5],~op[4], op[3],~op[2],~op[1],~op[0]);      // ADDI指令
    and (i_andi,~op[5],~op[4], op[3], op[2],~op[1],~op[0]);      // ANDI指令
    and (i_ori, ~op[5],~op[4], op[3], op[2],~op[1], op[0]);      // ORI指令
    and (i_xori,~op[5],~op[4], op[3], op[2], op[1],~op[0]);      // XORI指令
    and (i_lw,   op[5],~op[4],~op[3],~op[2], op[1], op[0]);      // LW指令
    and (i_sw,   op[5],~op[4], op[3],~op[2], op[1], op[0]);      // SW指令
    and (i_beq, ~op[5],~op[4],~op[3], op[2],~op[1],~op[0]);      // BEQ指令
    and (i_bne, ~op[5],~op[4],~op[3], op[2],~op[1], op[0]);      // BNE指令
    and (i_lui, ~op[5],~op[4], op[3], op[2], op[1], op[0]);      // LUI指令
    and (i_j,   ~op[5],~op[4],~op[3],~op[2], op[1],~op[0]);      // J指令
    and (i_jal, ~op[5],~op[4],~op[3],~op[2], op[1], op[0]);      // JAL指令
    // 使用rs的指令
    wire i_rs = i_add  | i_sub | i_and  | i_or  | i_xor | i_jr  | i_addi |
                i_andi | i_ori | i_xori | i_lw  | i_sw  | i_beq | i_bne;
    // 使用rt的指令
    wire i_rt = i_add  | i_sub | i_and  | i_or  | i_xor | i_sll | i_srl  |
                i_sra  | i_sw  | i_beq  | i_bne;
    // 因LW指令的数据依赖引起的流水线停顿
    assign nostall = ~(ewreg & em2reg & (ern != 0) & (i_rs & (ern == rs) |
                                                      i_rt & (ern == rt))) ;
    reg [1:0] fwda, fwdb;  // 前递，多路选择器的选择信号
    always @ (ewreg, mwreg, ern, mrn, em2reg, mm2reg, rs, rt) begin
        // ALU输入A的前递控制信号
        fwda = 2'b00;                                 // 默认：无冒险
        if (ewreg & (ern != 0) & (ern == rs) & ~em2reg) begin
            fwda = 2'b01;                             // 选择exe_alu
        end else begin
            if (mwreg & (mrn != 0) & (mrn == rs) & ~mm2reg) begin
                fwda = 2'b10;                         // 选择mem_alu
            end else begin
                if (mwreg & (mrn != 0) & (mrn == rs) & mm2reg) begin
                    fwda = 2'b11;                     // 选择mem_lw
                end 
            end
        end
        // ALU输入B的前递控制信号
        fwdb = 2'b00;                                 // 默认：无冒险
        if (ewreg & (ern != 0) & (ern == rt) & ~em2reg) begin
            fwdb = 2'b01;                             // 选择exe_alu
        end else begin
            if (mwreg & (mrn != 0) & (mrn == rt) & ~mm2reg) begin
                fwdb = 2'b10;                         // 选择mem_alu
            end else begin
                if (mwreg & (mrn != 0) & (mrn == rt) & mm2reg) begin
                    fwdb = 2'b11;                     // 选择mem_lw
                end 
            end
        end
    end
    // 控制信号定义
    assign wreg     =(i_add |i_sub |i_and |i_or  |i_xor |i_sll |i_srl |
                      i_sra |i_addi|i_andi|i_ori |i_xori|i_lw  |i_lui |
                      i_jal)& nostall;       // 防止指令执行两次
    assign regrt    = i_addi|i_andi|i_ori |i_xori|i_lw  |i_lui;
    assign jal      = i_jal;
    assign m2reg    = i_lw;
    assign shift    = i_sll |i_srl |i_sra;
    assign aluimm   = i_addi|i_andi|i_ori |i_xori|i_lw  |i_lui |i_sw;
    assign sext     = i_addi|i_lw  |i_sw  |i_beq |i_bne;
    assign aluc[3]  = i_sra;
    assign aluc[2]  = i_sub |i_or  |i_srl |i_sra |i_ori |i_lui;
    assign aluc[1]  = i_xor |i_sll |i_srl |i_sra |i_xori|i_beq |i_bne|i_lui;
    assign aluc[0]  = i_and |i_or  |i_sll |i_srl |i_sra |i_andi|i_ori;
    assign wmem     = i_sw  & nostall;       // 防止指令执行两次
	 
	 
    assign pcsrc[1] = i_jr  |i_j   |i_jal;
    assign pcsrc[0] = i_beq & rsrtequ | i_bne & ~rsrtequ | i_j | i_jal;
endmodule