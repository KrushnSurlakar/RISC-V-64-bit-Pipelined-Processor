`timescale 1ns / 1ps
module hazard_unit(
    input [4:0] Rs1E,
    input [4:0] Rs2E,
    input [4:0] RdM,
    input [4:0] RdW,
    input RegWriteM,
    input RegWriteW,
    input MemReadM,
    input [4:0]Rs1D,
    input [4:0]Rs2D,
    input [4:0]RdE,
    input MemReadE,
    input PCSrcE,
    output reg [1:0] ForwardAE,
    output reg [1:0] ForwardBE,
    output reg enable,
    output reg FlushE,
    output reg FlushD
);

always @(*) begin
    ForwardAE = 2'b00;
    ForwardBE = 2'b00;
    enable = 1;
    FlushE = 0;
    FlushD = 0;
    
    // Forward A
    if ((Rs1E == RdM) && RegWriteM && (Rs1E != 0) && (!MemReadM))
        ForwardAE = 2'b10;
    else if ((Rs1E == RdW) && RegWriteW && (Rs1E != 0))
        ForwardAE = 2'b01;

    // Forward B (FIXED)
    if ((Rs2E == RdM) && RegWriteM && (Rs2E != 0) && (!MemReadM))
        ForwardBE = 2'b10;
    else if ((Rs2E == RdW) && RegWriteW && (Rs2E != 0))
        ForwardBE = 2'b01;
        
    //STall  and flush with flush > stall
    if (PCSrcE)
        FlushD = 1;
            
    if ( (MemReadE && (RdE != 0) &&((RdE == Rs1D) || (RdE == Rs2D))) || PCSrcE )
        FlushE = 1;
    
    if (MemReadE && (RdE != 0) &&((RdE == Rs1D) || (RdE == Rs2D))) begin
        enable = 0;
    end
    
end

endmodule