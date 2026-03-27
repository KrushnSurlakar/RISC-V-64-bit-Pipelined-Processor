`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.02.2026 18:41:47
// Design Name: 
// Module Name: Data_mem
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


module Data_mem (
    input  wire  clk,
    input  wire  mem_read,
    input  wire  mem_write,
    input  wire [63:0] addr,
    input  wire [63:0] write_data,
    output reg  [63:0] read_data
    
);

    reg [63:0] memory [0:255];  // 1 KB data memory

    always @(posedge clk) begin
        if (mem_write)
            memory[addr[63:3]] <= write_data;
    end

    always @(*) begin
            read_data = memory[addr[63:3]]; 
    end

endmodule

