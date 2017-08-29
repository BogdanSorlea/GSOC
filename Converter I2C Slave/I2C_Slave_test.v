`timescale 1ns / 1ps

//Author: Niculescu Vlad
//Copyright (C)2017
//Licensed under CERN OHL v1.2

module I2C_Slave_test(
    input clock,
    inout SDA,
    inout SCL,
    output [7:0] addr_r,
    output test
    );


wire SDA_t;
wire SDA_o;
wire SCL_t;
wire SCL_o;

I2C_Slave Slave(
    .clock(clock),
    .SDA_i(SDA),
    .SDA_t(SDA_t),
    .SDA_o(SDA_o),
    .SCL_i(SCL),
    .SCL_t(SCL_t),
    .SCL_o(SCL_o),
    .addr_r(addr_r),
    .test(test)
    );
  
triBuf t_sda(
    .in(SDA_o),
    .tristate(SDA_t),
    .out(SDA)
    );
  
triBuf t_scl(
    .in(SCL_o),
    .tristate(SCL_t),
    .out(SCL)
    );
endmodule
