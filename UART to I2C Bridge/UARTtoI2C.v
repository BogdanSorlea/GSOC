`timescale 1ns / 1ps

//Author: Niculescu Vlad
//Copyright (C)2017
//Licensed under CERN OHL v1.2

module UARTtoI2C(
    input clock,
    output reg [2:0] state = 0,
    output [2:0] state_i2c,    
    output TX,
    input RX,
    output DAC_update,
    output pwm,
    input fb,
    output en,
    
    inout SDA,
    inout SCL           
    );

wire [7:0] data_rx;
wire d_avail;
wire ack;
wire ack_r;
wire nack;
wire TO;
wire SDA_t;
wire SCL_t;
wire SDA_o;
wire SCL_o;
wire [7:0] data_r;
wire busy;
wire TXbusy;
wire SDA_i;
wire SCL_i; 
reg [7:0] command [0:31];
reg [4:0] memCnt = 0;
reg [1:0] byteCnt = 0;
reg [7:0] LSB;
reg start = 0;
reg stop = 0;
reg [7:0] data_w;       
reg rw;
reg [7:0] data_tx;
reg go = 0;
reg goTX = 0;
reg [23:0] buffer_tx;

parameter 
    START_S = 0,
    FILLBUF_S = 1,
    SEND_S = 2,
    WAIT_S = 3;

PWM_Generator gen(
    .clock(clock),
    .fb(fb),
    .pwm(pwm),
    .en(en));
             
RX Receiver(
    .clock(clock),
    .in(RX),
    .out(data_rx),
    .d_avail(d_avail)
);

TX Transmitter(
    .in(data_tx),
    .clock(clock),
    .en(goTX),
    .busy(TXbusy),
    .out(TX)
);            
                 
I2C_M(
    .clock(clock),
    .start(start),
    .stop(stop),
    .data_w(data_w),
    .rw(rw),
    .go(go),
    .ack(ack),
    .ack_r(ack_r),
    .nack(nack),
    .timeout(timeout),
    .data_r(data_r),
    .busy(busy),
    .state(state_i2c),
    .SDA_t(SDA_t),
    .SCL_t(SCL_t),
    .SDA_o(SDA_o),
    .SCL_o(SCL_o),
    .SCL_i(SCL),
    .SDA_i(SDA),
    .DAC_update(DAC_update)
);               
            
triBuf TSDA(
    .tristate(SDA_t),
    .in(SDA_o),
    .out(SDA)
);
            
triBuf TSCL(
    .tristate(SCL_t),
    .in(SCL_o),
    .out(SCL)
);

   
always @(posedge clock) begin
    if (goTX == 1) 
        goTX <= 0;  
        
    if (go == 1)    
        go <= 0;
                                                                
    case(state)
        START_S : begin 
            goTX <= 0;
            memCnt <= 0;
            byteCnt <= 0;
            if (d_avail)
                if (data_rx == 83) 
                    state <= FILLBUF_S;
        end
        
        FILLBUF_S : 
            if (d_avail) begin
                if (data_rx == 115) begin //s
                    memCnt <= 0;
                    command[memCnt] <= data_rx;
                    state <= SEND_S;
                end
                else begin
                    if (byteCnt == 0) begin
                        if (data_rx < 58)
                            LSB <= data_rx - 48;
                        else
                            LSB <= data_rx - 55;
                            
                        byteCnt <= 1;
                    end
                    else if (byteCnt == 1) begin
                        if (data_rx < 58)
                            command[memCnt] <= LSB * 16 + data_rx - 48;
                        else
                            command[memCnt] <= LSB * 16 + data_rx - 55;
                        memCnt <= memCnt + 1;   
                        byteCnt <= byteCnt + 1;       
                    end
                    else begin
                        command[memCnt] <= data_rx;
                        memCnt <= memCnt + 1;
                        byteCnt <= 0;                                                                                   
                    end
                end
            end
        
        SEND_S : begin             
            if (memCnt == 0) begin
                if (command [memCnt + 1] == 87)  // W
                    rw <= 0;
                else 
                    rw <= 1;
                    
                data_w <= command [memCnt];               
                start <= 1;
                stop <= 0;
                if (go == 0) 
                    go <= 1;
                state <= WAIT_S;
            end
            else begin
                if (command[memCnt] == 115 || command[memCnt/2] == 115) begin
                    start <= 0;
                    stop <= 1;
                    if (go == 0) 
                        go <= 1;
                    state <= START_S;
                    data_tx <= 68; //D
                    goTX <= 1;
                end
                else begin
                    start <= 0;
                    stop <= 0;
                    
                    if (command [memCnt + 1] == 87)
                        rw <= 0;
                    else 
                        rw <= 1;
                        
                    data_w <= command[memCnt];
                    if (go == 0) 
                       go <= 1;
                    state <= WAIT_S;
                end
            end
        end 
        
        WAIT_S : begin
            if (ack) begin 
                state <= SEND_S;
                memCnt <= memCnt + 2;
            end
            else if (nack) begin
                state <= START_S;
                data_tx <= 78; //N
                goTX <= 1;
            end
            else if (timeout) begin
                data_tx <= 84; //T
                goTX <= 1;
                state <= START_S;
            end
            else if (ack_r) begin
                state <= SEND_S;
                memCnt <= memCnt + 2;
                data_tx <= data_r; //N
                goTX <= 1;
            end                           
        end              
    endcase  
end        
endmodule
