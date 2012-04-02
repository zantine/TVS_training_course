//`include "fifo_buggy.v"
`include "fifo.v"

module tb;
   reg        clk;
   reg        clear;
   reg        wr;
   reg [7:0]  data_in;
   reg        rd;

   wire [7:0] data_out;
   wire       data_out_valid;
   wire       empty;
   wire       full;

   integer    i;

   fifo DUV( clk, clear, wr, data_in, rd, data_out, data_out_valid, empty, full);

   always #5  clk = ~clk; // Toggle clock every 5 ticks

   initial
     begin
        $display ("time\t clk\t clear\t wr\t data_in\t rd\t data_out\t do_valid\t empty\t full");
        $monitor ("%g\t %b\t %b\t %b\t %b\t %b\t %b\t %b\t\t %b\t %b",
                  $time, clk, clear, wr, data_in, rd, data_out, data_out_valid, empty, full);
        clk     = 1;
        clear   = 0;
        wr      = 0;
        data_in = 8'b0;
        rd      = 0;
        
// data counter is not incremented because rd and wr in same cycle although rd on empty should be ignored
// in the following cycle, data counter overruns due to wrong decrement and empty is not asserted
          
        #10 @ (negedge clk) wr = 1;
        data_in = 1;
        rd = 1;        
        #10 @ (negedge clk)
        wr = 0;
        rd = 1;
        
        #100 @ (negedge clk)
          $stop;
     end // initial begin

endmodule // tb
