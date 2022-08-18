module dflipflop(d, clock, q);

input clock, d;
output reg q;

always @ (posedge clock) begin
	q <= d;
end
endmodule