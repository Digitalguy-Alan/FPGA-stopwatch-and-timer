module SevenSegEncoder(
	input [6:0] stopwatch_unit_mins,
	input [5:0] stopwatch_unit_secs,
	input [6:0] stopwatch_unit_decs,
	output [7:0] hex_10_mins,
	output [7:0] hex_1_min,
	output [7:0] hex_10_secs,
	output [7:0] hex_1_sec,
	output [7:0] hex_hundredths,
	output [7:0] hex_tenths
);

wire [11:0] BCD_mins;
wire [11:0] BCD_secs;
wire [11:0] BCD_decs;

BCDEncoder U10(
    .BinaryIn({1'b0,stopwatch_unit_mins}),
    .BCDOut(BCD_mins)
    );
	
BCDEncoder U11(
    .BinaryIn({2'b00,stopwatch_unit_secs}),
    .BCDOut(BCD_secs)
    );

BCDEncoder U12(
    .BinaryIn({1'b0,stopwatch_unit_decs}),
    .BCDOut(BCD_decs)
    );

BCDtoSEG U21(
	.BCD(BCD_mins[7:4]),
	.dp(1'b1),
	.SEG(hex_10_mins)
);

BCDtoSEG U22(
	.BCD(BCD_mins[3:0]),
	.dp(1'b0),
	.SEG(hex_1_min)
);

BCDtoSEG U23(
	.BCD(BCD_secs[7:4]),
	.dp(1'b1),
	.SEG(hex_10_secs)
);

BCDtoSEG U24(
	.BCD(BCD_secs[3:0]),
	.dp(1'b0),
	.SEG(hex_1_sec)
);

BCDtoSEG U25(
	.BCD(BCD_decs[7:4]),
	.dp(1'b1),
	.SEG(hex_tenths)
);

BCDtoSEG U26(
	.BCD(BCD_decs[3:0]),
	.dp(1'b1),
	.SEG(hex_hundredths)
);

endmodule
