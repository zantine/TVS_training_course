library verilog;
use verilog.vl_types.all;
entity the_fifo is
    generic(
        fbits           : integer := 8
    );
    port(
        clk             : in     vl_logic;
        clr_fifo        : in     vl_logic;
        rd_fifo         : in     vl_logic;
        wr_fifo         : in     vl_logic;
        data_in         : in     vl_logic_vector;
        data_out        : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of fbits : constant is 1;
end the_fifo;
