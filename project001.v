// File project001.v Created by Lucius Schoenbaum November 29, 2019
// EE 543 project for Dr. Na Gong, Fall 2019
// part 1 (gate-level modeling)



/// standard full adder
module full_adder(zout, cout, ain, bin, cin);

input ain, bin, cin;
output zout, cout;

// The project description requires gate level modeling is used. 

wire w1, w2, w3;

xor m0(w1, ain, bin);
xor m1(zout, cin, w1);
and m2(w2, ain, bin);
and m3(w3, cin, w1);
// Here a XOR gate or an OR gate may be used. 
or m4(cout, w2, w3);

endmodule





///////////////////////////////////////////////
// hereafter we parametrize by input width. 
// The parameter is called WIDTH.
// For a 4-bit multiplier, we can set WIDTH=4. 
// For an 8-bit multiplier, we can set WIDTH=8. 
// Etc.
////////////////////////////////////////////////





/// ripple adder with inputs/outputs that are convenient for use in array multiplier
module ripple_adder(zout, ppout, ttin, ppin);
parameter WIDTH = 4;

//) If carryout/overflow is included, 
//+ the output OUT of a normal adder has width WIDTH+1. 
//+ We assign the least significant bit of OUT to the output zout. 
//+ We assign the remaining bits (in order) of OUT to the output ppout. 
output zout;
output [WIDTH-1:0] ppout;
// inputs from scalar multiplication and the previous ripple adder
input [WIDTH-1:0] ttin, ppin;

wire [WIDTH-1:1] w;

