`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.03.2026 01:10:08
// Design Name: 
// Module Name: fetch_cycle
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


module fetch_cycle(
    input clk,
    input rst,
    input [63:0]PCTargetE,
    input PCSrcE,
    output [31:0]InstrD,
    output [63:0]PCD,
    output [63:0]PCPlus4D,
    input enable,
    input FlushD
    );
    
    wire [63:0]PCF, PCF_;
    wire [63:0]PCPlus4F;
    wire [31:0]InstrF;
    
    assign PCF_ = PCSrcE ? PCTargetE : PCPlus4F;
    
    D_FF_enable #(64) PCF_reg(clk, rst, enable, PCF_, PCF);
    
    Instr_mem IMEMF(PCF, InstrF);
    
    assign PCPlus4F = PCF + 64'd4;
    
    D_FF_enable_Flush #(64) PCD_reg(clk, rst, enable, FlushD, PCF, PCD);
    D_FF_enable_Flush #(32) InstrD_reg(clk, rst, enable, FlushD,  InstrF, InstrD);
    D_FF_enable_Flush #(64) PCPlus4D_reg(clk, rst, enable, FlushD, PCPlus4F, PCPlus4D);
    
endmodule
