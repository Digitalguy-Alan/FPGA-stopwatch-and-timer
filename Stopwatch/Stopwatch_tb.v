`timescale 1 ns/ 100 ps

module Stopwatch_tb();
	reg CLK_50;
	reg reset_n;
	reg start_stop;
	reg hold;
	// wires                                               
	wire [7:0]  ten_mins_seven_seg;
	wire [7:0]  one_min_seven_seg;
	wire [7:0]  ten_secs_seven_seg;
	wire [7:0]  one_sec_seven_seg;
	wire [7:0]  tenths_seven_seg;
	wire [7:0]  hundredths_seven_seg;
	wire overflow_flag;

Stopwatch i1 (
 
	.CLK_50(CLK_50),
	.reset_n(reset_n),
	.start_stop(start_stop),
	.hold(hold),
	
	.ten_mins_seven_seg(ten_mins_seven_seg),
	.one_min_seven_seg(one_min_seven_seg),
	.ten_secs_seven_seg(ten_secs_seven_seg),
	.one_sec_seven_seg(one_sec_seven_seg),
	.tenths_seven_seg(tenths_seven_seg),
	.hundredths_seven_seg(hundredths_seven_seg),
	.overflow_flag(overflow_flag)
);

always  #10	CLK_50 = ~CLK_50;

initial
begin
	CLK_50 = 0;
	reset_n = 0;
	start_stop = 1;
	hold = 1;
	
	#100
	reset_n = 1;

	#1000
	start_stop = 0;
	#100
	start_stop = 1;

	#20000
	hold = 0;
	#10000
	hold = 1;

	#10000000
	$stop;
end	


endmodule

