module the_fifo (clk,
		 clr_fifo,
	         rd_fifo,
	         wr_fifo,
	         data_in,
	         data_out);

   parameter fbits = 8;

   input clk;
   input clr_fifo;
   input rd_fifo;
   input wr_fifo;
   input [fbits-1:0] data_in;
   output reg [fbits-1:0] data_out;

//   reg [fbits-1:0]    fifo_data;
   
   always @ (posedge clk)
     begin
	if (clr_fifo)
	  begin
	     data_out <= 0;
	  end
	else if (wr_fifo)
	  begin
	     data_out <= data_in;
//	     data_out <= fifo_data;
	  end
     end  // always @ (posedge clk)	

 endmodule // the_fifo