module datadependency(instruction,clk, ex_sel1, ma_sel1, wb_sel1, ex_sel2, ma_sel2, wb_sel2, clk_ctrl);

	input [15:0] instruction;
	input clk;
	output reg ex_sel1, ma_sel1, wb_sel1, ex_sel2, ma_sel2, wb_sel2;
	output reg clk_ctrl;

	reg [15:0] buffer [0:3];
	reg stall;
	
	reg [15:0] whichIF;
	
	initial begin
		clk_ctrl =1'b1; stall = 1'b0;
		ex_sel1 = 1; ex_sel2 = 1; ma_sel1 = 1; ma_sel2 = 1; wb_sel1 = 1; wb_sel2 = 1;
	end

	always@(negedge clk) begin
		buffer[3] = buffer[2];
		buffer[2] = buffer[1];
		buffer[1] = buffer[0];
		buffer[0] = instruction;
		
//---------------------------------------------------------------------------------------
// R type instruction data dependency
		
		if((buffer[0][15:14] == 2'b00) & (buffer[1][15:14] == 2'b00)) begin
			whichIF = 15'd1;
			//Register file vs execution stage source a
			if (buffer[0][11:9] == buffer[1][5:3]) begin
				whichIF = 15'd2;
				ex_sel1 = 0; 
			end
			else begin
				ex_sel1 = 1;
			end
			//Register file vs execution stage source b
			if (buffer[0][8:6] == buffer[1][5:3]) begin
				ex_sel2 = 0;
			end
			else begin
				ex_sel2 = 1;
			end		
		end
		
		if((buffer[0][15:14] == 2'b00) & (buffer[2][15:14] == 2'b00)) begin
			//Register file vs memory access stage source a
			if (buffer[0][11:9] == buffer[2][5:3]) begin
				ma_sel1 = 0;
			end
			else begin
				ma_sel1 = 1;
			end
			//Register file vs memory access stage source b
			if (buffer[0][8:6] == buffer[2][5:3]) begin
				ma_sel2 = 0;
			end
			else begin
				ma_sel2 = 1;
			end
		end
		
		if((buffer[0][15:14] == 2'b00) & (buffer[3][15:14] == 2'b00)) begin
			//Register file vs write back stage source a
			if (buffer[0][11:9] == buffer[3][5:3]) begin
				wb_sel1 = 0;
			end
			else begin
				wb_sel1 = 1;
			end
			//Register file vs write back stage source b
			if (buffer[0][8:6] == buffer[3][5:3]) begin
				wb_sel2 = 0;
			end
			else begin
				wb_sel2 = 1;
			end
		end
		
// R type instruction data dependency
//---------------------------------------------------------------------------------------
// Store and R type instruction data dependency
		
		if ((buffer[0][15:12] == 4'b0101) & (buffer[1][15:14] == 2'b00)) begin
			if (buffer[0][11:9] == buffer[1][5:3]) begin
				ex_sel2 = 0;
			end
			else begin
				ex_sel2 = 1;
			end
		end
		
		if ((buffer[0][15:12] == 4'b0101) & (buffer[2][15:14] == 2'b00)) begin
			if (buffer[0][11:9] == buffer[2][5:3]) begin
				ma_sel2 = 0;
			end
			else begin
				ma_sel2 = 1;
			end
		end
		
		if ((buffer[0][15:12] == 4'b0101) & (buffer[3][15:14] == 2'b00)) begin
			if (buffer[0][11:9] == buffer[3][5:3]) begin
				wb_sel2 = 0;
			end
			else begin
				wb_sel2 = 1;
			end
		end
		
