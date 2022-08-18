module decode_stage(if_id_instr, reg_a, reg_b, reg_c, alu_b, reg_write_en, datamem_write_en, datamem_read_en, mem_alu, alu_op,out_sel,imm_data);
	reg [15:0] id_rr_pc,id_rr_instr, id_rr_imm_data;
	reg [2:0] id_rr_ra, id_rr_rb, id_rr_rc;
	reg [1:0] id_rr_out_sel;
	wire [2:0] reg_a, reg_b, reg_c;
	reg [1:0] id_rr_alu_b;
	wire [1:0] alu_b;
	reg id_rr_reg_write_en, id_rr_datamem_read_en, id_rr_datamem_write_en, id_rr_mem_alu;
	wire reg_write_en, datamem_write_en, datamem_read_en, mem_alu;
	reg [5:0] id_rr_alu_op;
	wire [5:0] alu_op; 
	wire [1:0] imm_ctrl;
	wire [15:0] imm_data, instruction_decode;
	wire [1:0] out_sel;

	assign instruction_decode = if_id_instr;

	instruction_decoder instr_dec(if_id_instr, reg_a, reg_b, reg_c, alu_b, reg_write_en, datamem_write_en, datamem_read_en, mem_alu, alu_op,imm_ctrl, out_sel);

	wire [15:0] imm_data_6bit, imm_data_9bit;

	assign imm_data_6bit = {{10{if_id_instr[5]}},if_id_instr[5:0]};
	assign imm_data_9bit = {if_id_instr[8:0], {7{1'b0}}};
	mux4 mux_imm(imm_data_6bit, imm_data_9bit, c, d, imm_ctrl, imm_data);
	
endmodule