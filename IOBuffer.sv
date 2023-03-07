module IOBuffer(in, out, enable, port);
	
	//TODO: complete IOBuffer as described in the lab spec.
	input in, enable;
	output out;
	inout port;
	
	assign out = enable ? 1'b0 : port;
	assign port = enable ? in : 1'bz;

endmodule