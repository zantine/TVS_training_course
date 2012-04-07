module the_fifo (clk,
		 clr_fifo,
	         rd_fifo,
	         wr_fifo,
	         data_in,
	         data_out,
		 data_counter,
		 data_out_valid,
		 empty,
		 full);

   parameter fbits = 8;
   parameter pwidth = 2;
   parameter fdepth = (1<<pwidth);  // 8 for 3 bit address :-)

   input clk;
   input clr_fifo;
   input rd_fifo;
   input wr_fifo;
   input [fbits-1:0] data_in;
   output reg [fbits-1:0] data_out;
   output reg [pwidth:0]  data_counter;

   output reg  data_out_valid;
   output      empty;
   output      full;

   reg [pwidth-1:0]     nxt_wr;
   reg [pwidth-1:0]     nxt_rd;
   reg [fbits-1:0]    data_mem [0:fdepth-1];

   assign full  = ((nxt_wr == nxt_rd) && (data_counter == fdepth)); 
   assign empty = ((nxt_wr == nxt_rd) && (data_counter == 0));

   initial
     begin
        data_out = 32'bx;
        data_out_valid = 1'b0;
        nxt_wr = 0;
        nxt_rd = 0;
        data_counter = 0;
     end   

   always @ (posedge clk) // Control of NEXT WRITE POINTER
     begin
        if (clr_fifo)
          begin
             nxt_wr <= 0;
          end
        else
          if (wr_fifo && !full)
            begin
               nxt_wr <= nxt_wr + 1;
            end
     end // always @ (posedge clk)

   always @ (posedge clk) // Control of NEXT READ POINTER
     begin
        if (clr_fifo)
          begin
             nxt_rd <= 0;
          end
        else
          if (rd_fifo && !empty)
            begin
               nxt_rd <= nxt_rd + 1;
            end
     end // always @ (posedge clk)

   always @ (posedge clk) // Control of DATA COUNTER
     begin
        if (clr_fifo)
          begin
             data_counter <= 0;
          end
        else
          begin // !if(clr_fifo)
             if ((rd_fifo && !wr_fifo && !empty) || (rd_fifo && full))
               begin // reading but not writing and not empty OR reading and full (where writing to full is ignored)
                  data_counter <= data_counter - 1;
               end
             if ((wr_fifo && !rd_fifo && !full) || (wr_fifo && empty))
               begin // writing but not reading and not full OR writing and empty (where reading from empty is ignored)
                  data_counter <= data_counter + 1;
               end
           end // else: !if(clr_fifo)        
     end // always @ (posedge clk)

   always @ (posedge clk) // Control of DATA OUT and DATA OUT VALID
     begin
        if (clr_fifo)
          begin
             data_out_valid <= 0;
             data_out <= 32'bx;
          end
        else
          begin // !if(clr_fifo)
             if (rd_fifo && !empty)
               begin
                  data_out_valid <= 1;
                  data_out <= data_mem[nxt_rd];
               end
             else
               begin
                  data_out_valid <= 0;
                  data_out <= data_mem[nxt_rd];
               end
          end // else: !if(clr_fifo)
     end // always @ (posedge clk)
               
   always @ (posedge clk) // Taking DATA IN when writing
     begin
        if (wr_fifo && !full && !clr_fifo)
          begin
             data_mem[nxt_wr] <= data_in;
          end
     end // always @ (posedge clk)

 endmodule // the_fifo