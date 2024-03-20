`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.12.2023 20:29:18
// Design Name: 
// Module Name: test1
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
/*
ADDI R1, R0, 10
ADDI R2, R0, 20
ADDI R3, R0, 25
ADD R4, R1, R2    
ADD R5, R4, R3   //DATA HAZARD OCCURS
HLT
*/

module test1();
reg clk1, clk2;
integer k;

pipe_MIPS32 mips1(clk1, clk2);

wire [31:0] PC = mips1.PC;
wire [31:0] IF_ID_IR = mips1.IF_ID_IR;
wire [31:0] IF_ID_NPC = mips1.IF_ID_NPC;
wire [31:0] ID_EX_A = mips1.ID_EX_A;
wire [31:0] ID_EX_B = mips1.ID_EX_B;
wire [31:0] ID_EX_IR = mips1.ID_EX_IR;
wire [31:0] ID_EX_Imm = mips1.ID_EX_Imm;
wire [2:0] ID_EX_type = mips1.ID_EX_type;
wire [31:0] EX_MEM_ALUout = mips1.EX_MEM_ALUout;
wire [31:0] EX_MEM_IR = mips1.EX_MEM_IR;
wire [2:0] EX_MEM_type = mips1.EX_MEM_type;
wire [31:0] MEM_WB_ALUout = mips1.MEM_WB_ALUout;
wire [31:0] MEM_WB_IR = mips1.MEM_WB_IR;
wire [2:0] MEM_WB_type = mips1.MEM_WB_type;
wire HALTED = mips1.HALTED;
wire TAKEN_BRANCH = mips1.TAKEN_BRANCH;


initial 
begin
    clk1 = 0;
    clk2 = 0;
    repeat (20)
    begin
        #5 clk1 = 1; #5 clk1 = 0;
        #5 clk2 = 1; #5 clk2 = 0;
    end
end

initial
begin
    for(k=0; k<31; k=k+1)
        mips1.reg_bank[k] = k;
    
    mips1.mem[0] = 32'h2801000a; //ADDI R1, R0, 10
    mips1.mem[1] = 32'h28020014; //ADDI R2, R0, 20
    mips1.mem[2] = 32'h28030019; //ADDI R3, R0, 25
    mips1.mem[3] = 32'h0ce77800; //OR R7, R7, R7   dummy instr
    mips1.mem[4] = 32'h0ce77800; //OR R7, R7, R7   dummy instr
    mips1.mem[5] = 32'h00222000; //ADD R4, R1, R2 
    mips1.mem[6] = 32'h0ce77800; //OR R7, R7, R7   dummy instr
    mips1.mem[7] = 32'h00832800; //ADD R5, R4, R3
    mips1.mem[8] = 32'hfc000000; //HLT
    
    mips1.HALTED = 0;
    mips1.PC = 0;
    mips1.TAKEN_BRANCH = 0;
    
    #280
    for(k=0; k<6; k=k+1)
        $display("R%1d = %2d", k, mips1.reg_bank[k]);
end

initial
begin
    $dumpfile("mips1.vcd");
    $dumpvars(0, test1);
    #300 $finish;
end
    
endmodule
