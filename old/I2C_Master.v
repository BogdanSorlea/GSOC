`timescale 1ns / 1ps

module I2C_Master(input clock,
                  input en,
                  input rw,           //read/write r = 1
                  input [6:0] addr,   //device address                  
                  input [7:0] addr2,  //register address
                  input [7:0] dataW,  //data to write in slave                 
                  input SDA_i,
                  input SCL_i,
                  output reg SDA_o,
                  output reg SCL_o,
                  output reg [7:0] dataR,  //data to read from slave
                  output reg busy,
                  output reg [3:0] state          
    );
 parameter P=1000; //SCL = SYSCLK / (2*P)
 reg stateSCL;
 reg SCLmem1=0;
 reg SCLmem2=0;
 reg SCL_negE=0;
 reg SCL_posE=0;
 reg [9:0] divider=0;
 reg SCL_en=0;
 integer index=0;
 integer cnt=0;
 
 parameter s0=0,
           s1=1,
           s2=2,
           s3=3,
           s4=4,
           s5=5,
           s6=6,
           s7=7,
           s8=8,
           s9=9,
           s10=10,              
           s11=11,
           s12=12,
           s13=13,
           s11a=14,
           s14=15;
           
           
always @(posedge clock)
begin
case(state)
   s0:begin  //Wait for start signal
      SDA_o <= 1'b1;
      if(en) begin
             state <= s1;
             busy <= 1;             
             end
      end
       
   s1:begin    
      if(cnt == P/10) begin
                      state <= s2;
                      cnt = 0;
                      SCL_en <= 1;
                      SDA_o <= 0;
                      end
       else cnt <= cnt + 1;
       end
       
   s2:begin  //send Slave Device Address
      if(SCL_negE) begin 
                   if(index < 6) begin
                                 SDA_o <= addr[6 - index];
                                 index = index + 1;
                                 end
                   else if(index == 6) 
                        begin
                        SDA_o <= addr[0];
                        state <= s3;
                        index = 0 ;   
                        end                       
                   end
       end
       
   s3:begin  //Send Read/Write Signal
      if(SCL_negE)     begin 
                       SDA_o <= rw;   
                       state <= s4;                                      
                       end
      end
    
   s4:begin       // Start waiting for ACK from Slave
      if(SCL_negE) begin
                   SDA_o <= 1'bz;
                   state <= s5;
                   end
      end
       
   s5:begin    //Check if Slave sent ACK   
       if(SCL_posE) if(SDA_i == 0) state <= s6;
       end
       
   s6:begin    //Start  sendind Slave register address
      if(SCL_negE) begin 
                           if(index < 7) begin
                                         SDA_o <= addr2[7 - index];
                                         index = index + 1;
                                         end
                           else if(index == 7)
                                begin
                                SDA_o <= addr2[0];
                                state <= s7;
                                index = 0;
                                end
                     end
      end
       
   s7:begin           //put the SDA in hi-Z and waiting for ACK from Slave
      if(SCL_negE)    begin
                      SDA_o <= 1'bz;
                      state <= s8;
                      end
      end
        
   s8:begin          //if ACK received
      if(SCL_posE) 
           if(SDA_i==0)
           begin
           if(rw) state <= s9;  //READ
           else   state <= s11;  //WRITE
           end
       end
       
   s9:begin  //Read byte from Slave
      if(SCL_posE) begin 
                   if(index < 7) begin
                                 dataR[7 - index] <= SDA_i;
                                 index = index + 1;
                                 end
                   else if(index ==7)
                                  begin
                                  state <= s10;
                                  index = 0 ; 
                                  dataR[0] <= SDA_i;                                  
                                  end                       
                    end
        end 
              
   s10:begin
       if(SCL_negE) begin 
                    SDA_o <= 0;  
                    state <= s12;
                    end
       end 
                   
   s11:begin  //Write byte to slave
       if(SCL_negE) begin 
                    if(index < 7) begin
                                  SDA_o <= dataW[7 - index];
                                  index = index + 1;
                                  end
                    else if( index == 7) begin                                         
                                         SDA_o <= dataW[0];
                                         state <= s11a;
                                         index = 0;                                  
                                         end                       
                     end 
       end   
           
   s11a:begin       // Start waiting for ACK from Slave
      if(SCL_negE) begin
                   SDA_o <= 1'bz;
                   state <= s12;
                   end
      end
   
        
   s12:begin
       if(SCL_posE) if(SDA_i==0) begin
                                 state <= s13;                                                                  
                                 end
       end  
       
    s13:begin
        if(SCL_negE) begin
                     state <= s0;
                     cnt <= 0; 
                     SCL_en <= 0;                    
                     end
               
        end
        
     
    endcase        
    end   



always @(posedge clock)
begin
if(SCL_en) 
    begin
            if (divider == P/2) SCL_o <= 1'bz;
            if(divider == P) begin
                             SCL_o <= 0;           
                             divider <= 0;
                             end
             else divider <= divider + 1;       
    end
else SCL_o <= 1'bz;
end

always @(posedge clock)
begin
case(stateSCL)
    0:begin
      stateSCL <= 1;
      SCLmem1 <= SCL_i;
      if(SCLmem2==1 & SCL_i==0) SCL_negE <= 1;
      else SCL_negE <= 0;
      
      if(SCLmem2==0 & SCL_i==1) SCL_posE <= 1;
      else SCL_posE <= 0;
      
      end
    1:begin
      stateSCL <= 0;
      SCLmem2 <= SCL_i;
      if(SCLmem1==1 & SCL_i==0) SCL_negE <= 1;
      else SCL_negE <= 0;
      
      if(SCLmem1==0 & SCL_i==1) SCL_posE <= 1;
      else SCL_posE <= 0;
      
      end
endcase
end

endmodule



