library verilog;
use verilog.vl_types.all;
entity pipelinedcpu_vlg_check_tst is
    port(
        ealu            : in     vl_logic_vector(31 downto 0);
        inst            : in     vl_logic_vector(31 downto 0);
        malu            : in     vl_logic_vector(31 downto 0);
        pc              : in     vl_logic_vector(31 downto 0);
        wdi             : in     vl_logic_vector(31 downto 0);
        sampler_rx      : in     vl_logic
    );
end pipelinedcpu_vlg_check_tst;
