`timescale 1ns / 1ps

module I2C_M (
    input clock,
    input [7:0] data_w,		//data to write to slave
    input start,
    input stop,
    input rw,
    input go,
    output reg [7:0] data_r,	//data to read from slave
    output reg ack,
    output reg nack,
    output reg timeout,
    output reg busy,

    input SDA_i,
    input SCL_i,
    output reg SDA_t,
    output reg SCL_t,
    output reg SDA_o,
    output reg SCL_o,

    output reg [2:0] state
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

integer index_v = 0;
integer stop_cnt_v = 0;

always @(posedge clock) begin
    SCL_prev <= SCL_i;
    SDA_o <= 0;
    SCL_o <= 0;
    
    case(state)
        WAIT_S : begin
            nack <= 0;
            ack <= 0;                 
                 
            if (go) begin
                if (start == 1) begin 
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
        end
        
        WRITE_S : begin
            if (SCL_prev == 1 && SCL_i == 0) begin  
                if (index_v < 8) begin
                    SDA_t <= data_w[8 - index_v];
                    index_v = index_v + 1;
                end
                
                else if (index_v == 8)  begin
                    SDA_t <= data_w[0];
                    state <= ACK_RECV_S;
                    index_v = 0 ;   
                end                       
            end
        end
        
        ACK_RECV_S : begin   
            if (SCL_prev == 0 && SCL_i == 1) begin 
                if (SDA_i == 0) 
                    ack <=1;
                else 
                    nack <=1;
            end
        end
        
        READ_S : begin
            if (SCL_prev == 1 && SCL_i == 0) begin
                if (index_v < 8) begin
                    data_r[8 - index_v] <= SDA_i;
                    index_v = index_v + 1;
                end
                else if (index_v == 8) begin                
                    index_v = 9;
                    SDA_t <= 0;                                                  
                end 
                else begin 
                    index_v = 0;
                    SDA_t <= 1;
                    state <= WAIT_S;
                    ack <= 1;
                end                                                               
            end
        end
        
        STOP_S : begin
            SCL_en <= 0;
            if (stop_cnt_v == 500) begin 
                SDA_t <= 1;
                stop_cnt_v = 0;
                state <= WAIT_S;
            end
        end        
    endcase
end

always @(posedge clock) begin
    if (SCL_en) begin
        if (SCL_i == 0) 
            stretch <= 1;
        else 
            stretch <= 0;
        
        if (cnt_c == 0) 
            SCL_t <= 0;
            
        if (cnt_c >= 500 && cnt_c < 1000) 
            SCL_t <= 1;        
                    
        if (cnt_c == 1000) 
            cnt_c <= 0;
        else if (stretch == 0) begin 
            cnt_c <= cnt_c + 1;  
            cnt_t <= 0;
        end
        else 
            cnt_t <= cnt_t + 1;
             
        if (cnt_t == 3400000) begin
             timeout <= 1;
             state <= WAIT_S;
        end
        
        if (timeout) 
            timeout <= 0;  
                  
     end
     else begin 
         SCL_t <= 1;
         cnt_c <= 500;
     end    
end

endmodule

