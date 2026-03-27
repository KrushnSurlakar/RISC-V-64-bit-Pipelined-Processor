`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.03.2026 17:05:08
// Design Name: 
// Module Name: memory_cycle
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


module memory_cycle(
    input clk,
    input rst,
    input RegWriteM,
    input jumpM,
    input jalrM,
    input MemReadM,
    input MemWriteM,
    input [2:0]load_typeM,
    input [1:0]store_typeM,
    input [63:0]AluResultM,
    input [63:0]WriteDataM,
    input [4:0]RdM,
    input [63:0]PCPlus4M,
    output RegWriteW,
    output jumpW,
    output jalrW,
    output MemReadW,
    output [2:0]load_typeW,
    output [63:0]AluResultW,
    output [63:0]ReadDataW,
    output [4:0]RdW,
    output [63:0]PCPlus4W
    );
    
    wire [63:0] mem_data;
    wire [63:0] store_data;
    
       store_unit SUM (
        AluResultM,
        WriteDataM,
        store_typeM,
        mem_data,
        store_data
    );
    
    Data_mem DMEMM (
        .clk(clk),
        .mem_read(MemReadM),
        .mem_write(MemWriteM),
        .addr(AluResultM),
        .write_data(store_data),
        .read_data(mem_data)
    );
    
       // 1-bit control
    D_FF #(1) RegWriteW_reg   (clk, rst, RegWriteM,   RegWriteW);
    D_FF #(1) jumpW_reg       (clk, rst, jumpM,       jumpW);
    D_FF #(1) jalrW_reg       (clk, rst, jalrM,       jalrW);
    D_FF #(1) MemReadW_reg    (clk, rst, MemReadM,    MemReadW);
    
    // multi-bit control
    D_FF #(3) load_typeW_reg  (clk, rst, load_typeM,  load_typeW);
    
    // datapath
    D_FF #(64) AluResultW_reg (clk, rst, AluResultM,  AluResultW);
    D_FF #(64) ReadDataW_reg  (clk, rst, mem_data,    ReadDataW);
    D_FF #(64) PCPlus4W_reg   (clk, rst, PCPlus4M,    PCPlus4W);
    
    // register index (CRITICAL)
    D_FF #(5) RdW_reg         (clk, rst, RdM,         RdW);
    
endmodule
