`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.03.2026 17:45:52
// Design Name: 
// Module Name: write_cycle
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



module write_cycle(
    input clk,
    input rst,
    input jumpW,
    input jalrW,
    input MemReadW,
    input [2:0]load_typeW,
    input [63:0]AluResultW,
    input [63:0]ReadDataW,
    input [63:0]PCPlus4W,
    output [63:0]ResultW
);
    
    wire [63:0]load_data;
    
    load_unit LUM (
        ReadDataW,
        AluResultW,
        load_typeW,
        load_data
    );
    
    assign ResultW = (jumpW||jalrW)? (PCPlus4W) : (MemReadW ? load_data : AluResultW) ;
    
    
endmodule
