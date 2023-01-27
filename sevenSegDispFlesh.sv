module sevenSegDispFlesh(mode, clk, min, sec, hs, dig5, dig4, dig3, dig2, dig1, dig0);
   input mode;
	input clk;
	input [6:0] min;
	input [5:0] sec;
	input [6:0] hs;
	output [7:0] dig5, dig4, dig3, dig2, dig1, dig0; //5 to 0 are the 6 displays on the board from left to right
	reg [3:0] input5, input4, input3, input2, input1, input0; 
	wire [7:0] dig5_tmp, dig4_tmp, dig3_tmp, dig2_tmp, dig1_tmp, dig0_tmp;
	
	reg [6:0] cnt = 0;
	
	sevenSegDigit digit5(input5, dig5_tmp); 
	sevenSegDigit digit4(input4, dig4_tmp);
	sevenSegDigit digit3(input3, dig3_tmp);
	sevenSegDigit digit2(input2, dig2_tmp); 
	sevenSegDigit digit1(input1, dig1_tmp);
	sevenSegDigit digit0(input0, dig0_tmp);
	
	always_comb begin
		input0 = hs % 10;
		input1 = (hs - input0)/10;
		input2 =  sec % 10;
		input3 = (sec - input2)/10;
		input4 =  min % 10;
		input5 = (min - input4)/10;
	end
	always@(posedge clk) begin
		cnt <= cnt + 1;
	end
	always_comb begin
	   if(mode == 0)
			{dig5, dig4, dig3, dig2, dig1, dig0} = {dig5_tmp, dig4_tmp, dig3_tmp, dig2_tmp, dig1_tmp, dig0_tmp};
		else begin
			if(cnt <= 7'd63)
				{dig5, dig4, dig3, dig2, dig1, dig0} = {dig5_tmp, dig4_tmp, dig3_tmp, dig2_tmp, dig1_tmp, dig0_tmp};
			else
				{dig5, dig4, dig3, dig2, dig1, dig0} = 48'b1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111;
		end
	end
	
	
endmodule