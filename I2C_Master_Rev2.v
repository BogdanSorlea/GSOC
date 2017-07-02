`timescale 1ns / 1ps

module I2C_M(input clock,
             input start,
             input stop,       
             input [7:0] dataW,  //data to write in slave                 
             input SDA_i,
             input SCL_i,
             input RW,
             input go,
             output reg ACK,
             output reg NACK,
             output reg TO = 0,
             output reg SDA_t = 1,
             output reg SCL_t = 1,
             output reg SDA_o,
             output reg SCL_o,
             output reg [7:0] dataR,  //data to read from slave
             output reg busy,
             output reg [2:0] state = 0          
    );

 
parameter WAIT=0,
          WRITE=1,
          READ=2,
          ACK_RECV=3,
          STOP=4;      

reg SCL_prev;
reg SCL_en = 0;
reg [9:0] cntC = 500;
reg [25:0] cntT = 0;
reg stretch = 0;
integer index=0;
integer stopCnt = 0;
always @(posedge clock) begin
    SCL_prev <= SCL_i;
    SDA_o <= 0;
    SCL_o <= 0;
    case(state)
        WAIT: begin
            NACK <= 0;
            ACK <= 0;            
            if(go) begin
                if(start == 1) begin 
                    state <= WRITE;
                    SCL_en <= 1;
                    SDA_t <= 0;
                end
                else if(stop) state <= STOP;
                     else if(RW == 0) state <= WRITE;
                          else state <= READ;                               
            end
        end
        
        WRITE: begin
            if(SCL_prev == 1 && SCL_i == 0) begin  
                if(index < 8) begin
                    SDA_t <= dataW[8 - index];
                    index = index + 1;
                end
                else if(index == 8)  begin
                    SDA_t <= dataW[0];
                    state <= ACK_RECV;
                    index = 0 ;   
                end                       
            end
        end
        
        ACK_RECV:begin   
            if(SCL_prev == 0 && SCL_i == 1) 
                if(SDA_i == 0) ACK <=1;
                else NACK <=1;
        end
        
        READ:begin
            if(SCL_prev == 1 && SCL_i == 0) begin
                if(index < 8) begin
                    dataR[8 - index] <= SDA_i;
                    index = index + 1;
                    end
                    else if(index == 8) begin                
                             index = 9;
                             SDA_t <= 0;                                                  
                         end 
                         else begin 
                                  index = 0;
                                  SDA_t <= 1;
                                  state <= WAIT;
                                  ACK <= 1;
                              end                                                               
            end
        end
        
        STOP:begin
            SCL_en <= 0;
            if(stopCnt == 500) begin 
                SDA_t <= 1;
                stopCnt = 0;
                state <= WAIT;
            end
        end        
    endcase
end

always @(posedge clock) begin
    if(SCL_en) begin
       if(SCL_i == 0) stretch <= 1;
       else stretch <= 0;
       if(cntC == 0) SCL_t <= 0;
       if(cntC >= 500 && cntC < 1000) begin
           SCL_t <= 1;        
       end            
       if(cntC == 1000) cntC <= 0;
       else if (stretch == 0) begin 
                cntC <= cntC + 1;  
                cntT <= 0;
            end
            else cntT <= cntT + 1;     
       if(cntT == 3400000) begin
            TO <= 1;
            state <= WAIT;
       end
       if(TO) TO <= 0;            
    end
    else begin 
        SCL_t <= 1;
        cntC <= 500;
    end
    
end

endmodule

