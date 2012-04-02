//`include "fifo_buggy.v"
`include "fifo.v"

// Read and write when full
// Writing should be ignored when the FIFO is full.
// In the buggy version the counter is not decremented when reading and writing to full because the write on full is not ignored by the logic that controls the data counter. This only propagates to the output when reading is stopped but writing is continued. At that stage the counter is then incremented beyond capacity and as a consequene full does not come on when it should.

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
        // fill the FIFO
        #10 @ (negedge clk)
          wr = 1;
        #100 // keep write asserted (writing when full should be ignored)
          @ (negedge clk)
          rd = 1;
        #10
          @ (negedge clk)
          rd = 0;
        #10
          $stop;
     end


   always @ (negedge clk)
     begin
        for (i=1; i<100; i=i+1) begin #10 data_in = i; end
     end
   

endmodule // tb
