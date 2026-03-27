`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.02.2026 04:57:17
// Design Name: 
// Module Name: store_unit
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


module store_unit (
    input wire [63:0] alu_result,
    input wire [63:0] rs2_data,
    input wire [1:0] store_type,
    input wire [63:0] mem_read_data,
    output reg [63:0] store_data
);

    wire [2:0] byte_offset = alu_result[2:0];

    always @(*) begin
        case (store_type)
        
            2'b00: begin
                store_data = mem_read_data;
                if(byte_offset[2] == 1'b0)
                    store_data[31:0] = rs2_data[31:0]; //SW
                else
                    store_data[63:32] = rs2_data[31:0];
            end
            
            // ---------- SB ----------
            2'b01: begin
                store_data = mem_read_data;
                case (byte_offset)
                    3'b000: store_data[7:0] = rs2_data[7:0];
                    3'b001: store_data[15:8] = rs2_data[7:0];
                    3'b010: store_data[23:16] = rs2_data[7:0];
                    3'b011: store_data[31:24] = rs2_data[7:0];
                    3'b100: store_data[39:32] = rs2_data[7:0];
                    3'b101: store_data[47:40] = rs2_data[7:0];
                    3'b110: store_data[55:48] = rs2_data[7:0];
                    3'b111: store_data[63:56] = rs2_data[7:0];
                endcase
            end

            // ---------- SH ----------
            2'b10: begin
                store_data = mem_read_data;
                if (byte_offset[2:1] == 2'b00)
                    store_data[15:0] = rs2_data[15:0];
                else if (byte_offset[2:1] == 2'b01)
                    store_data[31:16] = rs2_data[15:0];
                else if (byte_offset[2:1] == 2'b10)
                    store_data[47:32] = rs2_data[15:0];
                else 
                    store_data[63:48] = rs2_data[15:0];
            end

            2'b11: store_data = rs2_data; //store double

            default: store_data = rs2_data;
        endcase
    end
endmodule



