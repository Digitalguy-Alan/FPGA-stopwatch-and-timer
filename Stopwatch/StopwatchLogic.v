module StopwatchLogic(
	input CLK_100Hz,
	input reset_n,
	input start_stop,
	input hold,
	output [6:0] stopwatch_unit_mins,
	output [5:0] stopwatch_unit_secs,
	output [6:0] stopwatch_unit_decs,
	output reg stopwatch_overflow
);

reg	[6:0]	mins_buf;
reg	[6:0]	secs_buf;
reg	[6:0]	decs_buf;
reg			overflow;
localparam ms_init  = 7'd0;
localparam sec_init = 7'd0;
localparam min_init = 7'd0;


assign	stopwatch_unit_mins = mins_buf;
assign	stopwatch_unit_secs = secs_buf;
assign	stopwatch_unit_decs = decs_buf;

reg			CNT_EN;
always@(negedge start_stop or negedge reset_n)
begin
	if(reset_n == 0)
		CNT_EN <= 1'b0;
	else
		CNT_EN <= ~ CNT_EN;
end

reg		MS_CP;
always @(posedge CLK_100Hz or negedge reset_n)
begin
	if(reset_n == 0)
		begin
			decs_buf <= ms_init;
			MS_CP <= 0;
		end
	else 
		if(CNT_EN)
			if(hold == 1)
			begin
				if(decs_buf <= 7'd99)
					begin
						decs_buf <= decs_buf + 1'b1;
						MS_CP <= 0;
					end
				else
					begin
						decs_buf <= 7'b0;
						MS_CP <= 1;
					end
			end
		else
			begin
				decs_buf <= decs_buf;
				MS_CP <= MS_CP;
			end
end

reg		SEC_CP;
always @(posedge MS_CP or negedge reset_n)
begin
	if(reset_n == 0)
		begin
			secs_buf <= sec_init;
			SEC_CP <= 0;
		end
	else 
		if(CNT_EN)
			if(secs_buf < 6'd59)
				begin
					secs_buf <= secs_buf + 1'b1;
					SEC_CP <= 0;
				end
			else
				begin
					secs_buf <= 6'b0;
					SEC_CP <= 1;
				end
		else
			begin
				secs_buf <= secs_buf;
				SEC_CP <= SEC_CP;
			end
end

reg		MIN_CP;
always @(posedge SEC_CP or negedge reset_n)
begin
	if(reset_n == 0)
		begin
			mins_buf <= min_init;
			MIN_CP <= 0;
		end
	else
		if(CNT_EN)
			if(mins_buf < 7'd99)
				begin
					mins_buf <= mins_buf + 1'b1;
					MIN_CP <= 0;
				end
			else
				begin
					mins_buf <= 7'b0;
					MIN_CP <= 1;
				end
		else
			begin
				mins_buf <= mins_buf;
				MIN_CP <= MIN_CP;
			end
end

always @(posedge MIN_CP or negedge reset_n)
begin
	if(reset_n == 0)
		stopwatch_overflow <= 0;
	else
		stopwatch_overflow <= 1;
end


endmodule
	
