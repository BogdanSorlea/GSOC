`timescale 1ns / 1ps

//Author: Niculescu Vlad
//Copyright (C)2017
//Licensed under CERN OHL v1.2

module I2C_M (
    input clock,            //system clock
    input [7:0] data_w,		//data to write to slave
    input start,            //start the communication
    input stop,             //stop the communication
    input rw,               //read from slave/ write to slave
    input go,               //start current operation
    output reg [7:0] data_r,//data to read from slave
    output reg ack,         //write ack flag
    output reg ack_r,       //read ack flag
    output reg nack,        //not acknowledge - abort
    output reg timeout,     //communication timed out - abort
    output reg busy,        //cummunication in progress

    input SDA_i,
    input SCL_i,
    output reg SDA_t,
    output reg SCL_t = 1,
    output reg SDA_o,
    output reg SCL_o,

    output reg [2:0] state = 0,
    output reg DAC_update = 0
);

 
parameter
    WAIT_S = 0,
    WRITE_S = 1,
    READ_S = 2,
    ACK_RECV_S = 3,
    STOP_S = 4;      
    
reg SCL_prev;
reg SCL_en = 0;
reg [9:0] cnt_c = 500;
reg [25:0] cnt_t = 0;
reg stretch = 0;
reg SDA_up = 0;
reg [3:0] index_v = 0;
integer stop_cnt_v = 0;
reg SCL_up = 0;

always @(posedge clock) begin
    SCL_prev <= SCL_i;
    SDA_o <= 0;
    SCL_o <= 0;
    if (timeout == 1) 
        state <= WAIT_S;
    else 
        case(state)
            WAIT_S : begin
                nack <= 0;
                ack <= 0;
                ack_r <= 0;                               
                if (go) begin
                    if (start) begin 
                        state <= WRITE_S;
                        SCL_en <= 1;
                        SDA_t <= 0;
                    end
                    
                    else if (stop) 
                        state <= STOP_S;
                        
                    else if (rw == 0) 
                        state <= WRITE_S;
                        
                    else 
                        state <= READ_S;                               
                end
                else SDA_t <= 1;
            end
            
            WRITE_S : begin
                if (SCL_prev == 1 && SCL_i == 0) begin  
                    if (index_v < 8) begin
                        SDA_t <= data_w[7 - index_v];
                        index_v <= index_v + 1;
                    end                
                    
                    else begin 
                        state <= ACK_RECV_S;
                        index_v <= 0;
                      //  SDA_t <= 1;                      
                    end                                       
                end
            end
            
            ACK_RECV_S : begin   
                if (SCL_prev == 0 && SCL_i == 1) begin 
                    if (SDA_i == 0) begin
                        ack <= 1;          
                        state <= WAIT_S;
                    end          
                     //  state <= 5;
                    else begin
                        nack <= 1;
                        state <= STOP_S;
                    end                    
                end
            end
            
            READ_S : begin
                if (SCL_prev == 0 && SCL_i == 1) begin
                    if (index_v < 8) begin
                        data_r[7 - index_v] <= SDA_i;
                        index_v <= index_v + 1;
                    end
                    else begin 
                        index_v <= 0;
                        SDA_t <= 1;
                        state <= WAIT_S;
                        ack_r <= 1;
                    end                                                               
                end
            end
            
            STOP_S : begin
                if (SCL_prev == 1 && SCL_i == 0) begin
                    SCL_up <= 1;
                end   
                if (SCL_up == 1) begin
                    if (stop_cnt_v == 500) begin
                        SCL_en <= 0;
                        SDA_t <= 0;
                        SDA_up <= 1;
                        stop_cnt_v = 0;
                        SCL_up <= 0;
                    end
                    else stop_cnt_v = stop_cnt_v + 1;
                end
                             
                if (SDA_up) begin
                    if (stop_cnt_v == 500) begin 
                        SDA_t <= 1;
                        stop_cnt_v = 0;
                        state <= WAIT_S;    
                        SDA_up <= 0;        
                    end
                    else 
                        stop_cnt_v <= stop_cnt_v + 1;
                end
            end 
    
        endcase 
end

always @(posedge clock) begin
    if (SCL_en) begin     
        if (cnt_c < 500) begin
            SCL_t <= 0;
            cnt_c <= cnt_c + 1;
        end
        else if (cnt_c < 1000) begin
            SCL_t <= 1;
            if (SCL_i == 0) begin
                stretch <= 1;
                cnt_t <= cnt_t + 1;
            end
            else begin
                stretch <= 0;
                cnt_t <= 0;
                cnt_c <= cnt_c + 1;
            end                        
        end
        else 
            cnt_c <= 0;                               
       
        if (cnt_t == 3400000) begin
             timeout <= 1;
        end
        
        if (timeout) 
            timeout <= 0;  
                  
     end
     else begin 
         SCL_t <= 1;
         cnt_c <= 500;
         timeout <= 0; 
     end    
end

endmodule