// first module
full_adder m0(
	.zout(zout), 
	.cout(w[1]), 
	.ain(ttin[0]), 
	.bin(ppin[0]), 
	.cin(1'b0)
);

// last module 
full_adder m_end(
	.zout(ppout[WIDTH-2]), 
	.cout(ppout[WIDTH-1]), 
	.ain(ttin[WIDTH-1]), 
	.bin(ppin[WIDTH-1]), 
	.cin(w[WIDTH-1])
);

genvar i;

// modules 1 through WIDTH-2
generate
	for (i = 1; i < WIDTH-1; i=i+1) begin: loop
		full_adder mi(
			.zout(), 
			.cout(), 
			.ain(), 
			.bin(), 
			.cin()
		);
	end
endgenerate

endmodule




/// scalar multiplier
module scalar_mult(ttout, ain, bin);
parameter WIDTH = 4;

output [WIDTH-1:0] ttout;
input [WIDTH-1:0] ain;
input bin;

// The project description requires gate level modeling is used. 

genvar i;

generate
	for (i = 0; i < WIDTH; i=i+1) begin: loop
		and(ttout[i], ain[i], bin);
	end
endgenerate

endmodule


module multiplier_layer();
parameter WIDTH = 4;

// TODOOOOOOOOOOOOOOOOO

endmodule


/// WIDTH-bit multiplier
module multWIDTHbit();
parameter WIDTH = 4;

// TODOOOOOOOOOOOOOOOOO

endmodule


////////////////////////////////////////
// We can now create a 4-bit multiplier.
////////////////////////////////////////

/// 4-bit multiplier
module mult4bit(zout, ain, bin);

input [3:0] ain, bin; 
output [3:0] zout;

multWIDTHbit m0(
	.zout(zout), 
	.ain(ain), 
	.bin(bin)
);
defparam m0 .WIDTH=4;

endmodule








//








/////////////////////////////////////////////////////////
// We parametrize by the number of inputs and the width.  
// ()()() TODO: DESCRIPTION.
// talk about WIDTH, talk about NUM_INPUTS
/////////////////////////////////////////////////////////



/// select-AND gate
// Description: return zero if sel is 0, or ain if sel is 1. 
module sAND8(zout, ain, sel);
parameter WIDTH = 8;

input [WIDTH-1:0] ain;
input sel;
output [WIDTH-1:0] zout;

// The project description requires gate level modeling is used. 

genvar i;

generate
	for (i=0; i<WIDTH; i=i+1) begin: loop
		and mi(zout[i], ain[i], sel);
	end
endgenerate

endmodule



/// bitwise-OR gate
// Description: return the bitwise OR of ain and bin.
module bOR8(zout, ain, bin);
parameter WIDTH = 8;

input [WIDTH-1:0] ain, bin;
output [WIDTH-1:0] zout;

// The project description requires gate level modeling is used. 
 
genvar i;

generate
	for (i=0; i<WIDTH; i=i+1) begin: loop
		or mi(zout[i], ain[i], bin[i]);
	end
endgenerate

endmodule


// 2:1 multiplexer with variable input/output width
module mux21(zout, inputs, sel);
parameter WIDTH = 8;

// The project description requires gate level modeling is used. 

// TODOOOOOOOOOOOOOOOOOOO

endmodule


// General multiplexer
module mux_general(zout, inputs, sel);
parameter WIDTH = 8;
parameter NUM_INPUTS = 16;

// TODOOOOOOOOOOOOOOOOOOO

endmodule




// alu8bit controller
module controller(
	zout, 
	/// select signal
	sel, 
	/// inputs
	add8bit, 
	sub8bit, 
	rsb8bit, 
	mul4bithigh, 
	nor8bit, 
	not8bit, 
	nand8bit, 
	xnor8bit, 
	srl8bit, 
	sll8bit, 
	ror8bit,
	rol8bit,
	nop8bit1,
	nop8bit2, 
	nop8bit3, 
	nop8bit4
);

input [7:0] add8bit; 
input [7:0] sub8bit; 
input [7:0] rsb8bit; 
input [7:0] mul4bithigh; 
input [7:0] nor8bit; 
input [7:0] not8bit; 
input [7:0] nand8bit; 
input [7:0] xnor8bit; 
input [7:0] srl8bit; 
input [7:0] sll8bit; 
input [7:0] ror8bit; 
input [7:0] rol8bit; 
input [7:0] nop8bit1;
input [7:0] nop8bit2;
input [7:0] nop8bit3;
input [7:0] nop8bit4;
input [3:0] sel; 
output [7:0] zout; 

mux_general m1(
	.zout(zout), 
	.inputs({
		// todo
	}), 
	.sel(sel)
);
defparam m1 .WIDTH=8;
defparam m1 .NUM_INPUTS=16;

endmodule













/////////////////////////////
/// Bitwise Operations
/////////////////////////////

module nor8bit();

endmodule

module not8bit();

endmodule

module nand8bit();

endmodule

module xnor8bit();

endmodule


/////////////////////////////
/// Arithmetic Operations
/////////////////////////////

module add8bit();

endmodule

module sub8bit();

endmodule

module rsb8bit();

endmodule

module mult4bithigh();

endmodule

/// shift right logical (multiply by 2)
module srl8bit();

endmodule

/// shift left logical (divide by 2)
module sll8bit();

endmodule

/////////////////////////////
/// Shift, Rotate, Nop
/////////////////////////////

module ror8bit();

endmodule

module rol8bit();

endmodule

module nop8bit();

endmodule








//








module alu8bit(zout, overflow, ain, bin, ctrl);

output [7:0] zout;
output overflow;
input [7:0] ain, bin;
input [3:0] ctrl;

/////// trying this: an array of wires
wire [7:0] w[0:15];

// big pile of instantiations, with defparams

controller m0(
	// todo
);
// defparam here


endmodule











//










/// RAM Memory design 
// Description: clk is the clock signal, 
//+ Enable, WE, RE are control signals, 
//+ data_in and data_out are input/output for data, respectively, 
//+ address is the address to be read or to be written to. 
//+ The memory obeys the following specification: 
//+ (1) The memory is disabled if Enable is high. 
//+ (2) The memory is write-enabled if and only if Enable is high, WE is high, and RE is low. 
//+ (3) The memory is read-enabled if and only if Enable is high, WE is low, and RE is high. 
//+ (4) Changes to memory may occur only at positive clock edges. 
module MEM(data_out, address, data_in, WE, RE, clk, Enable);
parameter WORDSIZE = 8;
parameter NUM_WORDS = 512;

output [WORDSIZE-1:0] data_out;
reg [WORDSIZE-1:0] data_out;

input [WORDSIZE-1:0] data_in;
input [NUM_WORDS-1:0] address;
///// ???????????????????? I'm not sure if this works - can I index an array with a net????

reg [WORDSIZE-1:0] mem[0:NUM_WORDS-1];

integer i;

initial begin
	for (i=0; i<NUM_WORDS; i=i+1)
		mem[i] = {WORDSIZE{1'b0}};
end


always @(posedge clk) begin
	if (Enable && RE && !WE) begin
		// memory is read-enabled
		data_out = mem[address];
	end
	else if (Enable && !RE && WE) begin
		// memory is write-enabled
		mem[address] = data_in;

	end
		// in all other case (!Enable, or Enable but not {RE,WE} == 10 or 01), the memory is disabled.
end

endmodule




