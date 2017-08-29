`timescale 1ns / 1ps

//Author: Niculescu Vlad
//Copyright (C)2017
//Licensed under CERN OHL v1.2

module triBuf(
    input in,
    input tristate,
    output out             
);    
    
assign out = tristate ? 1'bz : in;

endmodule
