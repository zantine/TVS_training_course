module fifo ( clk,
              clear,
              wr,
              data_in,
              rd,
              data_out,
              data_out_valid,
              empty,
              full
              );

   parameter DATA_WIDTH = 8;
   parameter PTR_WIDTH  = 3;
   parameter FIFO_DEPTH = (1<<PTR_WIDTH); // 8 for 3 bit addresses :)

   input                   clk;
   input                   clear;
   input                   wr;
   input [DATA_WIDTH-1:0]  data_in;
   input                   rd;

   output [DATA_WIDTH-1:0] data_out;
   output                  data_out_valid;
   output                  empty;
   output                  full;

   wire                    clk;
   wire                    clear;
   wire                    wr;
   wire [DATA_WIDTH-1:0]   data_in;
   wire                    rd;
   
   reg [DATA_WIDTH-1:0]    data_out;
   reg                     data_out_valid;
   wire                    empty;
   wire                    full;
      
   reg [PTR_WIDTH-1:0]     nxt_wr;
   reg [PTR_WIDTH-1:0]     nxt_rd;
   reg [PTR_WIDTH:0]       data_counter;
   reg [DATA_WIDTH-1:0]    data_mem [0:FIFO_DEPTH-1];

   assign full  = ((nxt_wr == nxt_rd) && (data_counter == FIFO_DEPTH)); 
   assign empty = ((nxt_wr == nxt_rd) && (data_counter == 0));

   initial
     begin
        data_out = 8'bx;
        data_out_valid = 1'b0;
        nxt_wr = 0;
        nxt_rd = 0;
        data_counter = 0;
     end   

   always @ (posedge clk) // Control of NEXT WRITE POINTER
     begin
        if (clear)
          begin
             nxt_wr <= 0;
          end
        else
          if (wr && !full)
            begin
               nxt_wr <= nxt_wr + 1;
            end
     end // always @ (posedge clk)

   always @ (posedge clk) // Control of NEXT READ POINTER
     begin
        if (clear)
          begin
             nxt_rd <= 0;
          end
        else
          if (rd && !empty)
            begin
               nxt_rd <= nxt_rd + 1;
            end
     end // always @ (posedge clk)

   always @ (posedge clk) // Control of DATA COUNTER
     begin
        if (clear)
          begin
             data_counter <= 0;
          end
        else
          begin // !if(clear)
             if ((rd && !wr && !empty) || (rd && full))
               begin // reading but not writing and not empty OR reading and full (where writing to full is ignored)
                  data_counter <= data_counter - 1;
               end
             if ((wr && !rd && !full) || (wr && empty))
               begin // writing but not reading and not full OR writing and empty (where reading from empty is ignored)
                  data_counter <= data_counter + 1;
               end
           end // else: !if(clear)        
     end // always @ (posedge clk)

   always @ (posedge clk) // Control of DATA OUT and DATA OUT VALID
     begin
        if (clear)
          begin
             data_out_valid <= 0;
             data_out <= 8'bx;
          end
        else
          begin // !if(clear)
             if (rd && !empty)
               begin
                  data_out_valid <= 1;
                  data_out <= data_mem[nxt_rd];
               end
             else
               begin
                  data_out_valid <= 0;
                  data_out <= 8'bx;
               end
          end // else: !if(clear)
     end // always @ (posedge clk)
               
   always @ (posedge clk) // Taking DATA IN when writing
     begin
        if (wr && !full && !clear)
          begin
             data_mem[nxt_wr] <= data_in;
          end
     end // always @ (posedge clk)

endmodule // fifo
