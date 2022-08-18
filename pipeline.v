module pipeline(clk, rst);

input clk, rst;		

reg ma_wb_reg_write_en;
reg [15:0] ma_wb_out, ex_ma_out;	
wire [15:0] reg_wb_data, datamem_read_data;
wire [15:0] out;
wire clk_ctrl, stall_clk;
reg rr_ex_instr_flush_2;
reg [2:0] ma_wb_dest;
wire and_clk;


// clk for instruction stalling
assign stall_clk = clk_ctrl & clk;
//dflipflop d_flipFlop(and_clk, clk, stall_clk);


// instruction fetch stage
reg [15:0] if_id_instr, if_id_pc;
wire [15:0] pc, instruction, r7;
instr_mem instruction_mem (pc,instruction);
assign pc = r7;

always @ (posedge stall_clk) begin
	if_id_instr <= instruction;
	if_id_pc <= pc;
end

// instruction decode stage
reg [15:0] id_rr_pc2,id_rr_instr, id_rr_imm_data,id_rr_jal_loc;
reg [2:0] id_rr_ra, id_rr_rb, id_rr_dest;
reg [1:0] id_rr_out_sel;
wire [2:0] destination, source_a, source_b;
reg [1:0] id_rr_alu_b, id_rr_r7_write_mux;
wire [1:0] alu_b, r7_write_mux;
reg id_rr_reg_write_en, id_rr_datamem_read_en, id_rr_datamem_write_en, id_rr_mem_alu, id_rr_r7_write_en, id_rr_instr_flush, id_rr_instr_flush_2;
wire reg_write_en, datamem_write_en, datamem_read_en, mem_alu, r7_write_en, instr_flush,instr_flush_2;
reg [5:0] id_rr_alu_op;
wire [5:0] alu_op; 
wire [1:0] imm_ctrl;
wire [15:0] imm_data, instruction_decode;
wire [1:0] out_sel;

assign instruction_decode = if_id_instr;

instruction_decoder instr_dec(if_id_instr, destination, source_a, source_b, alu_b, reg_write_en, datamem_write_en, datamem_read_en, mem_alu, alu_op,imm_ctrl, out_sel, r7_write_en, instr_flush, id_rr_instr_flush, r7_write_mux, instr_flush_2,rr_ex_instr_flush_2);

wire [15:0] imm_data_6bit, imm_data_9bit, imm_data_9bit_lsb;
wire [15:0] jal_loc, pc2;

