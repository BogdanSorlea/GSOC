`timescale 1ns / 1ps

//Author: Niculescu Vlad
//Copyright (C)2017
//Licensed under CERN OHL v1.2

module TX(input [7:0] in,
          input clock,
          input en,
          output reg out,
          output reg busy);
          
reg [1:0] state=0;
parameter P=10416;  //prescaler: P = SYSCLK/BaudRate
integer i;
integer bit_pos;
parameter s0=2'b00,
          s1=2'b01,
          s2=2'b10,
          s3=2'b11;
         
always @(posedge clock) begin
    case(state)
        s0:begin  
            out<=1'b1;                  
            busy<=1'b0;  
            i=0;                   
            bit_pos=0;
            if(en==1'b1) begin     
                state<=s1;
                out<=1'b0; 
                i=1;
                busy<=1'b1;
            end
        end
           
        s1:begin    
            if(i==P-1) begin
                state<=s2;
                i=0;
            end
            else 
                i=i+1;
        end
           
        s2:begin
            out<=in[bit_pos];
            if(i==P) 
                if(bit_pos==7) begin
                    state<=s3;
                    i=0;
                end
                else begin 
                    bit_pos=bit_pos+1;
                    i=0;
                end 
            else
                i=i+1;       
            end
           
        s3:begin
            out<=1'b1;
            if(i==P) begin
                state<=s0;
                i=0;
            end
            else 
                i=i+1;
            end      
    endcase
end
endmodule

