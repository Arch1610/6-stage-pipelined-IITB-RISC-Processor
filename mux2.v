module mux2(a, b, sel, y);

input [15:0] a, b;
input sel;
output reg [15:0] y;

always @ (*) begin
	case(sel) 
		1'b0 : begin
			y = a;
		end
		1'b1 : begin
			y = b;
		end
	endcase
end
endmodule