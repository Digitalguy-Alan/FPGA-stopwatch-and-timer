module nunchuck_top(clk, rst, sda, scl, vdd, accel_x, bits);
	input clk, rst;
	inout sda;
	output scl;
	output vdd;
	output [9:0] accel_x;
	output [7:0] bits [5:0];
	
	wire [7:0] stick_x, stick_y;
	wire [9:0] accel_y, accel_z;
	wire [3:0] disp [5:0];
	wire [7:0] bits [5:0];
	
	assign vdd = 1'b1;
	assign disp[5] = stick_y / 100;
	assign disp[4] = (stick_y % 100) / 10;
	assign disp[3] = stick_y  % 10;
	assign disp[2] = stick_x / 100;
	assign disp[1] = (stick_x % 100) / 10;
	assign disp[0] = stick_x % 10;
	
	nunchuckDriver u0 (.clock(clk), .SDApin(sda), .SCLpin(scl), .stick_x(stick_x), .stick_y(stick_y), .accel_x(accel_x), .accel_y(accel_y), .accel_z(accel_z), .z(z), .c(c),.polling_clock(), .i2c_clock(), .rst(~rst));
	sevenSegDigit u5 (.decimalNum(disp[5]), .dot(1'b1), .dispBits(bits[5]));
	sevenSegDigit u4 (.decimalNum(disp[4]), .dot(1'b1), .dispBits(bits[4]));
	sevenSegDigit u3 (.decimalNum(disp[3]), .dot(z), .dispBits(bits[3]));
	sevenSegDigit u2 (.decimalNum(disp[2]), .dot(c), .dispBits(bits[2]));
	sevenSegDigit u1 (.decimalNum(disp[1]), .dot(1'b1), .dispBits(bits[1]));
	sevenSegDigit u (.decimalNum(disp[0]), .dot(1'b1), .dispBits(bits[0]));
endmodule