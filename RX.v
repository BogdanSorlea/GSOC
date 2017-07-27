`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/26/2016 02:30:57 PM
// Design Name: 
// Module Name: RX
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module RX(input in,
          input clock,
          output reg [7:0] out,
          output reg d_avail);
          
reg [2:0] state=0;
parameter P=10416;
integer i;
integer bit_pos;
parameter s0=3'b000,
          s1=3'b001,
          s2=3'b010,
          s3=3'b011,
          s4=3'b100;

always @(posedge clock)
begin
case(state)
s0:begin    
   d_avail<=1'b0;
   i=0;                   //init
   bit_pos=0;
   if(in==1'b0) begin     //start bit detected
                state<=s1; 
                i=1;
                end
   end
   
s1:begin    
   if(i==P-1) begin
              state<=s2;
              i=0;
              out<=8'b00000000;
              end
    else i=i+1;
    end
   
s2:begin
   if(i==P) if(bit_pos==7) begin
                           state<=s3;
                           i=0;
                           end
            else begin 
                 bit_pos=bit_pos+1;
                 i=0;
                 end 
    else begin
         if(i==P/2) out[bit_pos]<=in;
         i=i+1;
         end         
   end
   
s3:begin
   if(i==P) begin
              state<=s4;
              i=0;
              end
   else i=i+1;
   end

s4:begin
   d_avail<=1'b1;
   if(i==2) state<=s0;
   else i=i+1;
   end
   
endcase
end
endmodule
