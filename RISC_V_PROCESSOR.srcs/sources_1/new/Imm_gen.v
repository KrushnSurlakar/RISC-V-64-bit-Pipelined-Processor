`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.02.2026 18:41:47
// Design Name: 
// Module Name: Imm_gen
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


module Imm_gen (
    input  wire [31:0] instr,
    input  wire  [1:0] imm_sel,  // 00= I, 01 = S, 10= Branch
    output reg  [63:0] imm
);

    always @(*) begin
        case (imm_sel)

            // I-type (lw)
            2'b00:
                imm = {{52{instr[31]}}, instr[31:20]};

            // S-type (sw)
            2'b01: 
                imm = {{52{instr[31]}}, instr[31:25], instr[11:7]};
                
            // Branch
            2'b10 :
                imm = {{52{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
                
            2'b11 : //Jump
                imm = {{44{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
                
        endcase
    end

endmodule

