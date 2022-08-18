module instruction_decoder(instruction, destination, source_a, source_b, alu_b, reg_write_en, datamem_write_en, datamem_read_en, mem_alu, alu_op,imm_ctrl, out_mux_sel, r7_write_en, instr_flush, del_instr, r7_write_mux, instr_flush_2,del_instr_2);
	input [15:0] instruction;
	input del_instr, del_instr_2;
	output reg [2:0] destination, source_a, source_b;
	output reg reg_write_en, datamem_write_en, datamem_read_en, mem_alu, r7_write_en, instr_flush,instr_flush_2;
	output reg [5:0] alu_op;			//alu_op[5:4]- operation(add[00], nand[01], sub[10]), alu_op[3] - carry set, alu_op[2] - zero set, alu_op[1] - check carry, alu_op[0] - check zero
	output reg [1:0] alu_b, imm_ctrl, r7_write_mux;
	output reg [1:0] out_mux_sel;
	wire [5:0] alu_in;
	
	assign alu_in = {instruction[15:12],instruction[1:0]};
	
	always@(*) begin
	
		if(instruction[15:12] == 4'b0101) begin		// store
			destination = instruction[5:3];	//destination
			source_a = instruction[8:6];	//source a
			source_b = instruction[11:9];	//source b
		end
		else if ((instruction[15:12] == 4'b0100) | (instruction[15:12] == 4'b0011) | (instruction[15:12] == 4'b1001) | (instruction[15:12] == 4'b1010)) begin	//LHI, LW, JAL, JLR
			destination = instruction[11:9];	//destination
			source_a = instruction[8:6];	//source a
			source_b = instruction[5:3];	//source b
		end
		else if (instruction[15:12] == 4'b0000) begin	//ADI
			destination = instruction[8:6];	//destination
			source_a = instruction[11:9];	//source a
			source_b = instruction[5:3];	//source b
		end
		else begin		// ADD, ADC, ADZ, ADL, NDU, NDC, NDZ, JRI
			destination = instruction[5:3];	//destination
			source_a = instruction[11:9];	//source a
			source_b = instruction[8:6];	//source b
		end
		
	end
	
	always@(alu_in) begin
		casex(alu_in)
			6'b000100 : begin				//ADD
				alu_b <= 2'b01;
				reg_write_en <= 1'b1;
				datamem_read_en <= 1'b0;
				datamem_write_en <= 1'b0;
				mem_alu <= 1'b1;
				alu_op <= 6'b001100;
				imm_ctrl <= 2'b00;
				out_mux_sel <= 2'b00;
				r7_write_en <= 1'b0;
				instr_flush <= 1'b0;
				instr_flush_2 <= 1'b0;
				r7_write_mux <= 2'b00;
			end
			
			6'b000110 : begin				//ADC
				alu_b <= 2'b01;
				reg_write_en <= 1'b1;
				datamem_read_en <= 1'b0;
				datamem_write_en <= 1'b0;
				mem_alu <= 1'b1;
				alu_op <= 6'b001110;			// first two bits - operation, 3rd bit - carry modify, 4th bit - zero modify, // 5th and 6th bit - carry and zero check
				imm_ctrl <= 2'b00;
				out_mux_sel <= 2'b00;
				r7_write_en <= 1'b0;
				instr_flush <= 1'b0;
				instr_flush_2 <= 1'b0;
				r7_write_mux <= 2'b00;
			end
			
			6'b000101 : begin				//ADZ
				alu_b <= 2'b01;
				reg_write_en <= 1'b1;
				datamem_read_en <= 1'b0;
				datamem_write_en <= 1'b0;
				mem_alu <= 1'b1;
				alu_op <= 6'b001101;
				imm_ctrl <= 2'b00;
				out_mux_sel <= 2'b00;
				r7_write_en <= 1'b0;
				instr_flush <= 1'b0;
				instr_flush_2 <= 1'b0;
				r7_write_mux <= 2'b00;
			end
			
			6'b000111 : begin				//ADL
				alu_b <= 2'b00;
				reg_write_en <= 1'b1;
				datamem_read_en <= 1'b0;
				datamem_write_en <= 1'b0;
				mem_alu <= 1'b1;
				alu_op <= 6'b001100;
				imm_ctrl <= 2'b00;
				out_mux_sel <= 2'b00;
				r7_write_en <= 1'b0;
				instr_flush <= 1'b0;
				instr_flush_2 <= 1'b0;
				r7_write_mux <= 2'b00;
			end
			
			6'b0000xx: begin				//ADI
				alu_b <= 2'b10;
				reg_write_en <= 1'b1;
				datamem_read_en <= 1'b0;
				datamem_write_en <= 1'b0;
				mem_alu <= 1'b1;
				alu_op <= 6'b001100;
				imm_ctrl <= 2'b00; 
				out_mux_sel <= 2'b00;
				r7_write_en <= 1'b0;
				instr_flush <= 1'b0;
				instr_flush_2 <= 1'b0;
				r7_write_mux <= 2'b00;
			end
			
			6'b001000 : begin				//NDU
				alu_b <= 2'b01;
				reg_write_en <= 1'b1;
				datamem_read_en <= 1'b0;
				datamem_write_en <= 1'b0;
				mem_alu <= 1'b1;
				alu_op <= 6'b010100;
				imm_ctrl <= 2'b00;
				out_mux_sel <= 2'b00;
				r7_write_en <= 1'b0;
				instr_flush <= 1'b0;
				instr_flush_2 <= 1'b0;
				r7_write_mux <= 2'b00;
			end
			
			6'b001010 : begin				//NDC
				alu_b <= 2'b01;
				reg_write_en <= 1'b1;
				datamem_read_en <= 1'b0;
				datamem_write_en <= 1'b0;
				mem_alu <= 1'b1;
				alu_op <= 6'b010110;
				imm_ctrl <= 2'b00;
				out_mux_sel <= 2'b00;
				r7_write_en <= 1'b0;
				instr_flush <= 1'b0;
				instr_flush_2 <= 1'b0;
				r7_write_mux <= 2'b00;
			end
			
			6'b001001 : begin				//NDZ
				alu_b <= 2'b01;
				reg_write_en <= 1'b1;
				datamem_read_en <= 1'b0;
				datamem_write_en <= 1'b0;
				mem_alu <= 1'b1;
				alu_op <= 6'b010101;
				imm_ctrl <= 2'b00;
				out_mux_sel <= 2'b00;
				r7_write_en <= 1'b0;
				instr_flush <= 1'b0;
				instr_flush_2 <= 1'b0;
				r7_write_mux <= 2'b00;
			end
			
			6'b0011xx : begin				//LHI
				alu_b <= 2'b00;
				reg_write_en <= 1'b1;
				datamem_read_en <= 1'b0;
				datamem_write_en <= 1'b0;
				mem_alu <= 1'b1;
				alu_op <= 6'b010101;
				imm_ctrl <= 2'b01;
				out_mux_sel <= 2'b01;
				r7_write_en <= 1'b0;
				instr_flush <= 1'b0;
				instr_flush_2 <= 1'b0;
				r7_write_mux <= 2'b00;
			end
			
			6'b0100xx : begin			//LW
				alu_b <= 2'b10;
				reg_write_en <= 1'b1;
				datamem_read_en <= 1'b1;
				datamem_write_en <= 1'b0;
				mem_alu <= 1'b0;
				alu_op <= 6'b000100;
				imm_ctrl <= 2'b00;
				out_mux_sel <= 2'b00;
				r7_write_en <= 1'b0;
				instr_flush <= 1'b0;
				instr_flush_2 <= 1'b0;
				r7_write_mux <= 2'b00;
			end
			
			6'b0101xx : begin			//SW
				alu_b <= 2'b10;
				reg_write_en <= 1'b0;
				datamem_read_en <= 1'b0;
				datamem_write_en <= 1'b1;
				mem_alu <= 1'b0;
				alu_op <= 6'b000100;
				imm_ctrl <= 2'b00;
				out_mux_sel <= 2'b00;
				r7_write_en <= 1'b0;
				instr_flush <= 1'b0;
				instr_flush_2 <= 1'b0;
				r7_write_mux <= 2'b00;
			end
			
			6'b1001xx : begin			//JAL
				alu_b <= 2'b00;
				reg_write_en <= 1'b1;
				datamem_read_en <= 1'b0;
				datamem_write_en <= 1'b0;
				mem_alu <= 1'b1;
				alu_op <= 6'b000000;
				imm_ctrl <= 2'b10;
				out_mux_sel <= 2'b10;
				r7_write_en <= 1'b1;
				instr_flush <= 1'b1;
				instr_flush_2 <= 1'b0;
				r7_write_mux <= 2'b00;
			end
			
			6'b1010xx : begin			//JLR
				alu_b <= 2'b00;
				reg_write_en <= 1'b1;
				datamem_read_en <= 1'b0;
				datamem_write_en <= 1'b0;
				mem_alu <= 1'b1;
				alu_op <= 6'b000000;
				imm_ctrl <= 2'b11;
				out_mux_sel <= 2'b10;
				r7_write_en <= 1'b1;
				instr_flush <= 1'b1;
				instr_flush_2 <= 1'b0;
				r7_write_mux <= 2'b01;
			end
			
			6'b1011xx : begin			//JRI
				alu_b <= 2'b00;
				reg_write_en <= 1'b0;
				datamem_read_en <= 1'b0;
				datamem_write_en <= 1'b0;
				mem_alu <= 1'b0;
				alu_op <= 6'b000000;
				imm_ctrl <= 2'b10;
				out_mux_sel <= 2'b00;
				r7_write_en <= 1'b1;
				instr_flush <= 1'b1;
				instr_flush_2 <= 1'b1;
				r7_write_mux <= 2'b10;
			end
			
		endcase
		
		if((del_instr == 1'b1) | (del_instr_2 == 1'b1)) begin
			reg_write_en <= 1'b0;
			datamem_read_en <= 1'b0;
			datamem_write_en <= 1'b0;
		end
		
	end
		
endmodule