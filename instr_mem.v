module instr_mem (  
	input     		[15:0]  pc,  
	output wire    [15:0]  instruction );  

	wire [6:0] rom_addr = {1'b0,pc[6:1]};  
	reg [15:0] rom[0:2**6];  
//	R0 = 0 (read only)
// Instr    : 0 : 1 : 2 : 3 : 4 : 5 : 6 : 7 : 8 : 9 : 10 : 11 : 12 : 13 : 14 : 15 : 16 : 17 : 18 : 19 :
//---------------------------------------------------------------------------------------------------------
//	R1 = 2   : 2 : 2 : 2 : 2 : 2 : 2 : 2 : 2 : 2 : 2 : 2  : 2  : 2  : 2  : 2  : 2  : 2  : 2  : 2  : 2  :
//	R2 = 3   : 3 : 3 : 3 : 3 : 3 : 3 : 3 : 0 : 0 : 0 : 0  : 0  : 0  : 0  : 0  : 9  : 9  : 9  : 9  : 11 :
//	R3 = 4   : 5 : 5 : 5 : 5 : 5 : 5 : 5 : 5 : 5 : 5 : 5  : 5  : 5  : 5  : 5  : 5  : 9  : 9  : 9  : 9  :
//	R4 = 5   : 5 : 5 : 5 : 8 : 8 : 8 : 7 : 7 : 0 : 7 : 7  : 0  : 128: 7  : 7  : 7  : 7  : 11 : 11 : 11 :
//	R5 = 6   : 6 : 6 : 6 : 6 : 3 : 1 : 1 : 1 : 1 : 1 : 4  : 4  : 4  : 4  : 9  : 9  : 9  : 9  : 11 : 11 :
//	R6 = FFFF: " : " : " : " : " : " : " : " : " : " : "  : "  : "  : "  : "  : "  : "  : "  : "  : "  :
//	R7 = don't touch it.
						  //Sa  Sb  Dest
	initial begin    //Ra  Rb  Rc	
	rom[0]  = 16'b1011_011_000_000_1_11; // JLR R3 R2 ------ put 2 in R3 and 3 in R7 
	rom[1]  = 16'b0001_001_101_100_0_00; // ADC R4 = R1 + R5 = 8 
	rom[2]  = 16'b0001_001_101_101_0_00; // ADC R4 = R1 + R5 = 8 
	//rom[0]  = 16'b0001_001_010_011_0_00; // ADD R3 = R1 + R2 = 5 (normal add)
	//rom[1]  = 16'b0001_001_011_100_0_10; // ADC R4 = R1 + R3 = 7 (should not add up)
	//rom[2]  = 16'b0001_001_011_100_0_01; // ADZ R4 = R1 + R3 = 7 (should not add up)
	rom[3]  = 16'b0001_001_010_100_0_11; // ADL R4 = R1 + R2 = 8 (normal add)
	rom[4]  = 16'b0000_001_101_000001;   // ADI R5 = R1 + 01 = 3 (normal add)
	rom[5]  = 16'b0000_001_101_111111;   // ADI R5 = R1 + FFFF = 1 (carry = 1)
	rom[6]  = 16'b0001_001_011_100_0_10; // ADC R4 = R1 + R3 = 7 (ADC working)
	rom[7]  = 16'b0010_001_011_010_0_00; // NDU R2 = R1 & R3 = 0 (zero = 1) (normal NDU)
	rom[8]  = 16'b0010_001_011_100_0_01; // NDZ R4 = R1 & R3 = 0 (zero = 1) (NDZ working)
	rom[9]  = 16'b0001_001_011_100_0_01; // ADZ R4 = R1 + R3 = 7 (ADZ working)
	rom[10] = 16'b0001_011_110_101_0_00; // ADD R5 = R3 + R6 = 4 (carry = 1) (normal ADD)
	rom[11] = 16'b0010_001_011_100_0_10; // NDC R4 = R1 & R3 = 0 (zero = 1) (NDC working)
	rom[12] = 16'b0011_100_000_000_0_01; // LHI R4 = 128 			 (normal load immediate)
	rom[13] = 16'b0001_001_011_100_0_00; // ADD R4 = R1 + R3 = 7 (normal ADD)
	rom[14] = 16'b0001_100_001_101_0_00; // ADD R5 = R4 + R1 = 9 (Data dependency execution stage)
	rom[15] = 16'b0001_100_001_010_0_00; // ADD R2 = R4 + R1 = 9 (Data dependency memory access stage)
	rom[16] = 16'b0001_100_001_011_0_00; // ADD R3 = R4 + R1 = 9 (Data dependency write back stage)
	rom[17] = 16'b0001_001_101_100_0_00; // ADD R4 = R1 + R3 = 11 (Data dependency execution stage)
	rom[18] = 16'b0001_001_011_101_0_00; // ADD R5 = R1 + R3 = 11 (Data dependency memory access stage)
	rom[19] = 16'b0001_001_011_010_0_00; // ADD R2 = R1 + R3 = 11 (Data dependency write back stage)
	//rom[20] =  //
	end  
	assign instruction = (pc[15:0] < 32 )? rom[rom_addr[3:0]]: 16'd0;  
 endmodule