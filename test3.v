`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.12.2023 22:06:31
// Design Name: 
// Module Name: test3
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
compute factorial of number N stored in mem locn 200
store result in mem locn 198
ADDI R10, R0, 200
ADDI R2, R0, 1
LW R3, 0(R10)
LOOP : MUL R2, R2, R3
       SUBI R3, R3, 1
       BNEQZ R3, LOOP  //need to go to mem[5], PC=mem[9]; -4 is stored 
SW R2, -2(R10)  //-2 is stored in complement form with sign extended
HLT
*/

module test3();
reg clk1, clk2;
integer k;

pipe_MIPS32 mips3(clk1, clk2);

wire [31:0] PC = mips3.PC;
wire [31:0] IF_ID_IR = mips3.IF_ID_IR;
wire [31:0] IF_ID_NPC = mips3.IF_ID_NPC;
wire [31:0] ID_EX_A = mips3.ID_EX_A;
wire [31:0] ID_EX_B = mips3.ID_EX_B;
wire [31:0] ID_EX_IR = mips3.ID_EX_IR;
wire [31:0] ID_EX_Imm = mips3.ID_EX_Imm;
wire [2:0] ID_EX_type = mips3.ID_EX_type;
wire [31:0] EX_MEM_ALUout = mips3.EX_MEM_ALUout;
wire [31:0] EX_MEM_B = mips3.EX_MEM_B;
wire [31:0] EX_MEM_IR = mips3.EX_MEM_IR;
wire [2:0] EX_MEM_type = mips3.EX_MEM_type;
wire EX_MEM_cond = mips3.EX_MEM_cond;
wire [31:0] MEM_WB_ALUout = mips3.MEM_WB_ALUout;
wire [31:0] MEM_WB_IR = mips3.MEM_WB_IR;
wire [31:0] MEM_WB_LMD = mips3.MEM_WB_LMD;
wire [2:0] MEM_WB_type = mips3.MEM_WB_type;
wire HALTED = mips3.HALTED;
wire TAKEN_BRANCH = mips3.TAKEN_BRANCH;

initial 
begin
    clk1 = 0;
    clk2 = 0;
    repeat (100)
    begin
        #5 clk1 = 1; #5 clk1 = 0;
        #5 clk2 = 1; #5 clk2 = 0;
    end
end

initial
begin
    for(k=0; k<31; k=k+1)
        mips3.reg_bank[k] = k;
        
    mips3.mem[0] = 32'h280a00c8; //ADDI R10, R0, 200
    mips3.mem[1] = 32'h28020001; //ADDI R2, R0, 1
    mips3.mem[2] = 32'h0e94a000; //OR R20, R20, R20  dummy // 000011 10100 10100 10100 00000 000000
    mips3.mem[3] = 32'h21430000; //LW R3, 0(R10)
    mips3.mem[4] = 32'h0e94a000; //OR R20, R20, R20  dummy
    mips3.mem[5] = 32'h14431000; //LOOP : MUL R2, R2, R3
    mips3.mem[6] = 32'h2c630001; //SUBI R3, R3, 1
    mips3.mem[7] = 32'h0e94a000; //OR R20, R20, R20  dummy
    mips3.mem[8] = 32'h3460fffc; //BNEQZ R3, LOOP
    mips3.mem[9] = 32'h2542fffe; //SW R2, -2(R10)
    mips3.mem[10] = 32'hfc000000; //HLT
    
    mips3.mem[200] = 5;  //factorial of 5
    
    mips3.HALTED = 0;
    mips3.PC = 0;
    mips3.TAKEN_BRANCH = 0;
    
    #700
    $display("mem[200] = %2d, mem[198] = %6d", mips3.mem[200], mips3.mem[198]);
    
end

initial
begin
    $dumpfile("mips3.vcd");
    $dumpvars(0, test3);
    $monitor("R2 = %4d", mips3.reg_bank[2]);
    #700 $finish;
end

endmodule
