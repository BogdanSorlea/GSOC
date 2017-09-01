`timescale 1ns / 1ps

//Author: Niculescu Vlad
//Copyright (C)2017
//Licensed under CERN OHL v1.2

module Filter(
    input comp_out,
    input clock,
    output reg comp_out_f);

reg [16:0] cnt0 = 0;
reg [16:0] cnt1 = 0;
reg fb_filtered = 0;
reg [29:0] cnt = 0;
parameter filter_length = 100;

    
always @(posedge clock) begin
    if (cnt == filter_length) begin 
        cnt <= 0;
        cnt1 <= 0;
        cnt0 <= 0;
        comp_out_f <= fb_filtered;
    end
    else
        cnt <= cnt + 1;
    
    if (comp_out) 
        cnt1 <= cnt1 + 1;
    else  
        cnt0 <= cnt0 + 1;
    
    if (cnt1 > cnt0)
        fb_filtered <= 1;
    else
        fb_filtered <= 0;   
end
endmodule
