`timescale 1ns / 1ps

module decode_cycle(
    input clk,
    input rst,
    input [31:0]InstrD,
    input [63:0]PCD,
    input [63:0]PCPlus4D,
    input [4:0]RdW,
    input [63:0]ResultW,
    input RegWriteW,
    output RegWriteE,
    output MemReadE,
    output MemWriteE,
    output AluSrcE,
    output [1:0]AluSrc_aE,
    //output [1:0]imm_selE,
    output [3:0]AluCtrlE,
    output branchE,
    output jumpE,
    output jalrE,
    output [2:0]load_typeE,
    output [1:0]store_typeE,
    output [31:0]InstrE,
    output [63:0]RD1E,
    output [63:0]RD2E,
    output [63:0]PCE,
    output [4:0]RdE,
    output [63:0]ImmExtE,
    output [63:0]PCPlus4E,
    output [4:0]Rs1E,
    output [4:0]Rs2E,
    output [2:0]funct3E,
    output UseImmU,
    input FlushE
    );
    
    wire [6:0] op = InstrD[6:0];
    wire [2:0] funct3 = InstrD[14:12];
    wire [4:0] A1 = InstrD[19:15];
    wire [4:0] A2 = InstrD[24:20];
    wire [4:0] RdD = InstrD[11:7];
    wire [6:0] funct7 = InstrD[31:25];
    
    wire reg_writeD, mem_readD, mem_writeD;
    wire alu_srcD;
    wire [1:0]imm_selD;
    wire [3:0]alu_ctrlD;
    wire [2:0] load_typeD;
    wire [1:0] store_typeD;
    wire [1:0] alu_src_aD;
    wire branchD;
    wire jumpD;
    wire jalrD;
    
    wire [63:0] RD1D;
    wire [63:0] RD2D;

    wire UseImmU_ctrl;
    
    Control_unit CUD (
        op,
        funct3,
        funct7,
        //RD1D,
        //RD2D,
        reg_writeD,
        mem_readD,
        mem_writeD,
        alu_srcD,
        alu_src_aD,
        imm_selD,
        alu_ctrlD,
        branchD,
        jumpD,
        jalrD,
        load_typeD,
        store_typeD,
        UseImmU_ctrl
    );
    
    wire [63:0]ImmExtD;
    
    Imm_gen ImmD (
        InstrD,
        imm_selD,
        ImmExtD
    );

    // ---------------- Register File ----------------
     
     
    Register_file RFD (
        clk,
        rst,
        RegWriteW,
        A1,
        A2,
        RdW,
        ResultW,
        RD1D,
        RD2D
    );
    
    // 32-bit datapath signals
    D_FF_flush #(32) InstrE_reg      (clk, rst, FlushE, InstrD,   InstrE);
    D_FF_flush #(64) RD1E_reg        (clk, rst, FlushE, RD1D,       RD1E);
    D_FF_flush #(64) RD2E_reg        (clk, rst, FlushE, RD2D,       RD2E);
    D_FF_flush #(64) PCE_reg         (clk, rst, FlushE, PCD,        PCE);
    D_FF_flush #(64) ImmExtE_reg     (clk, rst, FlushE, ImmExtD,    ImmExtE);
    D_FF_flush #(64) PCPlus4E_reg    (clk, rst, FlushE, PCPlus4D,   PCPlus4E);
    
    // 1-bit control signals
    D_FF_flush #(1) RegWriteE_reg    (clk, rst, FlushE, reg_writeD,     RegWriteE);
    D_FF_flush #(1) MemReadE_reg     (clk, rst, FlushE, mem_readD,      MemReadE);
    D_FF_flush #(1) MemWriteE_reg    (clk, rst, FlushE, mem_writeD,     MemWriteE);
    D_FF_flush #(1) AluSrcE_reg      (clk, rst, FlushE, alu_srcD,       AluSrcE);
    D_FF_flush #(1) branchE_reg(clk, rst, FlushE, branchD,  branchE);
    D_FF_flush #(1) jumpE_reg        (clk, rst, FlushE, jumpD,          jumpE);
    D_FF_flush #(1) jalrE_reg        (clk, rst, FlushE, jalrD,          jalrE);
    D_FF_flush #(1) UseImmU_reg   (clk, rst, FlushE, UseImmU_ctrl, UseImmU);
    
    // multi-bit control signals
    D_FF_flush #(2) AluSrc_aE_reg    (clk, rst, FlushE, alu_src_aD,     AluSrc_aE);
    D_FF_flush #(4) AluCtrlE_reg     (clk, rst, FlushE, alu_ctrlD,      AluCtrlE);
    D_FF_flush #(3) load_typeE_reg   (clk, rst, FlushE, load_typeD,     load_typeE);
    D_FF_flush #(2) store_typeE_reg  (clk, rst, FlushE, store_typeD,    store_typeE);
    D_FF_flush #(3) funct3E_reg (clk, rst, FlushE, funct3, funct3E);
    
    // register index (CRITICAL)
    D_FF_flush #(5) RdE_reg          (clk, rst, FlushE, RdD,            RdE);
    D_FF_flush #(5) Rs1E_reg          (clk, rst, FlushE,  A1,            Rs1E);
    D_FF_flush #(5) Rs2E_reg          (clk, rst, FlushE, A2,            Rs2E);

endmodule
