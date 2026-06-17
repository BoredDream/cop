library verilog;
use verilog.vl_types.all;
entity pipelinedcpu is
    port(
        clk             : in     vl_logic;
        clrn            : in     vl_logic;
        pc              : out    vl_logic_vector(31 downto 0);
        inst            : out    vl_logic_vector(31 downto 0);
        ealu            : out    vl_logic_vector(31 downto 0);
        malu            : out    vl_logic_vector(31 downto 0);
        wdi             : out    vl_logic_vector(31 downto 0)
    );
end pipelinedcpu;
