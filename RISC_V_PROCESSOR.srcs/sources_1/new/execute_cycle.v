`timescale 1ns / 1ps

module execute_cycle(
    input clk,
    input rst,
    input [31:0]InstrE,
    input RegWriteE,
    input MemReadE,
    input MemWriteE,
    input AluSrcE,
    input [1:0]AluSrc_aE,
    input [3:0]AluCtrlE,
    input branchE,
    input jumpE,
    input jalrE,
    input [2:0]load_typeE,
    input [1:0]store_typeE,
    input [63:0]RD1E,
    input [63:0]RD2E,
    input [63:0]PCE,
    input [4:0]RdE,
    input [63:0]ImmExtE,
    input [63:0]PCPlus4E,
    output [63:0]PCTargetE,
    output PCSrcE,
    output RegWriteM,
    output jumpM,
    output jalrM,
    output MemReadM,
    output MemWriteM,
    output [2:0]load_typeM,
    output [1:0]store_typeM,
    output [63:0]AluResultM,
    output [63:0]WriteDataM,
    output [4:0]RdM,
    output [63:0]PCPlus4M,
    input [1:0]ForwardAE,
    input [1:0]ForwardBE,
    input [63:0]ResultW,
    input [2:0] funct3E,
    input [63:0] AluResultM_forward,
    input UseImmU
    );
    
    wire [63:0] alu_b, alu_a, imm_u, AluResultE;
    reg [63:0] RD1E_mux, RD2E_mux;
    
    always @(*) begin
        case (ForwardAE)
            2'b00: RD1E_mux = RD1E;
            2'b10: RD1E_mux = AluResultM_forward;
            2'b01: RD1E_mux = ResultW;
            default: RD1E_mux = RD1E;
        endcase
    
        case (ForwardBE)
            2'b00: RD2E_mux = RD2E;
            2'b10: RD2E_mux = AluResultM_forward;
            2'b01: RD2E_mux = ResultW;
            default: RD2E_mux = RD2E;
        endcase
    end
    
    wire signed [63:0] sA = RD1E_mux;
    wire signed [63:0] sB = RD2E_mux;
    
    wire eq  = (RD1E_mux == RD2E_mux);
    wire ne  = (RD1E_mux != RD2E_mux);
    wire lt  = (sA < sB);           // signed
    wire ge  = (sA >= sB);          // signed
    wire ltu = (RD1E_mux < RD2E_mux); // unsigned
    wire geu = (RD1E_mux >= RD2E_mux);
    
    reg branch_takenE;

    always @(*) begin
        case (funct3E)
            3'b000: branch_takenE = eq;   // BEQ
            3'b001: branch_takenE = ne;   // BNE
            3'b100: branch_takenE = lt;   // BLT
            3'b101: branch_takenE = ge;   // BGE
            3'b110: branch_takenE = ltu;  // BLTU
            3'b111: branch_takenE = geu;  // BGEU
            default: branch_takenE = 0;
        endcase
    end
    
   assign imm_u = {{32{InstrE[31]}},InstrE[31:12],12'b0};
   
   assign alu_a = (AluSrc_aE == 2'b01) ? 64'b0 : ( (AluSrc_aE == 2'b10) ? PCE : RD1E_mux );
   assign alu_b = (UseImmU) ? imm_u : (AluSrcE) ? ImmExtE : RD2E_mux;

    ALU aluE(
        alu_a,
        alu_b,
        AluCtrlE,
        AluResultE
    );
    
    assign PCSrcE = jalrE || jumpE || (branch_takenE && branchE);
    assign PCTargetE = jalrE ? ((RD1E_mux + ImmExtE)& ~64'b1) : (PCE + ImmExtE);
                         //AND with 32'b so as to avoid odd pc
        // 1-bit control signals
    D_FF #(1) RegWriteM_reg   (clk, rst, RegWriteE,   RegWriteM);
    D_FF #(1) jumpM_reg       (clk, rst, jumpE,       jumpM);
    D_FF #(1) jalrM_reg       (clk, rst, jalrE,       jalrM);
    D_FF #(1) MemReadM_reg    (clk, rst, MemReadE,    MemReadM);
    D_FF #(1) MemWriteM_reg   (clk, rst, MemWriteE,   MemWriteM);
    
    // multi-bit control
    D_FF #(3) load_typeM_reg  (clk, rst, load_typeE,  load_typeM);
    D_FF #(2) store_typeM_reg (clk, rst, store_typeE, store_typeM);
    
    // datapath (32-bit)
    D_FF #(64) AluResultM_reg (clk, rst, AluResultE,  AluResultM);
    D_FF #(64) WriteDataMreg  (clk, rst, RD2E_mux,        WriteDataM);
    D_FF #(64) PCPlus4M_reg   (clk, rst, PCPlus4E,    PCPlus4M);
    
    // register index (CRITICAL)
    D_FF #(5) RdM_reg         (clk, rst, RdE,         RdM);
     
endmodule
