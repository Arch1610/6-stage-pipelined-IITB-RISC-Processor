module alu(reg_a, reg_b, alu_op, out, carry, zero, block_write_en, old_carry, old_zero);

input [15:0] reg_a;
input [15:0] reg_b;
input [5:0] alu_op;
input old_carry, old_zero;
output reg [15:0] out;
output reg carry, zero;
output reg block_write_en;

wire [16:0] out_wire;

assign out_wire = reg_a + reg_b;

always @ (*) begin
	case(alu_op[5:4]) 
		2'b00 : begin
			out = out_wire[15:0];
		end
		
		2'b01 : begin
			out = ~(reg_a & reg_b);
		end
		
		default : begin
			out = out_wire[15:0];
		end
	endcase
	
	if(alu_op[3] == 1) begin	
		carry = (out_wire[16] == 1'b1) ? 1'b1 : 1'b0;
	end
	
	if(alu_op[2] == 1) begin
		zero = (out == 16'h0000) ? 1'b1 : 1'b0;
	end
	
	//blocking write enable if carry is not set
	if(alu_op[1] == 1)
		if(old_carry == 0)
			block_write_en = 1'b0;
		else 
			block_write_en = 1'b1;
		
	//blocking write enable if zero is not set	
	else if(alu_op[0] == 1)
		if(old_zero == 0)
			block_write_en = 1'b0;
		else 
			block_write_en = 1'b1;
	else 
		block_write_en = 1'b1;
		
end

endmodule