`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.12.2023 22:57:26
// Design Name: 
// Module Name: pipe_MIPS32
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
Register type instr
31   26 25    21 20    16 15    11 10      6 5     0
opcode     rs       rt       rd    shift amt   funct 
                                   {----not used---}
                                   
Immediate type instr
31   26 25    21 20    16 15        0
opcode     rs       rt       imm data                             

reg 0 = 0 always
*/



module pipe_MIPS32(
clk1, clk2
    );
input clk1, clk2; //2 phase clk

reg [31:0] PC, IF_ID_IR, IF_ID_NPC;
reg [31:0] ID_EX_IR, ID_EX_NPC, ID_EX_A, ID_EX_B, ID_EX_Imm;
reg [2:0] ID_EX_type, EX_MEM_type, MEM_WB_type;
reg [31:0] EX_MEM_IR, EX_MEM_ALUout, EX_MEM_B;
reg EX_MEM_cond;
reg [31:0] MEM_WB_IR, MEM_WB_ALUout, MEM_WB_LMD;

reg [31:0] reg_bank [0:31];
reg [31:0] mem [0:1023]; //1024 x 32 mem

//instr set opcode

//R-type instr
parameter ADD = 6'b000000;
parameter SUB = 6'b000001;
parameter AND = 6'b000010;
parameter OR = 6'b000011;
parameter SLT = 6'b000100;
parameter MUL = 6'b000101;
parameter HLT = 6'b111111;

//I-type instr
parameter LW = 6'b001000;
parameter SW = 6'b001001;
parameter ADDI = 6'b001010;
parameter SUBI = 6'b001011;
parameter SLTI = 6'b001100;
parameter BNEQZ = 6'b001101;
parameter BEQZ = 6'b001110;

//type of instr
parameter RR_ALU = 3'b000;
parameter RM_ALU = 3'b001; //instrs with immediate data 
parameter LOAD = 3'b010;
parameter STORE = 3'b011;
parameter BRANCH = 3'b100;
parameter HALT = 3'b101;

reg HALTED; //set after HLT instr is completed(in WB) stage) so that writing of next instrs will be disabled
reg TAKEN_BRANCH; //required to disable write operations of instr just after branch till desired destinatn addr

always@(posedge clk1)   //IF stage
begin
    if(HALTED==0)
    begin
        if( ((EX_MEM_IR[31:26]==BEQZ) && (EX_MEM_cond==1)) || ((EX_MEM_IR[31:26]==BNEQZ) && (EX_MEM_cond==0)) )
        begin
            IF_ID_IR <= #2 mem[EX_MEM_ALUout];
            TAKEN_BRANCH <= #2 1'b1;
            IF_ID_NPC <= #2 EX_MEM_ALUout + 1;
            PC <= #2 EX_MEM_ALUout + 1;
        end
        else
        begin
            IF_ID_IR <= #2 mem[PC];
            IF_ID_NPC <= #2 PC + 1;
            PC <= #2 PC + 1;
        end 
    end
end

always@(posedge clk2)  //ID stage
begin  
    if(HALTED==0)
    begin
        TAKEN_BRANCH <= #2 0;
        
        if(IF_ID_IR[25:21] == 5'b00000) //rs
            ID_EX_A <= 0;               //reg 0
        else
            ID_EX_A <= #2 reg_bank[IF_ID_IR[25:21]]; 
        if(IF_ID_IR[20:16] == 5'b00000) //rs
            ID_EX_B <= 0;               //reg 0
        else
            ID_EX_B <= #2 reg_bank[IF_ID_IR[20:16]]; 
            
        ID_EX_NPC <= #2 IF_ID_NPC;
        ID_EX_IR <= #2 IF_ID_IR;
        ID_EX_Imm <= #2 {{16{IF_ID_IR[15]}}, {IF_ID_IR[15:0]}};
        
        case(IF_ID_IR[31:26])
            ADD, SUB, AND, OR, SLT, MUL : ID_EX_type <= #2 RR_ALU;
            ADDI, SUBI, SLTI : ID_EX_type <= #2 RM_ALU;
            LW : ID_EX_type <= #2 LOAD;
            SW : ID_EX_type <= #2 STORE;
            BNEQZ, BEQZ : ID_EX_type <= #2 BRANCH;
            HLT : ID_EX_type <= #2 HALT;
            default : ID_EX_type <= #2 HALT;
        endcase
    end
end
        
always@(posedge clk1) //EX stage
begin
    if(HALTED==0)   
    begin
        EX_MEM_type <= #2 ID_EX_type;
        EX_MEM_IR <= #2 ID_EX_IR;
        
        
        case(ID_EX_type)
            RR_ALU : begin
                        case(ID_EX_IR[31:26]) //opcode
                            ADD : EX_MEM_ALUout <= #2 ID_EX_A + ID_EX_B;
                            SUB : EX_MEM_ALUout <= #2 ID_EX_A - ID_EX_B;
                            AND : EX_MEM_ALUout <= #2 ID_EX_A & ID_EX_B;
                            OR : EX_MEM_ALUout <= #2 ID_EX_A | ID_EX_B;
                            SLT : EX_MEM_ALUout <= #2 ID_EX_A < ID_EX_B;
                            MUL : EX_MEM_ALUout <= #2 ID_EX_A * ID_EX_B;
                            default : EX_MEM_ALUout <= #2 32'hxxxxxxxx;
                         endcase                        
                     end
            RM_ALU : begin
                        case(ID_EX_IR[31:26])
                            ADDI : EX_MEM_ALUout <= #2 ID_EX_A + ID_EX_Imm;
                            SUBI : EX_MEM_ALUout <= #2 ID_EX_A - ID_EX_Imm;
                            SLTI : EX_MEM_ALUout <= #2 ID_EX_A < ID_EX_Imm;
                            default : EX_MEM_ALUout <= #2 32'hxxxxxxxx;
                        endcase
                     end
            LOAD, STORE : 
                     begin
                        EX_MEM_ALUout <= #2 ID_EX_A + ID_EX_Imm;
                        EX_MEM_B <= #2 ID_EX_B;
                     end
            BRANCH : begin
                        EX_MEM_ALUout <= #2 ID_EX_NPC + ID_EX_Imm;
                        EX_MEM_cond <= #2 (ID_EX_A==0);
                     end
        endcase                
    end
end

always@(posedge clk2) //mem stage
begin
    if(HALTED==0)
    begin
        MEM_WB_type <= #2 EX_MEM_type;
        MEM_WB_IR <= #2 EX_MEM_IR;
        
        case(EX_MEM_type)
            RR_ALU, RM_ALU : 
                    begin
                        MEM_WB_ALUout <= #2 EX_MEM_ALUout;
                    end
            LOAD : begin
                       MEM_WB_LMD <= #2 mem[EX_MEM_ALUout];
                   end
            STORE : begin
                    if(TAKEN_BRANCH==0)
                        mem[EX_MEM_ALUout] <= #2 EX_MEM_B;
                    end
         endcase
    end
end 

always@(posedge clk1) //WB stage
begin
    if(TAKEN_BRANCH==0)
    begin
        case(MEM_WB_type)
            RR_ALU : reg_bank[MEM_WB_IR[15:11]] <= #2 MEM_WB_ALUout; //rd
            RM_ALU : reg_bank[MEM_WB_IR[20:16]] <= #2 MEM_WB_ALUout; //rt
            LOAD : reg_bank[MEM_WB_IR[20:16]] <= #2 MEM_WB_LMD; //rt
            HALT : HALTED <= #2 1'b1;
        endcase
    end
end

endmodule
