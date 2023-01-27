module timer(
	input clk,
	input reset,
	input start_stop,
	input [9:0] switches,
	output [7:0] dig5, dig4, dig3, dig2, dig1, dig0,
	output buzzer);
	
	reg [1:0] state,next;
	reg [6:0] mm;
	reg [5:0] ss;
	reg [6:0] hs;
	wire newClk;
	wire buzzer_tmp;
	
	parameter SET = 2'b00, RUN = 2'b01, PAUSE = 2'b10, BEEP = 2'b11;
	
	// transition logic 
	always_comb begin
		case(state)
			SET: next = start_stop ? SET : RUN;
			RUN: next = start_stop ? (({mm,ss,hs} == 20'd0) ? BEEP : RUN) : PAUSE;
			PAUSE: next = start_stop ? PAUSE : RUN;
			BEEP: next = BEEP;
		endcase
	end
	
	// output logic
	assign buzzer = (state == BEEP) ? buzzer_tmp : 1'b0;
	
	// state register
	always@(posedge clk) begin
		if(~reset)
			state <= SET;
		else
			state <= next;
	end
	
	// Timer
	
	// counter for mm
	always@(posedge newClk) begin
		if(state == SET)
			mm <= switches / 60;
		else if(state == RUN) begin
			if(mm == 7'd0)
				mm <= 7'd0;
			else begin
				if((ss == 6'd0) && (hs == 7'd0))
					mm <= mm - 7'd1;
				else
					mm <= mm;
			end
		end
		else if(state == PAUSE)
			mm <= mm;
		else
			mm <= 7'd0;
	end
	
	// counter for ss
	always@(posedge newClk) begin
		if(state == SET)
			ss <= switches % 60;
		else if(state == RUN) begin
			if((ss == 6'd0) && (mm != 7'd0) && (hs == 7'd0))
				ss <= 6'd59;
			else if((ss == 6'd0) && (mm == 7'd0))
				ss <= 6'd0;
			else begin
				if(hs == 7'd0)
					ss <= ss - 6'd1;
				else
					ss <= ss;
			end
		end
		else if(state == PAUSE)
			ss <= ss;
		else
			ss <= 6'd0;
	end
	
	// counter for hs
	always@(posedge newClk) begin
		if(state == SET)
			hs <= 7'd0;
		else if(state == RUN) begin
			if((hs == 7'd0) && (ss != 6'd0))
				hs <= 7'd99;
			else if((hs == 7'd0) && (ss == 6'd0) && (mm != 7'd0))
				hs <= 7'd99;
			else if((hs == 7'd0) && (ss == 6'd0) && (mm == 7'd0))
				hs <= 7'd00;
			else
				hs <= hs - 7'd1;
		end
		else if(state == PAUSE)
			hs <= hs;
		else
			hs <= 7'd0;
	end

	sevenSegDispFlesh u0 (.mode(state == BEEP),.clk(newClk), .min(mm), .sec(ss), .hs(hs), .dig5(dig5), .dig4(dig4), .dig3(dig3), .dig2(dig2), .dig1(dig1), .dig0(dig0));
	clk_div #(.SPEED(24_9999)) u1 (.reset(reset),.clk(clk),.newClk(newClk));
	clk_div #(.SPEED(24_9999)) u2 (.reset(reset),.clk(clk), .newClk(buzzer_tmp));
	
endmodule