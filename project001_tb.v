// File project001_tb.v Created by Lucius Schoenbaum December 3, 2019
// test bench modules for semester project assignment for Dr. Na Gong's EE 543 (Intro HDL Logic Simulation)





//////////////////
// ALU test bench
//////////////////





// we test the two ALU designs against one another. 
// This is based on an example in stx_cookbook by baeckler. 


// todo: unit test mux_general

module alu8bit_testbench();

reg [7:0] a, b;
reg [3:0] op;
wire [7:0] z1, z2;

alu8bit m1(
	.aluout(z1), 
	.ain(a), 
	.bin(b), 
	.ctrl(op)
);

alu8bit_Part3 m2(
	.aluout(z2), 
	.ain(a), 
	.bin(b), 
	.ctrl(op)
);

// transient pass
reg tpass;
// all test pass
reg pass;

initial begin
	a = 0; b = 0; pass = 1; tpass = 1;
	#100000000 if (pass) $display ("pass.");
	$stop();
end

always begin
	#100 a = $random; b = $random; op = $random;
	#10 if (z1 !== z2) 
	begin
		$display ("Mismatch at time %d: a = %b, b = %b, ctrl = %b.", $time, a, b, op);
		pass = 0;
		tpass = 0;
	end
	else // z1 == z2
	begin
		tpass = 1;
	end
end

endmodule






//////////////////
// MEM test bench
//////////////////


// This is a simple/basic test, not a great test. 
// Hope to improve another time. 


module MEM_testbench();

reg [7:0] data_in;
reg [8:0] address;
reg WE, RE, clk, Enable;
wire [7:0] data_out;

MEM m1(
	.data_out(data_out), 
	.address(address), 
	.data_in(data_in), 
	.WE(WE), 
	.RE(RE), 
	.clk(clk), 
	.Enable(Enable)
);

// transient pass
reg tpass;
// all test pass
reg pass;

// double clock signal
reg dbl;

initial begin
	data_in = $random; 
	address = $random;
	clk = 1;
	dbl = 0;
	tpass = 1; pass = 1;
	Enable = 1;
	RE = 0;
	WE = 1;
	#10000 if (pass) $display ("pass.");
	$stop();
end

// clock signal
always begin
	#10 clk = ~clk;
end

always @(posedge clk) begin
	dbl = ~dbl;
end

// write to address A; then set to read
always @(posedge dbl) begin
	RE = ~RE;
	WE = ~WE;
end

// read from address A; then change the input values and set back to write mode
always @(negedge dbl) begin
	data_in = $random; 
	address = $random;
end



// check the values at negedge of clock. 
always @(posedge dbl) begin
	if (data_out !== data_in && WE && !RE && Enable) 
	begin
		$display ("Read failure at time %d.", $time);
		pass = 0;
		tpass = 0;
	end
	else // return
	begin
		tpass = 1;
	end
end

endmodule

