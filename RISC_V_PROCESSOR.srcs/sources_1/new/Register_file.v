`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.02.2026 18:41:47
// Design Name: 
// Module Name: Register_file
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


module Register_file (
    input  wire        clk,
    input wire reset,
    input  wire  reg_write,
    input  wire [4:0]  rs1,
    input  wire [4:0]  rs2,
    input  wire [4:0]  rd,
    input  wire [63:0] wd,
    output wire [63:0] rs1_data,
    output wire [63:0] rs2_data
);

    reg [63:0] regs [0:31];

    assign rs1_data = (rs1 == 0) ? 63'b0 : regs[rs1];
    assign rs2_data = (rs2 == 0) ? 63'b0 : regs[rs2];
    
    integer i;
    always @(negedge clk) begin
    if (reset) begin
        for(i = 0; i < 32; i = i + 1)
            regs[i] <= 0;
    end
    else if (reg_write && rd != 0) begin
        regs[rd] <= wd;
    end
end

endmodule

