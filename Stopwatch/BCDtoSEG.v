module BCDtoSEG(
   input [3:0] BCD,
	input		dp,
   output reg [7:0] SEG
);

always@(*)
begin
	case(BCD)	
		4'h0: SEG = {dp,7'b1000000};	
		4'h1: SEG = {dp,7'b1111001};	
		4'h2: SEG = {dp,7'b0100100};	
		4'h3: SEG = {dp,7'b0110000};	
		4'h4: SEG = {dp,7'b0011001};	
		4'h5: SEG = {dp,7'b0010010};	
		4'h6: SEG = {dp,7'b0000010};	
		4'h7: SEG = {dp,7'b1111000};	
		4'h8: SEG = {dp,7'b0000000};	
		4'h9: SEG = {dp,7'b0010000};	
		default: SEG = {dp,7'b1111111}; //turn off
	endcase
end  

endmodule










