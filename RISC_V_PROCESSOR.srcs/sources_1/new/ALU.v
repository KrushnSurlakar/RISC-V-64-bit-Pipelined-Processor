`timescale 1ns / 1ps

module ALU (
    input  wire [63:0] a,
    input  wire [63:0] b,
    input  wire [3:0] alu_ctrl,
    output reg  [63:0] result
);
    
    // Temporary register to hold the 32-bit math result before sign-extension
    reg [31:0] word_res;

    always @(*) begin
        case (alu_ctrl)
            4'b0000: result = a + b; //add
            4'b0001: result = a - b; //sub
            4'b0010: result = a & b; //and
            4'b0011: result = a | b; //or
            4'b0100: result = a ^ b; //xor
            4'b0101: result = a << b[5:0]; //sll
            4'b0110: result = a >> b[5:0]; //srl
            4'b0111: result = $signed(a) >>> b[5:0]; //sra
            
            // slt and sltu padded with 63 zeros to prevent width warnings
            4'b1000: result = {($signed(a) < $signed(b))}; //slt
            4'b1001: result = {(a < b)}; //sltu
            
            // -----------------------------------------------------------
            // 32-bit Word operations (Calculate in 32-bit, then sign-extend)
            // -----------------------------------------------------------
            4'b1011: begin 
                word_res = a[31:0] + b[31:0]; 
                result = { {32{word_res[31]}}, word_res }; 
            end // ADDW
            
            4'b1100: begin 
                word_res = a[31:0] - b[31:0]; 
                result = { {32{word_res[31]}}, word_res }; 
            end // SUBW
            
            4'b1101: begin 
                word_res = a[31:0] << b[4:0]; 
                result = { {32{word_res[31]}}, word_res }; 
            end // SLLW
            
            4'b1110: begin 
                word_res = a[31:0] >> b[4:0]; 
                result = { {32{word_res[31]}}, word_res }; 
            end // SRLW
            
            4'b1111: begin 
                word_res = $signed(a[31:0]) >>> b[4:0]; 
                result = { {32{word_res[31]}}, word_res }; 
            end // SRAW
            
            default: result = 64'b0;
        endcase
    end

endmodule