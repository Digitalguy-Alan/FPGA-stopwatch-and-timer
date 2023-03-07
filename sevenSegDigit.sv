module sevenSegDigit(input [3:0] decimalNum, input dot, output reg [7:0] dispBits);
	always_comb begin 
		case(decimalNum)
			4'd0: dispBits = {dot, 7'b100_0000};
			4'd1: dispBits = {dot, 7'b111_1001};
			4'd2: dispBits = {dot, 7'b010_0100};
			4'd3: dispBits = {dot, 7'b011_0000};
			4'd4: dispBits = {dot, 7'b001_1001};
			4'd5: dispBits = {dot, 7'b001_0010};
			4'd6: dispBits = {dot, 7'b000_0010};
			4'd7: dispBits = {dot, 7'b111_1000};
			4'd8: dispBits = {dot, 7'b000_0000};
			4'd9: dispBits = {dot, 7'b001_0000};
			default: dispBits = 8'b1111_1111;
		endcase
	end

endmodule