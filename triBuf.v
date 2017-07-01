`timescale 1ns / 1ps

module triBuf(input in,
              input tristate,
              output out             
    );    
    
assign out = tristate ? 1'bz : 1'b0;

endmodule
