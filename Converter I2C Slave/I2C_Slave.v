`timescale 1ns / 1ps

//Author: Niculescu Vlad
//Copyright (C)2017
//Licensed under CERN OHL v1.2

module I2C_Slave(
    input clock,              
    input SDA_i,
    input SCL_i,
    output reg SDA_t,
    output reg SCL_t,
    output reg SDA_o = 0,
    output reg SCL_o = 0,
    output reg [2:0] state = 0
    );

parameter I2C_ADR = 7'h30;
parameter
    WAIT_S = 0,
    READ_DEV_S = 1,
    READ_REG_S = 2,
    READ_DATA_S = 3,
    WRITE_DATA_S = 4,
    STOP_S = 5;     

reg [7:0] I2C_registers [0:255]; 
reg SCL_prev;
reg [3:0] index_v = 0;
reg [6:0] addr_d;
reg [7:0] addr_r;
reg rw;
reg ack;
reg state_s;
reg stop = 0;

always @(posedge clock) begin
    SCL_prev <= SCL_i;
    if (stop)
        state <= WAIT_S;
    else begin
        case(state)
            WAIT_S : begin
                SDA_t <= 1;
                SCL_t <= 1;
                if (SDA_i == 0 && SCL_i == 1)
                    state <= READ_DEV_S;
            end
            
            READ_DEV_S : begin
                if (SCL_prev == 0 && SCL_i == 1) begin
                    if (index_v < 7) begin
                        addr_d[6 - index_v] <= SDA_i;
                        index_v <= index_v + 1;
                    end
                    
                    else if (index_v == 7) begin
                        rw <= SDA_i;
                        index_v <= index_v + 1;
                    end
                    
                    else begin 
                        index_v <= 0;
                        if (addr_d == I2C_ADR)
                            ack <= 1;
                        else begin
                            SDA_t <= 1;
                            state <= WAIT_S;
                        end
                    end                                                               
                end
                
                if (SCL_prev == 1 && SCL_i == 0 && ack) begin
                    SDA_t <= 0;
                    index_v <= index_v + 1;
                    if (index_v == 1) begin
                        SDA_t <= 1;
                        state <= READ_REG_S;
                        index_v <= 0;
                        ack <= 0;
                    end
                end
            end
            
            READ_REG_S : begin
                if (SCL_prev == 0 && SCL_i == 1) begin
                    if (index_v < 8) begin
                        addr_r[7 - index_v] <= SDA_i;
                        index_v <= index_v + 1;
                    end
                    else begin 
                        index_v <= 0;
                        ack <= 1;                    
                    end                                                               
                end
             
                if (SCL_prev == 1 && SCL_i == 0 && ack) begin
                    SDA_t <= 0;
                    if (rw)
                        state <= READ_DATA_S;
                    else
                        index_v <= index_v + 1;
                        
                    if (index_v == 1) begin
                        SDA_t <= 1;
                        index_v <= 0;
                        ack <= 0;
                        state <= WRITE_DATA_S;
                    end
                end
            end
            
            READ_DATA_S : begin
                if (SCL_prev == 1 && SCL_i == 0) begin  
                    if (index_v < 8) begin
                        SDA_t <= I2C_registers[addr_r][7 - index_v];
                        index_v <= index_v + 1;
                    end                              
                    else begin 
                        ack <= 1;
                        index_v <= 0;                   
                    end                                       
                end
                
                if (SCL_prev == 0 && SCL_i == 1 && ack == 1) begin
                    if (SDA_i == 0) 
                        state <= STOP_S;
                    else
                        state <= WAIT_S;
                end
            end
    
            WRITE_DATA_S : begin
                if (SCL_prev == 0 && SCL_i == 1) begin
                    if (index_v < 8) begin
                        I2C_registers[addr_r][7 - index_v] <= SDA_i;
                        index_v <= index_v + 1;
                    end
                    else begin 
                        index_v <= 0;
                        ack <= 1;
                    end                                                               
                end
                
                if (SCL_prev == 1 && SCL_i == 0 && ack) begin
                    SDA_t <= 0;                    
                    if (index_v == 1) begin
                        SDA_t <= 1;
                        index_v <= 0;
                        ack <= 0;
                        state <= WAIT_S;
                    end
                end
            end                
        endcase
    end
end  

always @(posedge clock) begin
    case(state_s)
        0 : begin
            stop <= 0;
            if (SCL_i == 1 && SDA_i == 0) state_s <= 1;
        end
        
        1 : begin
            if (SCL_i == 1 && SDA_i == 1)  begin
                state_s <= 0;
                stop <= 1;
            end
        end
    endcase
end 
endmodule
