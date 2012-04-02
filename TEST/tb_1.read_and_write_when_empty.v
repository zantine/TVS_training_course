//`include "fifo_buggy.v"
`include "fifo.v"

// Read and write when empty
// Reading should be ignored when the FIFO is empty.
// In the buggy version the counter is wrongly decremented.

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
        #10 @ (negedge clk)
        // write and read
        wr = 1; 
        data_in = 1;
        rd = 1; 
        #10 @ (negedge clk) 
        // read only
        wr = 0; rd = 1;
        
        #50 $stop;
     end

endmodule // tb
