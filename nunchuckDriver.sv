module nunchuckDriver(clock, SDApin, SCLpin, stick_x, stick_y, accel_x, accel_y, accel_z, z, c, rst);
	input clock, rst;
	inout SDApin;
	output SCLpin;
	output [7:0] stick_x, stick_y;
	output [9:0] accel_x, accel_y, accel_z;
	output z, c;
	
	localparam NUMBYTES_WIDTH = $clog2(MAX_BYTES + 2);
	
	// State name parameters:
	localparam HANDSHAKE1 = 0;
	localparam HANDSHAKE2 = 1;
	localparam WRITE = 2;
	localparam READ = 3;
	localparam READ2 = 5;
	localparam DONE = 4;

	localparam MAX_BYTES = 6; //Parameter for I2C low-level (LL) driver, max # of bytes to read/write at once, determines dataIn / Out width.
	
	//localparam I2C_CLOCK_SPEED = //TODO; 	 //400kHz
	localparam MESSAGE_RATE = 24_9999;//TODO; 		 //100Hz is the rate at which we send/read messages
	
	
	
	wire [7:0] dataOut_d [MAX_BYTES-1:0]; //This should be an array of MAX_BYTES bytes 
	reg [7:0] dataOut [MAX_BYTES-1:0];
	//For more advanced designs such as your capstone, we would use RAM instead of a massive port;
	
	//clocks
	//wire i2c_clock, polling_clock;
	reg [1:0] polling_clock_vals = 2'b00;	//controls shift register for polling clock
	
	wire polling_clock, i2c_clock;
	// FSM state
	reg [2:0] state = DONE;						//current driver FSM state
	reg [2:0] next_state = 3'b0;				//next state for FSM, determined by combinational logic
	
	
	// LL driver command arguments
	reg write; 											//write enable for LL (low level) driver
	
	//TO DO: numBytes_d and numBytes' sizes should be based on the parameter MAX_BYTES. Look at dataOut as an example for making the size based on the parameter
	reg [NUMBYTES_WIDTH - 1: 0] numBytes_d; 	//this is the number of bytes to read/write for the particular instruction
	reg [NUMBYTES_WIDTH - 1: 0] numBytes;
	
	reg communicate = 1'b0; 						//Flag that determines whether its time for us to send a new message. Controlled by the polling rate
	reg [6:0] regAddress; 							//memory address for the peripheral device
	reg [6:0] deviceAddr;
	reg [7:0] addr;
	
	reg [7:0] dataIn [MAX_BYTES - 1:0] = '{default: '0};
	reg start_from_write = 0;                          // a flag that prevents the skip of WRITE
	wire driverDisable = state == DONE;			//disables LL driver when idle
	wire done;								    //carries done flag from LL driver
	
	reg handshakeDone = 0;
	reg handshakeStart = 0;

	// submodule declarations
	//	TODO: declare I2C and nunchuckTranslator!
	I2C UUT (.clk(i2c_clock), .rst(rst), .driverDisable(driverDisable), .deviceAddr_d(deviceAddr), .regAddr_d(addr), .numBytes_d(numBytes_d), .dataIn_d(dataIn), .dataOut(dataOut_d), .write_d(write), .start(1'b1), .done(done), .scl(SCLpin), .sda(SDApin));
	
	nunchukTranslate translator_UUT (.data_in(dataOut), .stick_x(stick_x), .stick_y(stick_y), .accel_x(accel_x), .accel_y(accel_y), .accel_z(accel_z), .z(z), .c(c));
	/*
			NOTE: 
			You will need to provide your own clockDivider module. It should take a speed as a parameter rather than be hardcoded to a specific freq
			As per the spec, one of these clock dividers should be replaced with a PLL IP by the end of the lab
			This requirement will make more sense after Lecture 5
	*/
	
	pll_clock i2c_clock_uut(rst, clock, i2c_clock); 		//this clock corresponds to each I2C instruction 
	clk_div #(MESSAGE_RATE) polling_clock_uut(clock, rst, polling_clock); //clock is for spacing out messages to send
	
	
	
	// Sequential FSM Logic
	always@(posedge i2c_clock, posedge rst) begin
		if(rst) begin
			state <= DONE;
			communicate <= 0;
			handshakeDone <= 0;
			handshakeStart <= 0;
			start_from_write <= 0;
		end else begin
			//Two bit shift register:
			if (done || communicate) begin
				state <= next_state;
				if(state == HANDSHAKE1)
					handshakeStart <= handshakeStart + 1;
				else
					handshakeStart <= 0;
				if(state == HANDSHAKE2) handshakeDone <= handshakeDone + 1;
				if(next_state == READ2) dataOut <= dataOut_d;
				if(state == DONE && handshakeDone)
					start_from_write <= start_from_write + 1;
				else
					start_from_write <= 0;
				if(state == WRITE && start_from_write)
					start_from_write <= ~start_from_write;
			end
			
			//TO DO: communicate signal
			/*
				your communicate signal should be high for one i2c_clock cycle only at the posedge of polling clock.
				In otherwords, at the message rate, we should have a single communicate pulse that we use to start communication.
				
				How can we capture the polling_clock positive edge? We use a 2 bit register called polling_clock_vals...
				this 2-bit register should always keep the most recent values of polling_clock and we should update it on the posedge i2c_clock (so here).
				
				You need to write the logic to update polling_clock_vals and then use that to drive the communicate signal (Hint: negedge means we had a 1 and then a 0)
				If the most recent readings of polling_clock_vals show a posedge from polling clock, communicate should be 1 otherwise it should be 0
			*/
			polling_clock_vals[1] <= polling_clock;
			polling_clock_vals[0] <= polling_clock_vals[1];
			if(polling_clock_vals[1] == 1'b1 && polling_clock_vals[0] == 1'b0) 
				communicate <= 1'b1;
			else 
				communicate <= 1'b0;
			
		end
	end
	
	
	// Combinational FSM Logic
	always@(*) begin
		case (state)
			HANDSHAKE1: begin
				deviceAddr = 7'h52;
				addr = 8'hF0;
				dataIn[0] = 8'h55;
				numBytes_d = 1;
				write = 1;
				next_state = handshakeStart ? HANDSHAKE2 : HANDSHAKE1;
			end
			HANDSHAKE2: begin
				deviceAddr = 7'h52;
				addr = 8'hFB;
				dataIn[0] = 8'h00;
				numBytes_d = 1;
				write = 1;
				next_state = WRITE;
			end
			WRITE: begin
				deviceAddr = 7'h52;
				addr = 8'h00;
				dataIn[0] = 8'h00;
				numBytes_d = 0;
				write = 1;
				next_state = start_from_write ? WRITE : READ;
			end
			READ: begin
				deviceAddr = 7'h52;
				addr = 8'h00;
				dataIn[0] = 8'h00;
				numBytes_d = 6;
				write = 0;
				next_state = READ2;
			end
			READ2: begin
				deviceAddr = 7'h52;
				addr = 8'h00;
				dataIn[0] = 8'h00;
				numBytes_d = 6;
				write = 0;
				next_state = DONE;
			end
			DONE: begin
				if(handshakeDone == 1'b1) begin
					next_state = communicate ? WRITE : DONE;
				end else begin
					next_state = communicate ? HANDSHAKE1 : DONE;
				end
			end
			default: next_state = DONE;
		endcase
	end
	
	
endmodule