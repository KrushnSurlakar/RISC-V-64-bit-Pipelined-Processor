`timescale 1ns / 1ps


module D_FF_flush #(parameter WIDTH = 32) (
    input clk,
    input rst,
    input FlushE,
    input [WIDTH-1:0] D,
    output reg [WIDTH-1:0] Q
);
    always @(posedge clk or posedge rst) begin
            if (rst) Q <= 0;
            else if (FlushE) Q<=0;
            else Q <= D;
    end
endmodule