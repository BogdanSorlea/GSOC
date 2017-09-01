`timescale 1ns / 1ps

//Author: Niculescu Vlad
//Copyright (C)2017
//Licensed under CERN OHL v1.2

module PWM_Generator(
    input clock,
    input fb,
    output reg pwm,
    output reg en,
    input [15:0] clock_step,
    input [15:0] fb_interval
    );
    
reg [5:0] duty = 30; 
reg [5:0] ramp = 0;
reg [5:0] ramp_prev;
reg [16:0] clock_cnt = 0;
wire clock2;
reg clock_fr;
reg [16:0] decimal = 65000;
wire fb_out;

Filter f(
    .clock(clock),
    .comp_out(fb),
    .comp_out_f(fb_out));
    
always @(posedge clock) begin
    clock_fr <= clock_cnt[16];
    clock_cnt <= clock_cnt + clock_step;
end
          
always @(posedge clock_fr) begin
    en <= 1;
    ramp <= ramp + 1;
    
    if (ramp <= duty) 
        pwm <= 1;
    else 
        pwm <= 0;       
end
    
always @(posedge clock) begin 
    ramp_prev <= ramp;
            
    if (ramp == 0 && ramp_prev == 63) begin 
        if (fb) begin
            if (decimal == 65000 - fb_interval) begin
                decimal <= 65000;
                if (duty > 0)
                    duty <= duty - 1;
            end
            else 
                decimal <= decimal - 1;
        end
        else begin
            if (decimal == 65000 + fb_interval) begin
                decimal <= 65000;
                if (duty < 63) 
                    duty <= duty + 1;
            end
            else 
                decimal <= decimal + 1;  
        end 
    end
end
endmodule
