module testbench();

	reg rst, clk;

	pipeline processor(clk, rst);

	integer i;
	
	initial begin
		clk = 1'b0;
		rst = 1'b0; #10;  rst = 1'b1;   #20;   rst = 1'b0;
	end
	
	initial begin
		for (i=0;i<=100;i=i+1) begin
			#10; clk = ~clk;
		end
	end
endmodule