assign imm_data_6bit = {{10{if_id_instr[5]}},if_id_instr[5:0]};
assign imm_data_9bit = {if_id_instr[8:0], {7{1'b0}}};
assign imm_data_9bit_lsb = {{7{if_id_instr[8]}},if_id_instr[8:0]};

mux4 mux_imm(imm_data_6bit, imm_data_9bit, imm_data_9bit_lsb, 16'd0, imm_ctrl, imm_data);

// For JAL instruction
assign jal_loc = (2*imm_data) + if_id_pc;
assign pc2 = if_id_pc + 2;


//Sending data to next stage
always @ (posedge stall_clk) begin
	id_rr_instr <= if_id_instr;
	id_rr_pc2 <= pc2;
	id_rr_ra <= source_a;			//source a
	id_rr_rb <= source_b;			//source b
	id_rr_dest <= destination;			//destination
	id_rr_alu_b <= alu_b;
	id_rr_reg_write_en <= reg_write_en;
	id_rr_datamem_read_en <= datamem_read_en;
	id_rr_datamem_write_en <= datamem_write_en;
	id_rr_mem_alu <= mem_alu;
	id_rr_alu_op <= alu_op;
	id_rr_imm_data <= imm_data;
	id_rr_out_sel <= out_sel;
	id_rr_jal_loc <= jal_loc;
	id_rr_r7_write_en <= r7_write_en;
	id_rr_instr_flush <= instr_flush;
	id_rr_instr_flush_2 <= instr_flush_2;
	id_rr_r7_write_mux <= r7_write_mux;
end

// register read stage
reg [2:0] rr_ex_dest;
reg [15:0] rr_ex_pc2, rr_ex_instr;
reg [15:0] rr_ex_imm_data;
wire [15:0] y1, y2, y3, y4, y5, y6, instruction_register_read, jri_loc;
reg [15:0] rr_ex_reg_a_data, rr_ex_reg_b_data;
reg [5:0] rr_ex_alu_op;
reg [1:0] rr_ex_alu_b;
reg [1:0] rr_ex_out_sel;

wire ex_sel1, ma_sel1, wb_sel1, ex_sel2, ma_sel2, wb_sel2;
wire [15:0]reg_a_data, reg_b_data, jump_reg_value;

reg rr_ex_reg_write_en, rr_ex_datamem_read_en, rr_ex_datamem_write_en,rr_ex_mem_alu;

assign instruction_register_read = id_rr_instr;

//MUX for JAL and JLR instruction


assign jri_loc = (2*id_rr_imm_data) + reg_a_data;
mux4 mux_jump(id_rr_jal_loc, reg_a_data, jri_loc, 16'd0,id_rr_r7_write_mux, jump_reg_value);




///////////////////////////


register_file reg_file(rst, clk, ma_wb_reg_write_en, id_rr_r7_write_en, ma_wb_dest, reg_wb_data, jump_reg_value, id_rr_ra, reg_a_data, id_rr_rb, reg_b_data, r7);//reg_write_data

datadependency data_depend(id_rr_instr,clk, ex_sel1, ma_sel1, wb_sel1, ex_sel2, ma_sel2, wb_sel2, clk_ctrl);

mux2 mux_wb1(reg_wb_data, reg_a_data, wb_sel1, y1);
mux2 mux_ma1(datamem_read_data, y1, ma_sel1, y2);
mux2 mux_ex1(out, y2, ex_sel1, y3);

mux2 mux_wb2(reg_wb_data, reg_b_data, wb_sel2, y4);
mux2 mux_ma2(datamem_read_data, y4, ma_sel2, y5);
mux2 mux_ex2(out, y5, ex_sel2, y6);

always @ (posedge stall_clk) begin
	rr_ex_instr <= id_rr_instr;
	rr_ex_pc2 <= id_rr_pc2;
	rr_ex_dest <= id_rr_dest;
	rr_ex_reg_a_data <= y3;
	rr_ex_reg_b_data <= y6;
	rr_ex_alu_op <= id_rr_alu_op;
	rr_ex_alu_b <= id_rr_alu_b;
	rr_ex_reg_write_en <= id_rr_reg_write_en;
	rr_ex_datamem_read_en <= id_rr_datamem_read_en;
	rr_ex_datamem_write_en <= id_rr_datamem_write_en;
	rr_ex_mem_alu <= id_rr_mem_alu;
	rr_ex_imm_data <= id_rr_imm_data;
	rr_ex_out_sel <= id_rr_out_sel;
	rr_ex_instr_flush_2 <= id_rr_instr_flush_2;
end

//execution stage

reg ex_ma_reg_write_en;
reg ex_ma_carry,ex_ma_zero;
reg [15:0]ex_ma_pc2;
reg [2:0] ex_ma_dest;
wire [15:0]rb_left;
wire [15:0]reg_bl_data;
wire [15:0] final_out, instruction_execution;
reg ex_ma_datamem_read_en, ex_ma_datamem_write_en, ex_ma_mem_alu;
reg [15:0]ex_ma_reg_a_data, ex_ma_reg_b_data, ex_ma_instr;

assign instruction_execution = rr_ex_instr;

assign rb_left = {rr_ex_reg_b_data[14:0], 1'b0};
alu alu_unit(rr_ex_reg_a_data, reg_bl_data, rr_ex_alu_op, out, carry, zero, block_write_en, ex_ma_carry, ex_ma_zero);
mux4 mux(rb_left, rr_ex_reg_b_data, rr_ex_imm_data, d, rr_ex_alu_b, reg_bl_data);
mux4 mux_alu_op(out, rr_ex_imm_data, rr_ex_pc2, d, rr_ex_out_sel, final_out);

always @ (posedge clk) begin
	ex_ma_pc2 <= rr_ex_pc2;
	ex_ma_instr <= rr_ex_instr;
	ex_ma_reg_write_en <= block_write_en & rr_ex_reg_write_en;
	ex_ma_dest <= rr_ex_dest;
	ex_ma_out <= final_out;
	ex_ma_carry <= carry;
	ex_ma_zero <= zero;
	ex_ma_datamem_read_en <= rr_ex_datamem_read_en;
	ex_ma_datamem_write_en <= rr_ex_datamem_write_en;
	ex_ma_mem_alu <= rr_ex_mem_alu;
	ex_ma_reg_a_data <= rr_ex_reg_a_data;
	ex_ma_reg_b_data <= rr_ex_reg_b_data;
end

// memory access stage


reg ma_wb_carry, ma_wb_zero;
reg ma_wb_mem_alu;
wire [15:0] instruction_memory_access;
reg [15:0] ma_wb_datamem_read_data, ma_wb_instr;

assign instruction_memory_access = ex_ma_instr;

data_memory data_mem(clk, ex_ma_out, ex_ma_reg_b_data, ex_ma_datamem_write_en, ex_ma_datamem_read_en, datamem_read_data);

always @(posedge clk) begin
	ma_wb_instr <= ex_ma_instr;
	ma_wb_dest <= ex_ma_dest;
	ma_wb_reg_write_en <= ex_ma_reg_write_en;
	ma_wb_out <= ex_ma_out;
	ma_wb_datamem_read_data <= datamem_read_data;
	ma_wb_carry <= ex_ma_carry;
	ma_wb_zero <= ma_wb_zero;
	ma_wb_mem_alu <= ex_ma_mem_alu;
end

// write back stage
wire [15:0] instruction_write_back;

assign instruction_write_back = ma_wb_instr;

mux2 mux_wb(ma_wb_datamem_read_data, ma_wb_out, ma_wb_mem_alu, reg_wb_data);


endmodule