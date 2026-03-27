`timescale 1ns/1ps

module tb_riscv();

// registers to send data
reg clk;
reg reset;

// Initialize Top Module
top uut (
    .clk(clk),
    .rst(reset)
);

// =========================================================
// Hierarchical References to peek inside top.v
// =========================================================
wire [63:0] WriteData = uut.WriteDataM; 
wire [63:0] DataAdr   = uut.AluResultM; 
wire        MemWrite  = uut.MemWriteM;  
wire [63:0] PC        = uut.PCD;        // PC at the Decode stage
wire [63:0] Result    = uut.ResultW;    
wire        FlushE    = uut.FlushE;     // <-- ADDED: Tells TB when an instruction is flushed!
// =========================================================

reg [63:0] PCE, PCM, PCW;

// Pipeline the PC tracking, accounting for pipeline flushes!
always@(posedge clk) begin
    if (reset == 1) begin
        PCE <= 0;
        PCM <= 0;
        PCW <= 0;
    end else begin
        // If the CPU flushes the instruction entering Execute, turn it into a bubble (0) in the TB!
        if (FlushE) 
            PCE <= 64'b0; 
        else 
            PCE <= PC;   
            
        PCM <= PCE;
        PCW <= PCM;
    end
end

integer fault_instrs = 0, i = 0, fw = 0, flag = 0;

// Test the RISC-V processor addresses
localparam ADDI_x0  =   64'h8;
localparam ADDI     =   64'h10;
localparam SLLI     =   64'h14;
localparam SLTI     =   64'h18;
localparam SLTIU    =   64'h1C;
localparam XORI     =   64'h20;
localparam SRLI     =   64'h24;
localparam SRAI     =   64'h28;
localparam ORI      =   64'h2C;
localparam ANDI     =   64'h30;

localparam ADD      =   64'h34;
localparam SUB      =   64'h38;
localparam SLL      =   64'h3C;
localparam SLT      =   64'h40;
localparam SLTU     =   64'h44;
localparam XOR      =   64'h48;
localparam SRL      =   64'h4C;
localparam SRA      =   64'h50;
localparam OR       =   64'h54;
localparam AND      =   64'h58;

localparam LUI      =   64'h5C;
localparam AUIPC    =   64'h60;

localparam SB       =   64'h64;
localparam SH       =   64'h68;
localparam SW       =   64'h6C;

localparam LB       =   64'h70;
localparam LH       =   64'h74;
localparam LW       =   64'h78;
localparam LBU      =   64'h7C;
localparam LHU      =   64'h80;

localparam BLT_IN   =   64'h90;
localparam BLT_OUT  =   64'h9C;

localparam BGE_IN   =   64'hAC;
localparam BGE_OUT  =   64'hB8;

localparam BLTU_IN  =   64'hC8;
localparam BLTU_OUT =   64'hD4;

localparam BGEU_IN  =   64'hE4;
localparam BGEU_OUT =   64'hF0;

localparam BNE_IN   =   64'h100;
localparam BNE_OUT  =   64'h10C;

localparam BEQ_IN   =   64'h11C;
localparam BEQ_OUT  =   64'h128;

localparam JALR     =   64'h134;
localparam JAL      =   64'h138;

// generate clock to sequence tests
always begin
    clk <= 1; # 5; clk <= 0; # 5;
end

initial begin
    reset = 1;
     #10;
    reset = 0;
end

always @(posedge clk) begin
    # 1;
    if(MemWrite && !reset) begin
        if(DataAdr === 100 & WriteData === 25) begin
            $display("Simulation succeeded");
            $stop;
        end
        else if (DataAdr !== 96 && DataAdr !== 33 && DataAdr !== 38 && DataAdr !== 40) begin
            $display("Simulation failed");
            $stop;
        end
    end
end

 always @(posedge clk) begin
     #1;
     case(PCW)
         ADDI_x0 : begin
             i = i + 1'b1;
             if(Result === -3)  $display("1. addi implementation is correct for x0 ");
             else begin
                 $display("1. addi implementation for x0 is incorrect");
                 fault_instrs = fault_instrs + 1'b1;
             end
         end

         ADDI    : begin
             i = i + 1'b1;
             if(Result === 9) $display("2. addi implementation is correct ");
             else begin
                 $display("2. addi implementation is incorrect");
                 fault_instrs = fault_instrs + 1'b1;
             end
         end

         SLLI    : begin
             i = i + 1'b1;
             if(Result === 64) $display("3. slli implementation is correct ");
             else begin
                 $display("3. slli implementation is incorrect");
                 fault_instrs = fault_instrs + 1'b1;
             end
         end

         SLTI    : begin
             i = i + 1'b1;
             if(Result === 0) $display("4. slti implementation is correct ");
             else begin
                 $display("4. slti implementation is incorrect");
                 fault_instrs = fault_instrs + 1'b1;
             end
         end

         SLTIU    : begin
             i = i + 1'b1;
             if(Result === 1) $display("5. sltiu implementation is correct ");
             else begin
                 $display("5. sltiu implementation is incorrect");
                 fault_instrs = fault_instrs + 1'b1;
             end
         end

         XORI    : begin
             i = i + 1'b1;
             if(Result === 2) $display("6. xori implementation is correct ");
             else begin
                 $display("6. xori implementation is incorrect");
                 fault_instrs = fault_instrs + 1'b1;
             end
         end

         SRLI    : begin
             i = i + 1'b1;
             if(Result === 64'h1fffffffffffffff) $display("7. srli implementation is correct ");
             else begin
                 $display("7. srli implementation is incorrect");
                 fault_instrs = fault_instrs + 1'b1;
             end
         end

         SRAI    : begin
             i = i + 1'b1;
             if(Result === -1) $display("8. srai implementation is correct ");
             else begin
                 $display("8. srai implementation is incorrect");
                 fault_instrs = fault_instrs + 1'b1;
             end
         end

         ORI    : begin
             i = i + 1'b1;
             if(Result === -1) $display("9. ori implementation is correct ");
             else begin
                 $display("9. ori implementation is incorrect");
                 fault_instrs = fault_instrs + 1'b1;
             end
         end

         ANDI    : begin
             i = i + 1'b1;
             if(Result === 1) $display("10. andi implementation is correct");
             else begin
                 $display("10. andi implementation is incorrect");
                 fault_instrs = fault_instrs + 1'b1;
             end
         end

         ADD    : begin
             i = i + 1'b1;
             if(Result === 17) $display("11. add implementation is correct ");
             else begin
                 $display("11. add implementation is incorrect");
                 fault_instrs = fault_instrs + 1'b1;
             end
         end

         SUB    : begin
             i = i + 1'b1;
             if(Result === 15) $display("12. sub implementation is correct ");
             else begin
                 $display("12. sub implementation is incorrect");
                 fault_instrs = fault_instrs + 1'b1;
             end
         end

         SLL    : begin
             i = i + 1'b1;
             if(Result === 32) $display("13. sll implementation is correct ");
             else begin
                 $display("13. sll implementation is incorrect");
                 fault_instrs = fault_instrs + 1'b1;
             end
         end

         SLT    : begin
             i = i + 1'b1;
             if(Result === 0) $display("14. slt implementation is correct ");
             else begin
                 $display("14. slt implementation is incorrect");
                 fault_instrs = fault_instrs + 1'b1;
             end
         end

         SLTU    : begin
             i = i + 1'b1;
             if(Result === 1) $display("15. sltu implementation is correct ");
             else begin
                 $display("15. sltu implementation is incorrect");
                 fault_instrs = fault_instrs + 1'b1;
             end
         end

         XOR    : begin
             i = i + 1'b1;
             if(Result === 17) $display("16. xor implementation is correct ");
             else begin
                 $display("16. xor implementation is incorrect");
             end
         end

         SRL    : begin
             i = i + 1'b1;
             if(Result === 8) $display("17. srl implementation is correct ");
             else begin
                 $display("17. srl implementation is incorrect");
                 fault_instrs = fault_instrs + 1'b1;
             end
         end

         SRA    : begin
             i = i + 1'b1;
             if(Result === 8) $display("18. sra implementation is correct ");
             else begin
                 $display("18. sra implementation is incorrect");
                 fault_instrs = fault_instrs + 1'b1;
             end
         end

         OR    : begin
             i = i + 1'b1;
             if(Result === 17) $display("19. or implementation is correct ");
             else begin
                 $display("19. or implementation is incorrect");
                 fault_instrs = fault_instrs + 1'b1;
             end
         end

         AND    : begin
             i = i + 1'b1;
             if(Result === 0) $display("20. and implementation is correct ");
             else begin
                 $display("20. and implementation is incorrect");
                 fault_instrs = fault_instrs + 1'b1;
             end
         end

         LUI    : begin
             i = i + 1'b1;
             if(Result === 64'h0000000002000000) $display("21. lui implementation is correct ");
             else begin
                 $display("21. lui implementation is incorrect");
                 fault_instrs = fault_instrs + 1'b1;
             end
         end

         AUIPC    : begin
             i = i + 1'b1;
             if(Result === 64'h0000000002000060) $display("22. auipc implementation is correct ");
             else begin
                 $display("22. auipc implementation is incorrect");
                 fault_instrs = fault_instrs + 1'b1;
             end
         end

         LB      : begin
             i = i + 1'b1;
             if(DataAdr === 38 & Result === 1 ) $display ("26. lb implementation is correct");
             else begin
                 $display("26. lb implementation is incorrect");
                 fault_instrs = fault_instrs + 1'b1;
             end
         end

         LH      : begin
             i = i + 1'b1;
             if(DataAdr === 40 & Result === -3 ) $display ("27. lh implementation is correct");
             else begin
                 $display("27. lh implementation is incorrect");
                 fault_instrs = fault_instrs + 1'b1;
             end
         end

         LW      : begin
             i = i + 1'b1;
             if(DataAdr === 33 & Result === 16) $display ("28. lw implementation is correct");
             else begin
                 $display("28. lw implementation is incorrect");
                 fault_instrs = fault_instrs + 1'b1;
             end
         end

         LBU      : begin
             i = i + 1'b1;
             if(DataAdr === 38 & Result === 1) $display ("29. lbu implementation is correct");
             else begin
                 $display("29. lbu implementation is incorrect");
                 fault_instrs = fault_instrs + 1'b1;
             end
         end

         LHU     : begin
             i = i + 1'b1;
             if(DataAdr === 0 & Result === 64'h000000000000FFFD) $display ("30. lhu implementation is correct");
             else begin
                 $display("30. lhu implementation is incorrect");
                 fault_instrs = fault_instrs + 1'b1;
             end
         end

         BLT_IN : begin
             if(Result <= 64'hA) $display("31. blt is executing");
             else begin
                 $display("blt struck in loop");
                 flag = 1;
                 $stop;
             end
         end

         BLT_OUT : begin
             i = i + 1'b1;
             if(Result === 5) $display("31. blt implementation is correct ");
             else begin
                 $display("31. blt implementation is incorrect");
                 fault_instrs = fault_instrs + 1'b1;
             end
         end

         BGE_IN : begin
             if(Result <= 64'hB) $display("32. bge is executing");
             else begin
                 $display("bge struck in loop");
                 flag = 1;
                 $stop;
             end
         end

         BGE_OUT : begin
             i = i + 1'b1;
             if(Result === -6) $display("32. bge implementation is correct");
             else begin
                 $display("32. bge implementation is incorrect");
                 fault_instrs = fault_instrs + 1'b1;
             end
         end

         BLTU_IN : begin
             if(Result <= 4) $display("33. bltu is executing");
             else begin
                 $display("bltu struck in loop");
                 flag = 1;
                 $stop;
             end
         end

         BLTU_OUT : begin
             i = i + 1'b1;
             if(Result === 5) $display("33. bltu implementation is correct ");
             else begin
                 $display("33. bltu implementation is incorrect");
                 fault_instrs = fault_instrs + 1'b1;
             end
         end

         BGEU_IN : begin
             if(Result <= 5) $display("34. bgeu is executing");
             else begin
                 $display("bgeu struck in loop");
                 flag = 1;
                 $stop;
             end
         end

         BGEU_OUT : begin
             i = i + 1'b1;
             if(Result === 0) $display("34. bgeu implementation is correct ");
             else begin
                 $display("34. bgeu implementation is incorrect");
                 fault_instrs = fault_instrs + 1'b1;
             end
         end

         BNE_IN : begin
             if(Result <= 5) $display("35. bne is executing");
             else begin
                 $display("bne struck in loop");
                 flag = 1;
                 $stop;
             end
         end

         BNE_OUT : begin
             i = i + 1'b1;
             if(Result === 5) $display("35. bne implementation is correct ");
             else begin
                 $display("35. bne implementation is incorrect");
                 fault_instrs = fault_instrs + 1'b1;
             end
         end

         BEQ_IN : begin
             if(Result <=2) $display("36. beq is executing");
             else begin
                 $display("beq struck in loop");
                 $stop;
             end
         end

         BEQ_OUT : begin
             i = i + 1'b1;
             if(Result === 4) $display("36. beq implementation is correct ");
             else begin
                 $display("36. beq implementation is incorrect");
                 fault_instrs = fault_instrs + 1'b1;
             end
         end

         JALR     : begin
             i = i + 1'b1;
             if (Result === 64'h130) $display("37. jalr implementation is correct ");
             else begin
                 $display("37. jalr implementation is incorrect");
                 fault_instrs = fault_instrs + 1'b1;
             end
         end

         JAL     : begin
             i = i + 1'b1;
             if (Result === 64'h13C ) $display("38. jal implementation is correct ");
             else begin
                 $display("38. jal implementation is incorrect");
             end
         end
     endcase
     
     case(PCM)
         SB      : begin
             i = i + 1'b1;
             if(MemWrite && reset) begin
                 if(DataAdr === 33 & WriteData[7:0] == 1) $display ("23. sb implementation is correct");
                 else begin
                     $display("23. sb implementation is incorrect");
                     fault_instrs = fault_instrs + 1'b1;
                 end
             end
         end

         SH      : begin
             i = i + 1'b1;
             if(MemWrite && reset) begin
                 if(DataAdr === 38 & WriteData[15:0] === 16'hFFFD) $display ("24. sh implementation is correct");
                 else begin
                     $display("24. sh implementation is incorrect");
                     fault_instrs = fault_instrs + 1'b1;
                 end
             end
         end

         SW      : begin
             i = i + 1'b1;
             if(MemWrite && reset) begin
                 if(DataAdr === 40 & WriteData[31:0] === 16) $display ("25. sw implementation is correct");
                 else begin
                     $display("25. sw implementation is incorrect");
                     fault_instrs = fault_instrs + 1'b1;
                 end
             end
         end
      endcase
 end

 always @(negedge clk) begin
     if (i >= 70|| flag == 1) begin
         $display("Faulty Instructions => %d", fault_instrs);
         if (fault_instrs !== 0) begin
             fw = $fopen("results.txt","w");
             $fdisplay(fw, "%02h","Errors");
             $display("Error(s) encountered, please check your design!");
             $fclose(fw);
         end
         else begin
             fw = $fopen("results.txt","w");
             $fdisplay(fw, "%02h","No Errors");
             $display("No errors encountered, congratulations!");
             $fclose(fw);
         end
            $stop;
     end
 end

endmodule