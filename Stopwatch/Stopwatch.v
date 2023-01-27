module Stopwatch(
	input CLK_50,
	input reset_n,
	input start_stop,
	input hold,
	output [7:0] ten_mins_seven_seg,
	output [7:0] one_min_seven_seg,
	output [7:0] ten_secs_seven_seg,
	output [7:0] one_sec_seven_seg,
	output [7:0] tenths_seven_seg,
	output [7:0] hundredths_seven_seg,
	output overflow_flag
);

wire CLK_100Hz;
wire [6:0] mins;
wire [5:0] secs;
wire [6:0] decs;

ClockDivider50MHzTo100Hz U01 (
	.CLK_50_MHz(CLK_50),
	.reset_n(reset_n),
	.CLK_100Hz(CLK_100Hz)
);

StopwatchLogic U02(
	.CLK_100Hz(CLK_100Hz),
	.reset_n(reset_n),
	.start_stop(start_stop),
	.hold(hold),
	.stopwatch_unit_mins(mins),
	.stopwatch_unit_secs(secs),
	.stopwatch_unit_decs(decs),
	.stopwatch_overflow(overflow_flag)
);

SevenSegEncoder U03(
	.stopwatch_unit_mins(mins),
	.stopwatch_unit_secs(secs),
	.stopwatch_unit_decs(decs),
	.hex_10_mins(ten_mins_seven_seg),
	.hex_1_min(one_min_seven_seg),
	.hex_10_secs(ten_secs_seven_seg),
	.hex_1_sec(one_sec_seven_seg),
	.hex_hundredths(hundredths_seven_seg),
	.hex_tenths(tenths_seven_seg)
);


endmodule
