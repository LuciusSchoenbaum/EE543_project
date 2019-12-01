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






/// basic ripple adder with external carryin
module rippleTCadder(zout, overflow, ain, bin, cin);
parameter WIDTH = 8;

endmodule











/// ripple adder with inputs/outputs that are convenient for use in array multiplier
module pp_ripple_adder(ppout, pout, ttin, ppin);
parameter WIDTH = 4;

//) If carryout/overflow is included, 
//+ the output OUT of a normal adder has width WIDTH+1. 
//+ We assign the least significant bit of OUT to the output pout. 
//+ We assign the remaining bits (in order) of OUT to the output ppout. 
output pout;
output [WIDTH-1:0] ppout;
// inputs from scalar multiplication and the previous ripple adder
input [WIDTH-1:0] ttin, ppin;

wire [WIDTH-1:1] w;

// first module
full_adder m0(
	.zout(pout), 
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
			.zout(),  TODOoooooooooooooooooooooooooooooooo
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


/// layer of a general multiplier: scalar multiplication and addition. 
//) yields a single partial product and one completed product bit. 
//- ppout: the slice [\infty:1] of the partial product output
//- pout: the LSB of the partial product output
//- ain: the input a to the multiplier
//- bin: a digit from the input b to the multiplier
//- ppin: the partial product output from the previous layer
module multiplier_layer(ppout, pout, ain, bin, ppin);
parameter WIDTH = 4;
/// is the layer the zeroth layer? 
//) in this layer, the input ppin is zero, 
//+ but we don't wish to implement an adder just in order to add zero. 
parameter IS_LAYER0 = 0;

input [WIDTH-1:0] ain;
input bin;
output pout;
output [WIDTH-1:0] ppout;

wire [WIDTH-1:0] tt;

// module scalar_mult(ttout, ain, bin);
scalar_mult m0(
    ttout.(tt), 
    .ain(ain), 
    .bin(bin)
);

if (IS_LAYER0) begin
    assign pout = tt[0];
    assign ppout = {0'b0, tt[WIDTH-1:1]};
end
else begin
    // module pp_ripple_adder(zout, ppout, ttin, ppin);
    pp_ripple_adder m1(
        zout(pout), 
        .ppout(ppout), 
        .ttin(tt), 
        .ppin(ppin)
    );
end

endmodule





/// WIDTH-bit multiplier
module multWIDTHbit(prodout, ain, bin);
parameter WIDTH = 4;

output [2*WIDTH-1:0] product;
input [WIDTH-1:0] ain, bin;

wire [WIDTH*WIDTH-WIDTH-1:0] w;

// module multiplier_layer(ppout, pout, ain, bin, ppin);

/// first module
multiplier_layer m0(
    .ppout(w[WIDTH-1:0]), 
    .pout(prodout[0]), 
    .ain(ain), 
    .bin(bin[0]), 
    .ppin({WIDTH{1'b0}})
);
defparam m0 .WIDTH = WIDTH;
defparam m0 .IS_LAYER0 = 1;

/// last module
multiplier_layer mlast(
    .ppout(prodout[2*WIDTH-1:WIDTH]), 
    .pout(prodout[WIDTH-1]), 
    .ain(ain), 
    .bin(bin[WIDTH-1]), 
    .ppin(w[WIDTH*WIDTH-WIDTH-1:(WIDTH-1)*(WIDTH-1)])
);
defparam mlast .WIDTH = WIDTH;

/// ith module
genvar i;
generate
    for (i=1; i < WIDTH; i=i+1) begin: loop
        multiplier_layer mi(
            .ppout(w[(i*WIDTH-1:(i-1)*WIDTH]), 
            .pout(prodout[i]), 
            .ain(ain), 
            .bin(bin[i]), 
            .ppin(w[(i+1)*WIDTH-1:i*WIDTH])
        );
        defparam mi .WIDTH = WIDTH;
    end
endgenerate

endmodule





////////////////////////////////////////
// We can now create a 4-bit multiplier.
////////////////////////////////////////

/// 4-bit multiplier
module mult4bit(zout, ain, bin);

output [7:0] zout;
input [3:0] ain, bin; 

multWIDTHbit m0(
	.zout(zout), 
	.ain(ain), 
	.bin(bin)
);
defparam m0 .WIDTH=4;

endmodule








//








///////////////////////////////////////////////////////////////////////////////////////////////////////////
// We start by creating a general-purpose multiplexer. 
// We parametrize this module by the number of inputs and the input width.  
// We call these two parameters WIDTH and NUM_INPUTS, respectively. 
///////////////////////////////////////////////////////////////////////////////////////////////////////////



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

// The project description requires gate level modeling is used. 

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

/////////////////////////////
/// Shift, Rotate, Nop
/////////////////////////////


/// shifter/rotater building-block module
//) Can shift/rotate up to 7 bits. 
module shiftrotateWIDTHbit(zout, ain, bin);
parameter WIDTH = 8;
/// if RIGHT == 0, shift/rotate left, else rotate right.
parameter RIGHT = 0;
/// if ROTATE = 0, shift, else rotate. 
parameter ROTATE = 0;

input [WIDTH-1:0] ain, bin;
output [WIDTH-1:0] zout;

reg [7*WIDTH-1:0] products;

// The project description requires gate level modeling is used. 

if (ROTATE) begin
    if (RIGHT) begin
        products[1*WIDTH-1:0*WIDTH] = {ain[0:0], ain[WIDTH-1:1]};
        products[2*WIDTH-1:1*WIDTH] = {ain[1:0], ain[WIDTH-1:2]};
        products[3*WIDTH-1:2*WIDTH] = {ain[2:0], ain[WIDTH-1:3]};
        products[4*WIDTH-1:3*WIDTH] = {ain[3:0], ain[WIDTH-1:4]};        
        //...
        // products[i*WIDTH-1:(i-1)*WIDTH] = {ain[(i-1):0], ain[WIDTH-1]:i]};
        //...
        products[5*WIDTH-1:4*WIDTH] = {ain[4:0], ain[WIDTH-1:5]};        
        products[6*WIDTH-1:5*WIDTH] = {ain[5:0], ain[WIDTH-1:6]};        
        products[7*WIDTH-1:6*WIDTH] = {ain[6:0], ain[WIDTH-1:7]};
    end
    else // LEFT
    begin
        products[1*WIDTH-1:0*WIDTH] = {ain[WIDTH-2:0], ain[WIDTH-1:WIDTH-1]};
        products[2*WIDTH-1:1*WIDTH] = {ain[WIDTH-3:0], ain[WIDTH-1:WIDTH-2]};
        products[3*WIDTH-1:2*WIDTH] = {ain[WIDTH-4:0], ain[WIDTH-1:WIDTH-3]};
        products[4*WIDTH-1:3*WIDTH] = {ain[WIDTH-5:0], ain[WIDTH-1:WIDTH-4]};
        //...
        // products[i*WIDTH-1:(i-1)*WIDTH] = {ain[WIDTH-i-1:0], ain[WIDTH-1:WIDTH-i]};
        //...
        products[5*WIDTH-1:4*WIDTH] = {ain[WIDTH-6:0], ain[WIDTH-1:WIDTH-5]};        
        products[6*WIDTH-1:5*WIDTH] = {ain[WIDTH-7:0], ain[WIDTH-1:WIDTH-6]};        
        products[7*WIDTH-1:6*WIDTH] = {ain[WIDTH-8:0], ain[WIDTH-1:WIDTH-7]};
    end
end
else // SHIFT
begin
    if (RIGHT) begin 
        products[1*WIDTH-1:0*WIDTH] = {1'b0, ain[WIDTH-1:WIDTH-1]};
        products[2*WIDTH-1:1*WIDTH] = {2'b0, ain[WIDTH-1:WIDTH-2]};
        products[3*WIDTH-1:2*WIDTH] = {3'b0, ain[WIDTH-1:WIDTH-3]};
        products[4*WIDTH-1:3*WIDTH] = {4'b0, ain[WIDTH-1:WIDTH-4]};
        //...
        // products[i*WIDTH-1:(i-1)*WIDTH] = {{i{1'b0}}, ain[WIDTH-1:WIDTH-i]};
        //...
        products[5*WIDTH-1:4*WIDTH] = {5'b0, ain[WIDTH-1:WIDTH-5]};        
        products[6*WIDTH-1:5*WIDTH] = {6'b0, ain[WIDTH-1:WIDTH-6]};        
        products[7*WIDTH-1:6*WIDTH] = {7'b0, ain[WIDTH-1:WIDTH-7]};
    end
    else // LEFT
    begin
        products[1*WIDTH-1:0*WIDTH] = {ain[WIDTH-2:0], 1'b0};
        products[2*WIDTH-1:1*WIDTH] = {ain[WIDTH-3:0], 2'b0};
        products[3*WIDTH-1:2*WIDTH] = {ain[WIDTH-4:0], 3'b0};
        products[4*WIDTH-1:3*WIDTH] = {ain[WIDTH-5:0], 4'b0};
        //...
        // products[i*WIDTH-1:(i-1)*WIDTH] = {ain[WIDTH-i-1:0], {i{1'b0}}};
        //...
        products[5*WIDTH-1:4*WIDTH] = {ain[WIDTH-6:0], 5'b1}; 
        products[6*WIDTH-1:5*WIDTH] = {ain[WIDTH-7:0], 6'b1};
        products[7*WIDTH-1:6*WIDTH] = {ain[WIDTH-8:0], 7'b1};
    end
end

mux_general(
    .zout(zout), 
    .inputs(les produits), 
    .sel(bin[2:0])
);
defparam .WIDTH=WIDTH;
defparam .NUM_INPUTS=8;

endmodule


module ror8bit();

endmodule

module rol8bit();

endmodule

/// shift right logical (multiply by 2)
module srl8bit();

endmodule

/// shift left logical (divide by 2)
module sll8bit();

endmodule


/// for a nop instruction, set output to zero
module nop8bit(zout, ain, bin);

output [7:0] zout;
input [7:0] ain, bin;

// The project description requires gate level modeling is used. 

// assign zout = 8'b0000_0000;

wire [7:0] w1;

not (w1, ain);
and (zout, ain, w1);

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




