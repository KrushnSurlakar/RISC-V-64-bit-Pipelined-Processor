`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.02.2026 04:40:06
// Design Name: 
// Module Name: load_unit
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


module load_unit (
    input  wire [63:0] mem_data,
    input  wire [63:0] alu_result,
    input  wire [2:0]  load_type,
    output reg  [63:0] load_data
);

    wire [2:0] byte_offset = alu_result[2:0]; //To check which part to load

    wire [7:0] load_byte =
    (byte_offset == 3'b000) ? mem_data[7:0]:
    (byte_offset == 3'b001) ? mem_data[15:8]:
    (byte_offset == 3'b010) ? mem_data[23:16]:
    (byte_offset == 3'b011) ? mem_data[31:24]:
    (byte_offset == 3'b100) ? mem_data[39:32]:
    (byte_offset == 3'b101) ? mem_data[47:40]:
    (byte_offset == 3'b110) ? mem_data[55:48]: mem_data[63:56];

    wire [15:0] load_half =
        (byte_offset[2:1] == 2'b00) ? mem_data[15:0] :
        (byte_offset[2:1] == 2'b01) ? mem_data[31:16] :
        (byte_offset[2:1] == 2'b10) ? mem_data[47:32] : mem_data[63:48];
        
    wire [31:0] load_word = 
        (byte_offset[2] == 1'b0) ? mem_data[31:0] : mem_data[63:32];

    always @(*) begin
        case (load_type)
            3'b000: load_data = {{32{load_word[31]}},load_word};    // lw
            3'b001: load_data = {{56{load_byte[7]}}, load_byte};   // lb
            3'b010: load_data = {{48{load_half[15]}}, load_half};  // lh
            3'b011: load_data = {56'b0, load_byte};                // lbu
            3'b100: load_data = {48'b0, load_half};                // lhu
            3'b101: load_data = {32'b0, load_word};                //lwu
            3'b110: load_data = mem_data; //ld
            default: load_data = mem_data;
        endcase
    end
endmodule

