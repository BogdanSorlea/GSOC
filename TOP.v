`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////


module TOP( inout SDA,
            inout SCL,
            input trigger,
            input clock,
            output [3:0] state 
            );
reg rw = 1;
reg [6:0] addr = 40;
reg [7:0] addr2 = 54;
reg [7:0] dataW = 120;
wire [7:0] dataR; 
wire busy;
reg [29:0] t;
reg start=0;          
I2C_Master I2C(.clock(clock),
               .en(start),
               .rw(rw),
               .addr(addr),
               .addr2(addr2),
               .dataW(dataW),
               .dataR(dataR),
               .busy(busy),
               .state(state),
               .SDA_o(SDA),
               .SDA_i(SDA),
               .SCL_o(SCL),
               .SCL_i(SCL));
 
 always @(posedge clock)
 begin

         if(trigger)
         begin
                    if(t==100000000) begin 
                                   start <= 1;
                                   t <= 0;
                                   end
                    else begin start <= 0;
                               t <= t + 1;
                         end
          end
          else begin start <= 0;
                     t <= 0;
               end
 end              
               

endmodule
