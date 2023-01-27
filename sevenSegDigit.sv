module sevenSegDigit(input [3:0] decimalNum, output reg [7:0] dispBits);
	
	always_comb begin 
		case(decimalNum)
			4'd0: dispBits = 8'b11000000;
			4'd1: dispBits = 8'b11111001;
			4'd2: dispBits = 8'b10100100;
			4'd3: dispBits = 8'b10110000;
			4'd4: dispBits = 8'b10011001;
			4'd5: dispBits = 8'b10010010;
			4'd6: dispBits = 8'b10000010;
			4'd7: dispBits = 8'b11111000;
			4'd8: dispBits = 8'b10000000;
			4'd9: dispBits = 8'b10010000;
			default: dispBits = 8'b1111_1111;
		endcase
	end

endmodule