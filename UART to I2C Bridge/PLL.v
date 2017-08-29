`timescale 1ns / 1ps

//Author: Niculescu Vlad
//Copyright (C)2017
//Licensed under CERN OHL v1.2

module PLL(
    input         in,
    output        out
    );
    
clk_wiz_0 clk_pll(
    .clk_out1(out),
    .clk_in1(in));
endmodule
