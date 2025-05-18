module processor_core(clk, rst);

input clk,rst;

///////////////WIRES OF ALL MODULES/////////////////////


//Inst_FETCH

wire [31:0] pc,next_pc;
wire [31:0] pc_plus_four, target_branch;
wire [31:0] imm;
wire beq, bneq, bge, blt, jmp;

//ALU_rv32i
wire [31:0] alu_result;
wire [31:0] operand_A;
wire [31:0] operand_B;
wire [3:0] alu_op;

//RegFile
wire [31:0] rout1, rout2;
wire [4:0] rs1, rs2, rd;
reg [31:0] reg_inp_data;
wire  RegWE;

//Inst_Decode
//wire [31:0] imm;
wire [6:0] opcode, func7;
wire [2:0] func3;
//wire [4:0] rs1,rs2,rd;
wire [31:0] instr;

// idk y i am feeling so nervous and excited at the same time I am just writing code
//CU
wire MR, MW, MemtoReg;

//data_mem
wire [31:0]read_mem_data;

//Inst_mem
//all already defined :)


//Instantiating Inst_FETCH
inst_fetch inst_fetch(
	.pc(pc),
	.next_pc(next_pc),
	.pc_plus_four(pc_plus_four),
	.target_branch(target_branch),
	.imm(imm),
	.beq(beq),
	.bneq(bneq),
	.bge(bge),
	.blt(blt),
	.jmp(jmp),
	.clk(clk),
	.rst(rst)
);

//Instantiating RegFile
regFile RegFile(
	.rout1(rout1),
	.rout2(rout2),
	.rs1(rs1),
	.rs2(rs2),
	.rd(rd),
	.inp_data(reg_inp_data),
	.clk(clk),
	.rst(rst),
	.we(RegWE)
);

//Instantiating Inst_Decode
inst_decode inst_decode(
	.imm(imm),
	.opcode(opcode),
	.func7(func7),
	.func3(func3),
	.rs1(rs1),
	.rs2(rs2),
	.rd(rd),
	.instr(instr)
);

//Instantiating CU
CU CU(
	.opcode(opcode),
	.func7(func7),
	.func3(func3),
	.alu_op(alu_op),
	.MR(MR),
	.MW(MW),
	.regWE(RegWE),
	.beq(beq),
	.bneq(bneq),
	.bge(bge),
	.blt(blt),
	.jmp(jmp),
	.MemtoReg(MemtoReg)
);
	
//Wiring ALU operands
assign operand_A = rout1;
assign operand_B = (opcode == 7'b0110011 || opcode == 7'b1100011) ? rout2 : imm;

//Instantiating ALU_rv32i
ALU alu(
	.Result(alu_result),
	.A(operand_A),
	.B(operand_B),
	.alu_op(alu_op)
);

//Instantiating data_mem
data_mem data_mem(
	.data(rout2),
	.addrs(alu_result),
	.clk(clk),
	.we(MW),
	.re(MR),
	.data_out(read_mem_data)
);

//Write back logic acc to blk diag
always@(*) begin
if(jmp)
reg_inp_data = pc_plus_four;
else if(MemtoReg)
reg_inp_data = read_mem_data;
else
reg_inp_data = alu_result;
end

//Instantiating Inst_mem
i_mem inst_mem(
	.PC(pc),
	.instr(instr)
);

    // Debug
    always @(posedge clk) begin
        $display("PC: %h, Instruction: %h", pc, instr);
    end

endmodule
