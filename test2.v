`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.12.2023 21:07:57
// Design Name: 
// Module Name: test2
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
/* data dependency
load a word stored in mem locn 120, add 45 to it, and store result in locn 121

ADDI R1, R0, 120
LW R2, 0(R1)
ADDI R2, R2, 45
SW R2, 1(R1)
HLT
*/

module test2();
reg clk1, clk2;
integer k;

pipe_MIPS32 mips2 (clk1, clk2);

wire [31:0] PC = mips2.PC;
wire [31:0] IF_ID_IR = mips2.IF_ID_IR;
wire [31:0] IF_ID_NPC = mips2.IF_ID_NPC;
wire [31:0] ID_EX_A = mips2.ID_EX_A;
wire [31:0] ID_EX_B = mips2.ID_EX_B;
wire [31:0] ID_EX_IR = mips2.ID_EX_IR;
wire [31:0] ID_EX_Imm = mips2.ID_EX_Imm;
wire [2:0] ID_EX_type = mips2.ID_EX_type;
wire [31:0] EX_MEM_ALUout = mips2.EX_MEM_ALUout;
wire [31:0] EX_MEM_B = mips2.EX_MEM_B;
wire [31:0] EX_MEM_IR = mips2.EX_MEM_IR;
wire [2:0] EX_MEM_type = mips2.EX_MEM_type;
wire [31:0] MEM_WB_ALUout = mips2.MEM_WB_ALUout;
wire [31:0] MEM_WB_IR = mips2.MEM_WB_IR;
wire [31:0] MEM_WB_LMD = mips2.MEM_WB_LMD;
wire [2:0] MEM_WB_type = mips2.MEM_WB_type;
wire HALTED = mips2.HALTED;
wire TAKEN_BRANCH = mips2.TAKEN_BRANCH;

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
        mips2.reg_bank[k] = k;
    
    mips2.mem[0] = 32'h28010078; //ADDI R1, R0, 120
    mips2.mem[1] = 32'h0c631800; //OR R3, R3, R3  dummy instr
    mips2.mem[2] = 32'h20220000; //LW R2, 0(R1)
    mips2.mem[3] = 32'h0c631800; //OR R3, R3, R3  dummy instr
    mips2.mem[4] = 32'h2842002d; //ADDI R2, R2, 45
    mips2.mem[5] = 32'h0c631800; //OR R3, R3, R3  dummy instr
    mips2.mem[6] = 32'h24220001; //SW R2, 1(R1)
    mips2.mem[7] = 32'hfc000000; //HLT
    
    mips2.mem[120] = 85;
    
    mips2.HALTED = 0;
    mips2.PC = 0;
    mips2.TAKEN_BRANCH = 0;
    
    #280
    $display("mem[120] = %4d, mem[121] = %4d", mips2.mem[120], mips2.mem[121]);
end

initial
begin
    $dumpfile("mips2.vcd");
    $dumpvars(0, test2);
    #300 $finish;
end

endmodule
