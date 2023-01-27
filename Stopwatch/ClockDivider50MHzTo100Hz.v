module ClockDivider50MHzTo100Hz (
	input CLK_50_MHz,
	input reset_n,
	output reg CLK_100Hz
);

	reg [20:0] cnt=0;
	always@(posedge CLK_50_MHz or negedge reset_n) 
		begin  
			if(reset_n==0)  
				begin 
					cnt<=0;
					CLK_100Hz<=0;
				end
			else
				begin 
					if(cnt==249999)
						begin  
							CLK_100Hz<=!CLK_100Hz;
							cnt<=0;
						end
					else
						cnt<=cnt+1;
				end
		end	
endmodule
