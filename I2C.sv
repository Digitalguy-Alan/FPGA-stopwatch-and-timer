`timescale 1ns/1ns
module I2C #(parameter MAX_BYTES = 6) (clk, rst, driverDisable, deviceAddr_d, regAddr_d, numBytes_d, dataIn_d, dataOut, write_d, start, done, scl, sda);
	
	// bus width parameter:
	localparam NUMBYTES_WIDTH = $clog2(MAX_BYTES + 2);
	
	// FSM state declarations
	localparam RESET = 0;
	localparam START = 1;
	localparam DEV_ADDR = 2;
	localparam REG_ADDR = 3;
	localparam DATA = 4;
	localparam STOP = 5;
	localparam IDLE = 6;
	
	// input / output ports
	input clk; 								//note: clk is 4x the actual speed of i2c communication
	input rst;
	input write_d;							//write = write enable
	input start; 				 			//start = triggers FSM to start when start == 1
	input driverDisable;					//driverDisable = disables FSM when == 1
	input[6:0] deviceAddr_d;						//device address
	input[7:0] regAddr_d;							//register address to read/write from
	input[NUMBYTES_WIDTH-1:0] numBytes_d;		//number of bytes to read/write
	input[7:0] dataIn_d [MAX_BYTES-1:0];		// data input bus
	
	output reg [7:0] dataOut[MAX_BYTES-1:0] = '{default: '0};	//dataOut = data output bus, note '{default: '0}; is a parameterized version of setting = 0;
	output done; 							//done = 1 when finished with a transmission
	output reg scl = 1'b0;				//scl = I2C clock output
	inout sda;								//sda = I2C data in/out
	
	
	// Tri-state buffer
	reg in = 0;		//input value to write when we=1
	reg we = 1;		//write enable for tri-state buffer
	wire out;		//output from buffer when we=0
	IOBuffer sdaBuff(.in(in), .out(out), .enable(we), .port(sda));

	// FSM state
	reg [2:0] state = RESET;
	reg [2:0] next_state = RESET;
	
	
	// input buffers
	// These are essentially just registers that hold commands after start is triggered.
	reg write = 1'b0;							// determines if writing/reading to peripheral
	reg [6:0] deviceAddr;					//device address to talk to
	reg [NUMBYTES_WIDTH - 1:0] numBytes;	//input # of bytes to read/write. NOTE: This is 1 bit larger since we will include reg/dev addresses as bytes and add this to the numbytes_d
	reg [7:0] dataIn [MAX_BYTES-1:0];	//data input register
	reg [7:0] regAddr;						//register address
	
	// internal variables
	reg [7:0] data2send;				//data to send (used as buffer for individual bytes)
	reg [7:0] byteOut;						//byte output (used as buffer for individual bytes)
	reg [NUMBYTES_WIDTH-1:0] byte_cnt = '{default: '0};	//counts # of bytes sent/received
	reg [3:0] bit_cnt = 4'b0;			//counts # of bits
	reg [1:0] subbit_cnt = 2'b0;		//counts # of sub-bit ticks
	reg [7:0] delayCounter = 8'b0;	//counts # of delay ticks after command is finished
	
	// flags
	reg done_sending = 0;	//triggered when each state is finished
	reg sending_byte = 0;	//high if currently writing, low if currently reading
	reg data_start = 0;		//high if currently sending / receiving data
	reg notAcked = 0;			//high if peripheral returned NACK
	
	assign done = state == RESET; //set done output HIGH when FSM returns to RESET.
	
	
	// FSM sequential logic
	// This block handles setting state=next_state
	always @(negedge clk) begin
		if(rst || driverDisable) begin
			state <= IDLE;
			write <= 0;
			deviceAddr = 0;
			numBytes <= 0;
			dataIn <= '{default: '0};
			regAddr <= 0;
		end
		else begin
			/*
				TODO: Set state to next_state, and all correct values 
				for variables in the block above.
				
				Think about all the signals with _d in the name as inputs to a flip flop. We want to assign those outputs here on the clock edge!
				
				Note that numBytes_d comes from the upper level Nunchuck driver and corresponds of how many bytes of data to read or write
				However, in this implementation, numBytes includes the byte containing the dev_addr + r/w and the byte for the register address (for writes)
				The reason for this is so we can reuse the code for sending/recieving bytes of data!
				
				But, you should adjust numBytes to accomodate. If we are reading, we only send one byte before sending the data. If writing, we also send reg address!
				
			*/
			if(~driverDisable) begin
				state <= next_state;
				if(state == START) begin
					write <= write_d;
					deviceAddr <= deviceAddr_d;
					numBytes <= numBytes_d;
					dataIn <= dataIn_d;
					regAddr <= regAddr_d;
				end
			end else begin
				state <= state;
				write <= write;
				deviceAddr <= deviceAddr;
				numBytes <= numBytes;
				dataIn <= dataIn;
				regAddr <= regAddr;
			end
			
		end
	end
	
	// I2C communication logic
	// This block does the dirty work!
	always @(posedge clk) begin
		// Set everything to 0 on reset or disable
		if(rst || driverDisable) begin
			subbit_cnt <= 0;
			bit_cnt <= 0;
			done_sending <= 0;
			we <= 0;
			in <= 0;
			scl <= 0;
			notAcked <= 0;
			byteOut <= 8'b0;
			byte_cnt <= 0;
			if(rst) begin
				dataOut <= '{default: '0};
			end
		end else begin

			// increase subbit_cnt each cycle if not idle
			if(state != RESET && state != IDLE) begin
				subbit_cnt <= subbit_cnt + 1;
			end else begin
				subbit_cnt <= 0;
			end
			
			// increase delayCounter while idle
			if(state == IDLE) begin
				delayCounter <= delayCounter + 1;
			end else begin
				delayCounter <= 0;
			end
			
			// send start or stop signal
			if (state == START || state == STOP) begin
				byte_cnt <= 0;
				done_sending <= 0;
				case (subbit_cnt)
					0: begin
						//TODO
						scl <= 0;
						if(state == START) begin
							we <= 1;
							in <= 1;
						end
						else begin
							we <= 1;
							in <= 0;
						end
					end
					1: begin
						//TODO
						scl <= !scl;
						if(state == START) begin
							we <= 1;
							in <= 1;
						end
						else begin
							we <= 1;
							in <= 0;
						end
					end
					2: begin
						//TODO
						if(state == START) begin
							we <= 1;
							in <= 0;
						end
						else begin
							we <= 1;
							in <= 1;
						end
					end
					3: begin
						//TODO
						scl <= !scl;
						done_sending <= 1;
						if(state == START) begin
							we <= 1;
							in <= 0;
						end
						else begin
							we <= 1;
							in <= 1;
						end
					end
				endcase
				
			// send or receive data
			end else if (data_start) begin
				if(bit_cnt < 8) begin
					done_sending <= 0;
					case (subbit_cnt)
						0: begin
							scl <= 0;
							if(sending_byte) begin
								//TODO
								we <= 1;
								in <= data2send[7 - bit_cnt];
							end else begin
								we <= 0;
							end
						end
						1: begin
							//TODO
							scl <= !scl;
							
						end
						2: begin
							//TODO
							if(!sending_byte) begin
								we <= 0;
								byteOut[7 - bit_cnt] <= out;
							end
						end
						3: begin
							//TODO
							scl <= !scl;
							bit_cnt <= bit_cnt + 1;
						end
					endcase
					
				//check or send ACK
				end else begin
					case (subbit_cnt)
						//TODO
						0: begin
							scl <= 0;
							if(!sending_byte) begin
								we <= 1;
								in <= (byte_cnt == numBytes - 1) ? 1 : 0;
								dataOut[byte_cnt] = byteOut;
							end else begin
								we <= 0;
								notAcked <= out;
							end
						end
						1: begin
							scl <= !scl;
						end
						2: begin
							// do nothing
						end
						3: begin
							scl <= !scl;
							done_sending <= 1;
							bit_cnt <= 0;
							if(state == DATA)
								byte_cnt <= byte_cnt + 1;
						end
					endcase
				end
				
			// idle state
			end else begin
				done_sending <= 0;
			end
		end
	end

	
	// FSM combinational logic
	always_comb begin
		case (state)
			
			// Reset state
			RESET: begin
				data_start = 0;
				sending_byte = 0;
				data2send = '{default: '0};
				if(start) begin
					next_state = START;
				end else begin
					next_state = IDLE;
				end
			end
			
			// Send START signal
			START: begin
				//TODO
				data_start = 0;
				sending_byte = 0;
				data2send = '{default: '0};
				if(done_sending) begin
					next_state = DEV_ADDR; //TODO
				end else begin
					next_state = START; //TODO
				end
			end
				
			// Send device address
			DEV_ADDR: begin
				//send 7 bits for address
				data_start = 1;
				sending_byte = 1;
				data2send = {deviceAddr, ~write};//TODO
				if(done_sending) begin
					if(notAcked) begin
						//TODO
						next_state = IDLE;
					end else begin
						next_state = write ? REG_ADDR : DATA; //write signal determines whether we need to send a reg address or can go to read
					end
				end
				else begin
					next_state = DEV_ADDR;//TODO;
				end
				
			end
			
			
			// Send register address for write
			REG_ADDR: begin
				//TODO
				data_start = 1;
				sending_byte = 1;
				data2send = regAddr;
				if(done_sending && (subbit_cnt == 3 || subbit_cnt == 0)) begin
					if(notAcked) begin
						next_state = IDLE;
					end else begin
						next_state = (numBytes == 0) ? STOP : DATA; 
					end
				end
				else begin
					next_state = REG_ADDR;
				end
			end
			
			// read / write bulk DATA
			DATA: begin

				//TODO
				data_start = 1;
				sending_byte = write;
				data2send = dataIn[byte_cnt];
				//dataOut[byte_cnt] = byteOut;
				if(done_sending && (subbit_cnt == 3 || subbit_cnt == 0)) begin
					if(notAcked && sending_byte) begin
						//TODO
						next_state = IDLE;
					end else begin
						if (numBytes == byte_cnt) begin
							//TODO
							next_state = STOP;
						end
						else begin
							//TODO
							next_state = DATA;
						end
					end
				end
				else begin
					//TODO
					next_state = DATA;
				end
			end
			
			
			// Send STOP signal
			STOP: begin
				//TODO
				data_start = 0;
				sending_byte = 0;
				data2send = '{default: '0};
				if(done_sending) begin
					next_state = IDLE; //TODO
				end else begin
					next_state = STOP; //TODO
				end
			end

			// Adds delay to space out individual commands
			IDLE: begin
				//TODO
				data_start = 0;
				sending_byte = 0;
				data2send = '{default: '0};
				if(delayCounter > 10) begin
					//TODO
					next_state = RESET;
				end else begin
					//TODO
					next_state = IDLE;
				end
			end
			
			default: next_state = IDLE;
		endcase
	end
endmodule