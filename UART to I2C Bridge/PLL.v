`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/15/2017 07:33:06 PM
// Design Name: 
// Module Name: PLL
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


module PLL(
    input         in,
    output        out
    );
    
clk_wiz_0 clk_pll(
    .clk_out1(out),
    .clk_in1(in));
endmodule
