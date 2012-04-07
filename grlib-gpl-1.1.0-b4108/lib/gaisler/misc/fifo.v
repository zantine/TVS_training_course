module the_fifo (clk,
		 clr_fifo,
	         rd_fifo,
	         wr_fifo,
	         data_in,
	         data_out,
		 data_out_valid,
		 empty,
		 full);

   parameter fbits = 8;
   parameter pwidth = 3;
   parameter fdepth = (1<<pwidth);  // 8 for 3 bit address :-)

   input clk;
   input clr_fifo;
   input rd_fifo;
   input wr_fifo;
   input [fbits-1:0] data_in;
   output reg [fbits-1:0] data_out;

   output reg		  data_out_valid;
   output reg		  empty;
   output reg		  full;

 initial
   begin
     empty = 0;
     full = 1;
  end  
  
   always @ (posedge clk)
     begin
        data_out_valid = !clr_fifo;
	if (clr_fifo)
	  begin
	     data_out <= 0;
	  end
	else if (wr_fifo)
	  begin
	     data_out <= data_in;
	  end
     end  // always @ (posedge clk)	

 endmodule // the_fifo