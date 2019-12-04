// File project001_tb.v Created by Lucius Schoenbaum December 3, 2019
// test bench modules for semester project assignment for Dr. Na Gong's EE 543 (Intro HDL Logic Simulation)





//////////////////
// ALU test bench
//////////////////





// we test the two ALU designs against one another. 

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

reg pass;

initial begin
	a = 0; b = 0; pass = 1;
	#100000000 if (pass) $display ("pass.");
	$stop();
end

always begin
	#100 a = $random; b = $random; op = $random;
	#10 if (z1 !== z2) 
	begin
		$display ("Mismatch at time %d: a = %b, b = %b, ctrl = %b.", $time, a, b, op);
		pass = 0;
	end
	else // z1 == z2
	begin
		pass = 1;
	end
end

endmodule






//////////////////
// MEM test bench
//////////////////



// todo


