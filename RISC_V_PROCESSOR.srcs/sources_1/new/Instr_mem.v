`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.02.2026 18:41:47
// Design Name: 
// Module Name: Instr_mem
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


module Instr_mem (
    input  wire [63:0] addr,
    output wire [31:0] instr
);

    reg [31:0] memory [0:255];  

    initial begin
        $display("Loading instruction memory from RV64.hex");
        $readmemh("rv32i_test1.hex", memory);
    end

    assign instr = memory[addr[31:2]];

endmodule

