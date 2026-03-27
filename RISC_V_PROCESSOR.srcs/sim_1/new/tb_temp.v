`timescale 1ns/ 1ps

module tb_temp();

reg clk;
reg reset;

top uut (
    .clk(clk),
    .rst(reset)
);

// Hierarchical references
wire [63:0] WriteData = uut.WriteDataM; 
wire [63:0] DataAdr   = uut.AluResultM; 
wire        MemWrite  = uut.MemWriteM;  
wire [63:0] PC        = uut.PCD;        
wire [63:0] Result    = uut.ResultW;    
wire        FlushE    = uut.FlushE;     
wire        RegWriteW = uut.RegWriteW; // ADDED: To know when the instruction actually finishes

reg [63:0] PCE, PCM, PCW;

always@(posedge clk) begin
    if (reset == 1) begin
        // Start with invalid PCs so it doesn't grade PC=0 during reset
        PCE <= 64'hFFFFFFFF; PCM <= 64'hFFFFFFFF; PCW <= 64'hFFFFFFFF;
    end else begin
        if (FlushE) PCE <= 64'hFFFFFFFF; 
        else        PCE <= PC;   
        PCM <= PCE;
        PCW <= PCM;
    end
end

integer fault_instrs = 0;

// Instruction Addresses
localparam ADDI_1 = 64'h0;
localparam SLLI   = 64'h4;
localparam ADDI_2 = 64'h8;
localparam SD     = 64'hC;
localparam LD     = 64'h10;
localparam LUI    = 64'h14;
localparam ADDI_3 = 64'h18;
localparam ADDI_4 = 64'h1C;
localparam ADDW   = 64'h20;
localparam SUBW   = 64'h24;

always begin
    clk <= 1; #5; clk <= 0; #5;
end

initial begin
    reset = 1;
    #10;
    reset = 0;
    
    #200; 
    $display("-------------------------------------------");
    $display("Test Finished! Faults: %0d", fault_instrs);
    if (fault_instrs == 0) $display("SUCCESS! 64-bit architecture is fully operational!");
    $display("-------------------------------------------");
    $stop;
end

reg [63:0] last_checked_pcm = 64'hFFFFFFFF;
reg [63:0] last_checked_pcw = 64'hFFFFFFFF;

always @(posedge clk) begin
    #1;
    // 1. Check Store (SD) in the Memory stage
    if (PCM == SD && MemWrite && PCM != last_checked_pcm) begin
        if (DataAdr === 104 && WriteData === 64'h0000000F_000000FF) 
            $display("SD  Test Passed! Stored massive 64-bit value: %h", WriteData);
        else begin
            $display("SD  Test FAILED! Addr: %0d, Data: %h", DataAdr, WriteData);
            fault_instrs = fault_instrs + 1;
        end
        last_checked_pcm = PCM;
    end

    // 2. Check ALU and Load instructions in the Writeback stage
    if (RegWriteW && PCW != last_checked_pcw) begin
        case(PCW)
            ADDI_1: if(Result === 64'hF) $display("ADDI Test Passed!"); else begin $display("ADDI FAILED! Got: %h", Result); fault_instrs = fault_instrs + 1; end
            SLLI:   if(Result === 64'h0000000F_00000000) $display("SLLI Test Passed! Shifted past 32 bits!"); else begin $display("SLLI FAILED! Got: %h", Result); fault_instrs = fault_instrs + 1; end
            ADDI_2: if(Result === 64'h0000000F_000000FF) $display("ADDI Test Passed!"); else begin $display("ADDI 2 FAILED! Got: %h", Result); fault_instrs = fault_instrs + 1; end
            LD:     if(Result === 64'h0000000F_000000FF) $display("LD  Test Passed! Fetched all 64 bits!"); else begin $display("LD FAILED! Got: %h", Result); fault_instrs = fault_instrs + 1; end
            
            ADDW: begin
                if(Result === 64'h00000000_7FFFF801) $display("ADDW Test Passed! 32-bit math correct!");
                else begin $display("ADDW FAILED! Got: %h", Result); fault_instrs = fault_instrs + 1; end
            end
            
            SUBW: begin
                if(Result === 64'hFFFFFFFF_FFFFFFFE) $display("SUBW Test Passed! 32-bit negative sign-extended perfectly!");
                else begin $display("SUBW FAILED! Got: %h", Result); fault_instrs = fault_instrs + 1; end
            end
        endcase
        last_checked_pcw = PCW;
    end
end

endmodule