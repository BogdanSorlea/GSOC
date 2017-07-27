`timescale 1ns / 1ps

//Author: Niculescu Vlad
//Copyright (C)2017
//Licensed under CERN OHL v1.2


module PWM_Generator(
    input clock,
    input fb,
    output reg pwm,
    output reg en
    );
reg [10:0] duty = 0; 
reg [10:0] ramp = 0;
reg [29:0] cnt = 0;
wire clock_200;

PLL pll(
    .in(clock),
    .out(clock200));
          
always @(posedge clock200) begin
    en <= 1;
    ramp <= ramp + 1;
    
    if (ramp < duty) 
        pwm <= 1;
    else 
        pwm <= 0;      
end
    
always @(posedge clock200) begin
    if(cnt == 10000) begin 
        cnt <=0;
        if(fb) 
            duty <= duty - 1;
        else 
            duty <= duty + 1;
    end
    else
        cnt <= cnt + 1;    
    end
       
endmodule