// Store and R type instruction data dependency
//---------------------------------------------------------------------------------------
// Jump (JAL and JLR) and R type instruction data dependency 


	if((buffer[0][15:14] == 2'b00) & ((buffer[2][15:12] == 4'b1001) | buffer[2][15:12] == 4'b1010))) begin
			whichIF = 15'd1;

		//Register file vs memory access stage source a
		if (buffer[0][11:9] == buffer[2][11:9]) begin
			ma_sel1 = 0; ex_sel1 = 1; ex_sel2 = 1;
		end
		else begin
			ma_sel1 = 1; ex_sel1 = 1; ex_sel2 = 1;
		end
		//Register file vs memory access stage source b
		if (buffer[0][8:6] == buffer[2][11:9]) begin
			ma_sel2 = 0; ex_sel1 = 1; ex_sel2 = 1;
		end
		else begin
			ma_sel2 = 1; ex_sel1 = 1; ex_sel2 = 1;
		end
	end
		
	if((buffer[0][15:14] == 2'b00) & ((buffer[3][15:12] == 4'b1001) | (buffer[3][15:12] == 4'b1010))) begin
		//Register file vs write back stage source a
		if (buffer[0][11:9] == buffer[3][11:9]) begin
			wb_sel1 = 0; ex_sel1 = 1; ex_sel2 = 1;
		end
		else begin
			wb_sel1 = 1;
		end
		//Register file vs write back stage source b
		if (buffer[0][8:6] == buffer[3][11:9]) begin
			wb_sel2 = 0; ex_sel1 = 1; ex_sel2 = 1;
		end
		else begin
			wb_sel2 = 1;
		end
	end

// Jump (JAL and JLR) and R type instruction data dependency 
//---------------------------------------------------------------------------------------
// Jump (JAL and JLR) and Store instruction data dependency

	if((buffer[0][15:12] == 4'b0101) & ((buffer[2][15:12] == 4'b1001) | buffer[2][15:12] == 4'b1010))) begin
		whichIF = 15'd1;
		//Register file vs memory access stage source b
		if (buffer[0][11:9] == buffer[2][11:9]) begin
			ma_sel2 = 0; ex_sel1 = 1; ex_sel2 = 1; ma_sel1 = 1; wb_sel1 = 1;
		end
		else begin
			ma_sel2 = 1; ex_sel1 = 1; ex_sel2 = 1; ma_sel1 = 1; wb_sel1 = 1;
		end
	end
		
	if((buffer[0][15:12] == 4'b0101) & ((buffer[3][15:12] == 4'b1001) | (buffer[3][15:12] == 4'b1010))) begin
		//Register file vs write back stage source b
		if (buffer[0][11:9] == buffer[3][11:9]) begin
			wb_sel2 = 0; ex_sel1 = 1; ex_sel2 = 1; wb_sel1 = 1; ma_sel1 = 1
		end
		else begin
			wb_sel2 = 1; ex_sel1 = 1; ex_sel2 = 1; wb_sel1 = 1; ma_sel1 = 1
		end
	end

// Jump (JAL and JLR) and Store instruction data dependency
//---------------------------------------------------------------------------------------
// R type and JLR instruction data dependency
// ADD R1 = R2 + R3 buffer = 1
// JLR 				  buffer = 0

	if((buffer[0][15:12] == 4'b1010) & (buffer[1][15:14] == 2'b00)) begin
			whichIF = 15'd1;
			//Register file vs execution stage source a
			if (buffer[0][8:6] == buffer[1][5:3]) begin
				whichIF = 15'd2;
				ex_sel1 = 0; ex_sel2 = 1;
			end
			else begin
				ex_sel1 = 1; ex_sel2 = 1;
			end		
	end
		
	if((buffer[0][15:12] == 4'b1010) & (buffer[2][15:14] == 2'b00)) begin
		//Register file vs memory access stage source a
		if (buffer[0][8:6] == buffer[2][5:3]) begin
			ma_sel1 = 0; ma_sel2 = 1;
		end
		else begin
			ma_sel1 = 1; ma_sel2 = 1;
		end
	end
	
	if((buffer[0][15:12] == 4'b1010) & (buffer[3][15:14] == 2'b00)) begin
		//Register file vs write back stage source a
		if (buffer[0][8:6] == buffer[3][5:3]) begin
			wb_sel1 = 0; wb_sel2 = 1;
		end
		else begin
			wb_sel1 = 1; wb_sel2 = 1;
		end
	end

// R type and JLR instruction data dependency
//---------------------------------------------------------------------------------------
// For adding Stall
	
		if(stall == 1'b1) begin
			stall = 1'b0;
			clk_ctrl = 1'b1;
			buffer[1] = 16'hFFFF;
		end
		
		else if((buffer[1][15:12] == 4'b0100) & ((buffer[0][15:14] == 2'b00) | (buffer[0][15:12] == 4'b0101))) 		begin // check for load and (store or R type instruction)
			clk_ctrl = 1'b0;
			stall = 1'b1;
		end
		
// For adding Stall
//---------------------------------------------------------------------------------------
// Load and R type instruction data dependency	

		if((buffer[2][15:12] == 4'b0100) & (buffer[0][15:14] == 2'b00)) begin
			if (buffer[0][11:9] == buffer[2][11:9]) begin
				ma_sel1 = 0; ex_sel1 = 1; wb_sel1 = 1; ex_sel2 = 1; wb_sel2 = 1;
			end
			else begin
				ma_sel1 = 1; ex_sel1 = 1; wb_sel1 = 1; ex_sel2 = 1; wb_sel2 = 1;
			end
			//Register file vs memory access stage source b
			if (buffer[0][8:6] == buffer[2][11:9]) begin
				ma_sel2 = 0; ex_sel1 = 1; wb_sel1 = 1; ex_sel2 = 1; wb_sel2 = 1;
			end
			else begin
				ma_sel2 = 1; ex_sel1 = 1; wb_sel1 = 1; ex_sel2 = 1; wb_sel2 = 1;
			end	
		end
		
		
		if((buffer[3][15:12] == 4'b0100) & (buffer[0][15:14] == 2'b00)) begin
			//Register file vs memory access stage source a
			if (buffer[0][11:9] == buffer[3][11:9]) begin
				ma_sel1 = 1; ex_sel1 = 1; wb_sel1 = 0; ex_sel2 = 1; ma_sel2 = 1;
			end
			else begin
				ma_sel1 = 1; ex_sel1 = 1; wb_sel1 = 1; ex_sel2 = 1; ma_sel2 = 1;
			end
			//Register file vs memory access stage source b
			if (buffer[0][8:6] == buffer[3][11:9]) begin
				ma_sel2 = 1; ex_sel1 = 1; wb_sel2 = 0; ex_sel2 = 1; ma_sel1 = 1;
			end
			else begin
				ma_sel2 = 1; ex_sel1 = 1; wb_sel2 = 1; ex_sel2 = 1; ma_sel1 = 1;
			end
		end
		
// Load and R type instruction data dependency
//---------------------------------------------------------------------------------------
// Load and Store instruction data dependency	
		
		if((buffer[2][15:12] == 4'b0100) & (buffer[0][15:12] == 4'b0101)) begin
			if (buffer[0][11:9] == buffer[2][11:9]) begin
				ma_sel2 = 0; ex_sel1 = 1; wb_sel1 = 1; ex_sel2 = 1; wb_sel2 = 1; ma_sel1 = 1; 
			end
			else begin
				ma_sel2 = 1; ex_sel1 = 1; wb_sel1 = 1; ex_sel2 = 1; wb_sel2 = 1; ma_sel1 = 1; 
			end
		end
		
		if((buffer[3][15:12] == 4'b0100) & (buffer[0][15:12] == 4'b0101)) begin
			//Register file vs memory access stage source a
			if (buffer[0][11:9] == buffer[3][11:9]) begin
				ma_sel1 = 1; ex_sel1 = 1; wb_sel2 = 0; ex_sel2 = 1; ma_sel2 = 1; wb_sel1 = 1; 
			end
			else begin
				ma_sel1 = 1; ex_sel1 = 1; wb_sel2 = 1; ex_sel2 = 1; ma_sel2 = 1; wb_sel1 = 1; 
			end
		end
		
// Load and Store instruction data dependency
//----------------------------------------------------------------------------------------
// Load and JLR data dependency

		



		
//		else begin
//			whichIF = 15'd0;
//			ma_sel1 = 1; ma_sel2 = 1; ex_sel1 = 1; wb_sel1 = 1; ex_sel2 = 1; wb_sel2 = 1;
//		end
	end
endmodule