module register_file (rst, clk, reg_write_en_1, reg_write_en_2, reg_write_dest, reg_write_data_1, reg_write_data_2, reg_read_addr_1, reg_read_data_1, reg_read_addr_2, reg_read_data_2, r7); 

	input		  		rst,clk,reg_write_en_1, reg_write_en_2; 
	input  [ 2:0] 	reg_write_dest;
	input  [15:0] 	reg_write_data_1;  
	input  [15:0] 	reg_write_data_2;
	input  [ 2:0] 	reg_read_addr_1; 
	output [15:0] 	reg_read_data_1;   
	input  [ 2:0] 	reg_read_addr_2;  
	output [15:0] 	reg_read_data_2;
	output reg [15:0]	r7;

	reg    [15:0] 	reg_array [0:6]; 
	reg	 [15:0]  reg_array7;	 

	always @ (*) begin	  
		if(rst) begin  
			reg_array[0] <= 16'h0000;  
			reg_array[1] <= 16'h0002;  
			reg_array[2] <= 16'h0003;  
			reg_array[3] <= 16'h0004;  
			reg_array[4] <= 16'h0005;  
			reg_array[5] <= 16'h0006;  
			reg_array[6] <= 16'hFFFF;       
		end  
		else begin  
			if(reg_write_en_1 == 1'b1) begin  
				reg_array[reg_write_dest] <= reg_write_data_1;  
			end  
		end  
	end  
	
	always@(posedge clk) begin
		if(rst) begin  
			reg_array7 <= 16'h0000;       
		end  
		else begin
			reg_array7 <= reg_array7 + 2;
			r7 = reg_array7;
			if((reg_write_en_1 == 1'b1) & (reg_write_dest == 3'b111)) begin  
				reg_array7 <= reg_write_data_1;  
			end
			else if(reg_write_en_2 == 1'b1) begin
				reg_array7 <= reg_write_data_2;
			end
		end
		
	end
	
	assign reg_read_data_1 = ( reg_read_addr_1 == 0)? 16'b0 : reg_array[reg_read_addr_1];  
	assign reg_read_data_2 = ( reg_read_addr_2 == 0)? 16'b0 : reg_array[reg_read_addr_2];
endmodule   