`timescale 1ns / 1ps

//Author: Niculescu Vlad
//Copyright (C)2017
//Licensed under CERN OHL v1.2

module RX(input in,
          input clock,
          output reg [7:0] out,
          output reg d_avail);
          
reg [2:0] state=0;
parameter P=10416;   //prescaler: P = SYSCLK/BaudRate
integer i;
integer bit_pos;
parameter s0=3'b000,
          s1=3'b001,
          s2=3'b010,
          s3=3'b011,
          s4=3'b100;

always @(posedge clock) begin
    case(state)
        s0:begin    
            d_avail<=1'b0;
            i=0;                   
            bit_pos=0;
            if(in==1'b0) begin     
                state<=s1; 
                i=1;
            end
        end
           
        s1:begin    
            if(i==P-1) begin
               state<=s2;
               i=0;
               out <= 0;
            end
            else 
                i=i+1;
            end
           
        s2:begin
            if(i == P) 
                if(bit_pos==7) begin
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
            else 
                i=i+1;
            end
        
        s4:begin
               d_avail<=1'b1;
               state<=s0; 
        end           
    endcase
end
endmodule
