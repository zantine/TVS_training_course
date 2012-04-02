library verilog;
use verilog.vl_types.all;
entity fifo is
    generic(
        DATA_WIDTH      : integer := 8;
        PTR_WIDTH       : integer := 3
    );
    port(
        clk             : in     vl_logic;
        clear           : in     vl_logic;
        wr              : in     vl_logic;
        data_in         : in     vl_logic_vector;
        rd              : in     vl_logic;
        data_out        : out    vl_logic_vector;
        data_out_valid  : out    vl_logic;
        empty           : out    vl_logic;
        full            : out    vl_logic
    );
end fifo;
