module inst_fetch(pc, next_pc, pc_plus_four, target_branch, imm, beq, bneq, bge, blt, jmp, clk, rst);

output reg [31:0] pc, next_pc;
output [31:0] /*next_pc,*/ pc_plus_four, target_branch;
input [31:0] imm;
input beq, bneq, bge, blt, jmp, clk, rst;

assign pc_plus_four = pc + 4;
assign target_branch = pc + imm;
//assign next_pc = (beq  || bneq  || bge  || blt  || jmp ) ? target_branch : pc_plus_four;
always@(*) begin
if(beq ==1 || bneq  ==1 || bge ==1  || blt ==1 || jmp ==1 )
 next_pc = target_branch;
else
 next_pc = pc_plus_four;
end

initial begin
pc = 0;
end

always@(posedge clk or posedge rst) begin
if(rst)
pc <= 0;

else
pc <= next_pc;

end
endmodule

