  module clk_div(
	input clk,
	input reset,
	output reg newClk);
	parameter SPEED = 24_9999;
    reg[20:0] cnt = 0;
	always@(posedge clk or posedge reset) begin
		if(reset) begin
			cnt <= 0;
			newClk <= 0;
		end
		else begin
			if(cnt == SPEED) begin
				newClk <= !newClk;
				cnt <= 0;
			end
			else
				cnt <= cnt + 1;
		end
	end
	

 
 endmodule