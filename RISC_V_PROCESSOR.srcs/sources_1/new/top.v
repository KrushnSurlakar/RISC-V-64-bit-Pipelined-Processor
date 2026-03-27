`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.02.2026 18:41:47
// Design Name: 
// Module Name: top
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


module top(
    input clk,
    input rst
);

// ================= IF =================
wire [31:0] InstrD;
wire [63:0] PCTargetE, PCD, PCPlus4D;
wire PCSrcE, enable, FlushD;
wire [4:0]Rs1D, Rs2D;
assign Rs1D = InstrD[19:15];
assign Rs2D = InstrD[24:20];

// ================= ID =================
wire RegWriteE, MemReadE, MemWriteE, AluSrcE;
wire [1:0] AluSrc_aE;
wire [3:0] AluCtrlE;
wire branchE, jumpE, jalrE;
wire [2:0] load_typeE;
wire [1:0] store_typeE;
wire [63:0] RD1E, RD2E, PCE, ImmExtE, PCPlus4E;
wire [4:0] RdE,Rs1E,Rs2E;
wire [2:0] funct3E;
wire UseImmU, FlushE;

// ================= EX =================
wire RegWriteM, MemReadM, MemWriteM;
wire jumpM, jalrM;
wire [2:0] load_typeM;
wire [1:0] store_typeM;
wire [63:0]AluResultM, WriteDataM, PCPlus4M;
wire [31:0] InstrE;
wire [4:0] RdM;
wire [1:0] ForwardAE, ForwardBE;

// ================= MEM =================
wire RegWriteW, MemReadW;
wire jumpW, jalrW;
wire [2:0] load_typeW;
wire [63:0] AluResultW, ReadDataW, PCPlus4W;
wire [4:0] RdW;

// ================= WB =================
(* dont_touch = "true" *) wire [63:0] ResultW;

// ================= IF =================
fetch_cycle IF(
    clk, rst, PCTargetE, PCSrcE, 
    InstrD, PCD, PCPlus4D, enable, FlushD
);

// ================= ID =================
decode_cycle ID(
    clk, rst,
    InstrD, PCD, PCPlus4D,
    RdW, ResultW, RegWriteW,
    RegWriteE, MemReadE, MemWriteE,
    AluSrcE, AluSrc_aE,
    AluCtrlE,
    branchE, jumpE, jalrE,
    load_typeE, store_typeE, InstrE,
    RD1E, RD2E, PCE, RdE,
    ImmExtE, PCPlus4E, Rs1E, Rs2E, funct3E, UseImmU, FlushE
);

// ================= EX =================
execute_cycle EX(
    clk, rst,
    InstrE,
    RegWriteE, MemReadE, MemWriteE,
    AluSrcE, AluSrc_aE,
    AluCtrlE,
    branchE, jumpE, jalrE,
    load_typeE, store_typeE,
    RD1E, RD2E, PCE, RdE,
    ImmExtE, PCPlus4E,
    PCTargetE, PCSrcE, 
    RegWriteM, jumpM, jalrM,
    MemReadM, MemWriteM,
    load_typeM, store_typeM,
    AluResultM, WriteDataM,
    RdM, PCPlus4M, ForwardAE, ForwardBE, ResultW, funct3E, AluResultM, UseImmU
);

// ================= MEM =================
memory_cycle MEM(
    clk, rst,
    RegWriteM, jumpM, jalrM,
    MemReadM, MemWriteM,
    load_typeM, store_typeM,
    AluResultM, WriteDataM,
    RdM, PCPlus4M,
    RegWriteW, jumpW, jalrW,
    MemReadW, load_typeW,
    AluResultW, ReadDataW,
    RdW, PCPlus4W
);

// ================= WB =================
write_cycle WB(
    clk, rst,
    jumpW, jalrW, MemReadW,
    load_typeW,
    AluResultW,
    ReadDataW,
    PCPlus4W,
    ResultW
);

// Hazard unit calling
hazard_unit HU(
     Rs1E, Rs2E,
     RdM, RdW,
     RegWriteM, RegWriteW, MemReadM, Rs1D, Rs2D, RdE, MemReadE, PCSrcE,
     ForwardAE, ForwardBE, enable, FlushE, FlushD
     );

endmodule

