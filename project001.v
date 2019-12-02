// File project001.v Created by Lucius Schoenbaum November 29, 2019
// EE 543 project for Dr. Na Gong, Fall 2019



// For the project code, I have preferred "flat" nets over vectors. 
// My experience with Verilog vectors has been that they are not convenient, 
// particularly because inputs and outputs cannot be vectors. 
// Therefore, rather than mixing styles, I have used flat nets throughout, 
// and avoided the use of vectors. 

// I worked with general input widths. I did this to practice this coding style. 
// I found that it was worth the extra work, because I grew more comfortable 
// working this way as I went along. 





////////////////
// Part 1
////////////////







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
//- zout: output integer (sum)
//- cout: carryout
//- ain, bin: input integers
//- cin: carryin. 
//) set carry to high after negating one of the inputs to perform subtraction. 
module ripple_adder(zout, cout, ain, bin, cin);
parameter WIDTH = 8;

output [WIDTH-1:0] zout;
output cout;
input [WIDTH-1:0] ain, bin;
input cin;

wire [WIDTH-1:1] w;

//module full_adder(zout, cout, ain, bin, cin);

// first module
full_adder m0(
    .zout(zout[0]), 
    .cout(w[1]), 
    .ain(ain[0]), 
    .bin(bin[0]), 
    .cin(cin)
);

// last module
full_adder ml(
    .zout(zout[WIDTH-1]), 
    .cout(cout), 
    .ain(ain[WIDTH-1]), 
    .bin(bin[WIDTH-1]), 
    .cin(w[WIDTH-1])
);

// ith module
genvar i;
generate
    for (i=1; i < WIDTH-1; i=i+1) begin: loop
        full_adder mi(
            .zout(zout[i]), 
            .cout(w[i+1]), 
            .ain(ain[i]), 
            .bin(bin[i]), 
            .cin(w[i])
        );
    end
endgenerate

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
full_adder ml(
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
			.zout(ppout[i-1]), 
			.cout(w[i+1]), 
			.ain(ttin[i]), 
			.bin(ppin[i]), 
			.cin(w[i])
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

input [WIDTH-1:0] ain, ppin;
input bin;
output pout;
output [WIDTH-1:0] ppout;

wire [WIDTH-1:0] tt;

// module scalar_mult(ttout, ain, bin);
scalar_mult m0(
    .ttout(tt), 
    .ain(ain), 
    .bin(bin)
);

generate
if (IS_LAYER0) begin
    assign pout = tt[0];
    assign ppout = {1'b0, tt[WIDTH-1:1]};
end
else begin
    pp_ripple_adder m1(
        .ppout(ppout), 
        .pout(pout), 
        .ttin(tt), 
        .ppin(ppin)
    );
end
endgenerate

endmodule





/// WIDTH-bit multiplier
//- prodout - output integer (product of ain, bin)
//- ain, bin - input integers
module multWIDTHbit(prodout, ain, bin);
parameter WIDTH = 4;

output [2*WIDTH-1:0] prodout;
input [WIDTH-1:0] ain, bin;

wire [(WIDTH-1)*WIDTH-1:0] w;

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
multiplier_layer ml(
    .ppout(prodout[2*WIDTH-1:WIDTH]), 
    .pout(prodout[WIDTH-1]), 
    .ain(ain), 
    .bin(bin[WIDTH-1]), 
    .ppin(w[(WIDTH-1)*WIDTH-1:(WIDTH-2)*WIDTH]) 
);
defparam ml .WIDTH = WIDTH;

/// ith module
genvar i;
generate
    for (i=1; i < WIDTH-1; i=i+1) begin: loop
        multiplier_layer mi(
            .ppout(w[(i+1)*WIDTH-1:i*WIDTH]), 
            .pout(prodout[i]), 
            .ain(ain), 
            .bin(bin[i]), 
            .ppin(w[i*WIDTH-1:(i-1)*WIDTH])
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
	.prodout(zout), 
	.ain(ain), 
	.bin(bin)
);
// Change this line to change the input width.
// This isn't strictly necessary, because 4 is the default. 
defparam m0 .WIDTH = 4;

endmodule








//















////////////////
// Part 2
////////////////









/////////////////////////////////////////////////////////////////////////////////////////////////
// We implement an 8-bit ALU with 12 operations. 
// We start by creating a general-purpose multiplexer. 
// We parametrize this module by the number of inputs and the input width.  
// We call these two parameters WIDTH and SEL_WIDTH, respectively. 
/////////////////////////////////////////////////////////////////////////////////////////////////



/// select-NAND gate
// Description: return zero if sel is 0, or ~ain if sel is 1. 
module sNAND(zout, ain, sel);
parameter WIDTH = 8;

input [WIDTH-1:0] ain;
input sel;
output [WIDTH-1:0] zout;

// The project description requires gate level modeling is used. 

genvar i;

generate
	for (i=0; i<WIDTH; i=i+1) begin: loop
		nand mi(zout[i], ain[i], sel);
	end
endgenerate

endmodule



/// bitwise-NAND gate
// Description: return the bitwise NAND of ain and bin.
module bNAND(zout, ain, bin);
parameter WIDTH = 8;

input [WIDTH-1:0] ain, bin;
output [WIDTH-1:0] zout;

// The project description requires gate level modeling is used. 
 
genvar i;

generate
	for (i=0; i<WIDTH; i=i+1) begin: loop
		nand mi(zout[i], ain[i], bin[i]);
	end
endgenerate

endmodule

///////////////////////////////////////////////////////////////////////////////////////////////
// While we are at it, we define other bitwise operators we will need.
// The code is highly similar to the code above. 
///////////////////////////////////////////////////////////////////////////////////////////////

/// not
module bNOT(zout, ain);
parameter WIDTH = 8;

input [WIDTH-1:0] ain;
output [WIDTH-1:0] zout;
 
genvar i;

generate
	for (i=0; i<WIDTH; i=i+1) begin: loop
		not mi(zout[i], ain[i]);
	end
endgenerate

endmodule

/// nor
module bNOR(zout, ain, bin);
parameter WIDTH = 8;

input [WIDTH-1:0] ain, bin;
output [WIDTH-1:0] zout;
 
genvar i;

generate
	for (i=0; i<WIDTH; i=i+1) begin: loop
		nor mi(zout[i], ain[i], bin[i]);
	end
endgenerate

endmodule

/// xnor
module bXNOR(zout, ain, bin);
parameter WIDTH = 8;

input [WIDTH-1:0] ain, bin;
output [WIDTH-1:0] zout;
 
genvar i;

generate
	for (i=0; i<WIDTH; i=i+1) begin: loop
		xnor mi(zout[i], ain[i], bin[i]);
	end
endgenerate

endmodule




// 2:1 multiplexer with variable input/output width
///////////////////////////////////////////////////////////////////////////////////////////
// Convention: consider sel's inputs as increasing integers: 
//      0, followed by 1. 
// Consider the flat vectors `inputs` as segments, starting from the right: 
//      [WIDTH-1:0], followed by [2*WIDTH-1:WIDTH]. 
// We match these two orderings. 
// We do the same in the general multiplexer that follows. 
///////////////////////////////////////////////////////////////////////////////////////////
module mux21(zout, inputs, sel);
parameter WIDTH = 8;

output [WIDTH-1:0] zout;
input [2*WIDTH-1:0] inputs;
input sel;

// The project description requires gate level modeling is used. 

wire [2*WIDTH-1:0] w;

sNAND m0(
    .zout(w[WIDTH-1:0]), 
    .ain(inputs[WIDTH-1:0]), 
    .sel(~sel)
);
sNAND m1(
    .zout(w[2*WIDTH-1:WIDTH]),
    .ain(inputs[2*WIDTH-1:WIDTH]), 
    .sel(sel)
);
bNAND m2(
    .zout(zout), 
    .ain(w[2*WIDTH-1:WIDTH]), 
    .bin(w[WIDTH-1:0])
);

defparam m0 .WIDTH=WIDTH;
defparam m1 .WIDTH=WIDTH;
defparam m2 .WIDTH=WIDTH;

endmodule


/// layer submodule of general multiplexer module
module mux_general_layer(layerout, layerin, sel);
parameter WIDTH = 8;
parameter LEVEL = 0;
localparam NUM_MUXES = 2**LEVEL;

output [LEVEL*WIDTH-1:0] layerout; 
input [2*LEVEL*WIDTH-1:0] layerin;
input sel;

genvar i;
generate
    for (i=0; i<NUM_MUXES; i=i+1) begin: loop
        mux21 mi(
            .zout(layerout[(i+1)*WIDTH-1:i*WIDTH]), 
            .inputs(layerin[2*(i+1)*WIDTH-1:2*i*WIDTH]), 
            .sel(sel)
        );
        defparam mi .WIDTH=WIDTH;
    end
endgenerate

endmodule



/// General multiplexer
////////////////////////////////////////////////////////////////////////////////////////////////////
//) See the important comment above the module mux21.
//) The parameter SEL_WIDTH sets the number of inputs to the mux: 
// SEL_WIDTH = 1, then mux_general is a 2:1 mux.
// SEL_WIDTH = 2, then mux_general is a 4:1 mux.
// SEL_WIDTH = 3, then mux_general is a 8:1 mux. 
// SEL_WIDTH = 4, then mux_general is a 16:1 mux. 
// Etc. 
//) For this project, we use this module for the shift/rotate logic, and for the ALU controller. 
////////////////////////////////////////////////////////////////////////////////////////////////////
module mux_general(zout, inputs, sel);
parameter WIDTH = 8;
parameter SEL_WIDTH = 4;
localparam NUM_INPUTS = 2**SEL_WIDTH;

output [WIDTH-1:0] zout;
input [NUM_INPUTS*WIDTH-1: 0] inputs;
input [SEL_WIDTH-1:0] sel;

wire [(NUM_INPUTS-1)*WIDTH-1:WIDTH] w;

// first layer, i=SEL_WIDTH-1, closest to inputs
mux_general_layer m0(
	.layerout(w[(2**(SEL_WIDTH)-1)*WIDTH-1:(2**(SEL_WIDTH-1)-1)*WIDTH]), 
	.layerin(inputs), 
	.sel(sel[0])
);
defparam m0 .WIDTH=WIDTH;
defparam m0 .LEVEL=SEL_WIDTH-1;

// last layer, i=0, closest to output
mux_general_layer ml(
	.layerout(zout), 
	.layerin(w[3*WIDTH-1:WIDTH]), 
	.sel(sel[SEL_WIDTH-1])
);
defparam ml .WIDTH=WIDTH;
defparam ml .LEVEL=0;

genvar i;
generate
    for (i=1; i<SEL_WIDTH-1; i=i+1) begin: loop
        mux_general_layer mi(
            .layerout(w[(2**(i+1)-1)*WIDTH-1:(2**(i)-1)*WIDTH]), 
            .layerin(w[(2**(i+2)-1)*WIDTH-1:(2**(i+1)-1)*WIDTH]), 
            .sel(sel[SEL_WIDTH-1-i])
        );
        defparam mi .WIDTH=WIDTH;
        defparam mi .LEVEL=i;
    end
endgenerate

endmodule




// 8-bit ALU controller, to the project's specification. 
module controller(
	aluout, 
	ctrl, 
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

// ALU output
output [7:0] aluout;
// control signal
input [3:0] ctrl;
// inputs
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

mux_general m1(
	.zout(aluout), 
	.inputs({
		nop8bit1[7:0], // ctrl = 0000
		add8bit[7:0], // ctrl = 0001
		sub8bit[7:0], // ctrl = 0010
		rsb8bit[7:0], // ctrl = 0011
		mul4bithigh[7:0], // ctrl = 0100
		nop8bit2[7:0], // ctrl = 0101
		nop8bit3[7:0], // ctrl = 0110
		nop8bit4[7:0], // ctrl = 0111
		nor8bit[7:0], // ctrl = 1000
		not8bit[7:0], // ctrl = 1001
		nand8bit[7:0], // ctrl = 1010
		xnor8bit[7:0], // ctrl = 1011
		srl8bit[7:0], // ctrl = 1100
		sll8bit[7:0], // ctrl = 1101
		ror8bit[7:0], // ctrl = 1110
		rol8bit[7:0] // ctrl = 1111
	}), 
	.sel(ctrl)
);
defparam m1 .WIDTH=8;
defparam m1 .SEL_WIDTH=4;

endmodule













/////////////////////////////
/// Bitwise Operations
/////////////////////////////

module nor8bit(zout, ain, bin);

output [7:0] zout;
input [7:0] ain, bin;

bNOR m(zout, ain, bin);
defparam m .WIDTH=8;

endmodule

// the logical inverse of input2
module not8bit(zout, ain, bin);

output [7:0] zout;
input [7:0] ain, bin;

bNOT m(zout, bin);
defparam m .WIDTH=8;

endmodule

module nand8bit(zout, ain, bin);

output [7:0] zout;
input [7:0] ain, bin;

bNAND m(zout, ain, bin);
defparam m .WIDTH=8;

endmodule

module xnor8bit(zout, ain, bin);

output [7:0] zout;
input [7:0] ain, bin;

bXNOR m(zout, ain, bin);
defparam m .WIDTH=8;

endmodule


/////////////////////////////
/// Arithmetic Operations
/////////////////////////////


// The project specification requires no carryout.
module add8bit(zout, ain, bin);

output [7:0] zout;
input [7:0] ain, bin;
reg cin = 1'b0;

ripple_adder m(zout, , ain, bin, cin);
defparam m .WIDTH=8;

endmodule

// input 2 minus input 1
module sub8bit(zout, ain, bin);

output [7:0] zout;
input [7:0] ain, bin;
reg cin = 1'b1;

bNOT m0(zout, bin);
ripple_adder m1(zout, , ain, bin, cin);

defparam m0 .WIDTH=8;
defparam m1 .WIDTH=8;

endmodule

// input 1 minus input 2
module rsb8bit(zout, ain, bin);

output [7:0] zout;
input [7:0] ain, bin;
reg cin = 1'b1;

bNOT m0(zout, ain);
ripple_adder m1(zout, , ain, bin, cin);

defparam m0 .WIDTH=8;
defparam m1 .WIDTH=8;

endmodule

// the product of the 4 most significant bits of input 1 and input 2 (as integers)
module mult4bithigh(zout, ain, bin);

output [7:0] zout; 
input [7:0] ain, bin;

// re-use 4-bit multiplier from part 1:
mult4bit m(zout, ain[7:4], bin[7:4]);

endmodule

/////////////////////////////
/// Shift, Rotate, Nop
/////////////////////////////

/// shifter/rotater building-block module
//) Can shift/rotate up to 7 bits. 
//) We code/implement a trivial operation in case of input bin == 0 
//+ at the cost of area (?)
//+ because otherwise we wouldn't be able to re-use our multiplexer. 
module shiftrotateWIDTHbit(zout, ain, bin);
parameter WIDTH = 8;
/// if RIGHT == 0, shift/rotate left, else rotate right.
parameter RIGHT = 0;
/// if ROTATE = 0, shift, else rotate. 
parameter ROTATE = 0;

input [WIDTH-1:0] ain, bin;
output [WIDTH-1:0] zout;

reg [8*WIDTH-1:0] products;

// The project description requires gate level modeling is used. 
// Currently I am using an initial block because my original idea requires it, 
// (which I didn't realize) and I haven't had time to redo it using gate-level code. 

initial begin
if (ROTATE) begin
    if (RIGHT) begin
		products[1*WIDTH-1:0*WIDTH] = ain;
        products[2*WIDTH-1:1*WIDTH] = {ain[0:0], ain[WIDTH-1:1]};
        products[3*WIDTH-1:2*WIDTH] = {ain[1:0], ain[WIDTH-1:2]};
        products[4*WIDTH-1:3*WIDTH] = {ain[2:0], ain[WIDTH-1:3]};
        products[5*WIDTH-1:4*WIDTH] = {ain[3:0], ain[WIDTH-1:4]};        
        //...
        // products[i*WIDTH-1:(i-1)*WIDTH] = {ain[(i-1):0], ain[WIDTH-1]:i]};
        //...
        products[6*WIDTH-1:5*WIDTH] = {ain[4:0], ain[WIDTH-1:5]};        
        products[7*WIDTH-1:6*WIDTH] = {ain[5:0], ain[WIDTH-1:6]};        
        products[8*WIDTH-1:7*WIDTH] = {ain[6:0], ain[WIDTH-1:7]};
    end
    else // LEFT
    begin
		products[1*WIDTH-1:0*WIDTH] = ain;
        products[2*WIDTH-1:1*WIDTH] = {ain[WIDTH-2:0], ain[WIDTH-1:WIDTH-1]};
        products[3*WIDTH-1:2*WIDTH] = {ain[WIDTH-3:0], ain[WIDTH-1:WIDTH-2]};
        products[4*WIDTH-1:3*WIDTH] = {ain[WIDTH-4:0], ain[WIDTH-1:WIDTH-3]};
        products[5*WIDTH-1:4*WIDTH] = {ain[WIDTH-5:0], ain[WIDTH-1:WIDTH-4]};
        //...
        // products[i*WIDTH-1:(i-1)*WIDTH] = {ain[WIDTH-i-1:0], ain[WIDTH-1:WIDTH-i]};
        //...
        products[6*WIDTH-1:5*WIDTH] = {ain[WIDTH-6:0], ain[WIDTH-1:WIDTH-5]};        
        products[7*WIDTH-1:6*WIDTH] = {ain[WIDTH-7:0], ain[WIDTH-1:WIDTH-6]};        
        products[8*WIDTH-1:7*WIDTH] = {ain[WIDTH-8:0], ain[WIDTH-1:WIDTH-7]};
    end
end
else // SHIFT
begin
    if (RIGHT) begin
		products[1*WIDTH-1:0*WIDTH] = ain;
        products[2*WIDTH-1:1*WIDTH] = {1'b0, ain[WIDTH-1:WIDTH-1]};
        products[3*WIDTH-1:2*WIDTH] = {2'b0, ain[WIDTH-1:WIDTH-2]};
        products[4*WIDTH-1:3*WIDTH] = {3'b0, ain[WIDTH-1:WIDTH-3]};
        products[5*WIDTH-1:4*WIDTH] = {4'b0, ain[WIDTH-1:WIDTH-4]};
        //...
        // products[i*WIDTH-1:(i-1)*WIDTH] = {{i{1'b0}}, ain[WIDTH-1:WIDTH-i]};
        //...
        products[6*WIDTH-1:5*WIDTH] = {5'b0, ain[WIDTH-1:WIDTH-5]};        
        products[7*WIDTH-1:6*WIDTH] = {6'b0, ain[WIDTH-1:WIDTH-6]};        
        products[8*WIDTH-1:7*WIDTH] = {7'b0, ain[WIDTH-1:WIDTH-7]};
    end
    else // LEFT
    begin
		products[1*WIDTH-1:0*WIDTH] = ain;
        products[2*WIDTH-1:1*WIDTH] = {ain[WIDTH-2:0], 1'b0};
        products[3*WIDTH-1:2*WIDTH] = {ain[WIDTH-3:0], 2'b0};
        products[4*WIDTH-1:3*WIDTH] = {ain[WIDTH-4:0], 3'b0};
        products[5*WIDTH-1:4*WIDTH] = {ain[WIDTH-5:0], 4'b0};
        //...
        // products[i*WIDTH-1:(i-1)*WIDTH] = {ain[WIDTH-i-1:0], {i{1'b0}}};
        //...
        products[6*WIDTH-1:5*WIDTH] = {ain[WIDTH-6:0], 5'b1}; 
        products[7*WIDTH-1:6*WIDTH] = {ain[WIDTH-7:0], 6'b1};
        products[8*WIDTH-1:7*WIDTH] = {ain[WIDTH-8:0], 7'b1};
    end
end
end

mux_general m0(
    .zout(zout), 
    .inputs(products), 
    .sel(bin[2:0])
);
defparam m0 .WIDTH=WIDTH;
defparam m0 .SEL_WIDTH=3;

endmodule

/// rotate right
module ror8bit(zout, ain, bin);

output [7:0] zout;
input [7:0] ain, bin;

shiftrotateWIDTHbit m(zout, ain, bin);
defparam m .WIDTH = 8;
defparam m .RIGHT = 1;
defparam m .ROTATE = 1;

endmodule

/// rotate left
module rol8bit(zout, ain, bin);

output [7:0] zout;
input [7:0] ain, bin;

shiftrotateWIDTHbit m(zout, ain, bin);
defparam m .WIDTH = 8;
defparam m .RIGHT = 0;
defparam m .ROTATE = 1;

endmodule

/// shift right logical (multiply by 2)
module srl8bit(zout, ain, bin);

output [7:0] zout;
input [7:0] ain, bin;

shiftrotateWIDTHbit m(zout, ain, bin);
defparam m .WIDTH = 8;
defparam m .RIGHT = 1;
defparam m .ROTATE = 0;

endmodule

/// shift left logical (divide by 2)
module sll8bit(zout, ain, bin);

output [7:0] zout;
input [7:0] ain, bin;

shiftrotateWIDTHbit m(zout, ain, bin);
defparam m .WIDTH = 8;
defparam m .RIGHT = 0;
defparam m .ROTATE = 0;

endmodule


/// for a nop instruction, set output to zero
module nop8bit(zout, ain, bin);

output [7:0] zout;
input [7:0] ain, bin;

// The project description requires gate level modeling is used. 

wire [7:0] w1;

not (w1, ain);
and (zout, ain, w1);

endmodule




module alu8bit(aluout, ain, bin, ctrl);

output [7:0] aluout;
input [7:0] ain, bin;
input [3:0] ctrl;

/// wires
wire [7:0] add8bit_w;
wire [7:0] sub8bit_w;
wire [7:0] rsb8bit_w;
wire [7:0] mul4bithigh_w;
wire [7:0] nor8bit_w;
wire [7:0] not8bit_w; 
wire [7:0] nand8bit_w;
wire [7:0] xnor8bit_w;
wire [7:0] srl8bit_w;
wire [7:0] sll8bit_w;
wire [7:0] ror8bit_w;
wire [7:0] rol8bit_w;
wire [7:0] nop8bit1_w;
wire [7:0] nop8bit2_w;
wire [7:0] nop8bit3_w;
wire [7:0] nop8bit4_w;

/// compute modules
add8bit m0(add8bit_w, ain, bin); 
sub8bit m1(sub8bit_w, ain, bin); 
rsb8bit m2(rsb8bit_w, ain, bin); 
mul4bithigh m3(mul4bithigh_w, ain, bin); 
nor8bit m4(nor8bit_w, ain, bin); 
not8bit m5(not8bit_w, ain, bin); 
nand8bit m6(nand8bit_w, ain, bin); 
xnor8bit m7(xnor8bit_w, ain, bin); 
srl8bit m8(srl8bit_w, ain, bin); 
sll8bit m9(sll8bit_w, ain, bin); 
ror8bit m10(ror8bit_w, ain, bin); 
rol8bit m11(rol8bit_w, ain, bin); 
nop8bit1 m12(nop8bit1_w, ain, bin);
nop8bit2 m13(nop8bit2_w, ain, bin);
nop8bit3 m14(nop8bit3_w, ain, bin);
nop8bit4 m15(nop8bit4_w, ain, bin);

/// controller module
controller m16(
	.aluout(aluout), 
	.ctrl(ctrl), 
	.add8bit(add8bit_w), 
	.sub8bit(sub8bit_w), 
	.rsb8bit(rsb8bit_w), 
	.mul4bithigh(mul4bithigh_w), 
	.nor8bit(nor8bit_w), 
	.not8bit(not8bit_w), 
	.nand8bit(nand8bit_w), 
	.xnor8bit(xnor8bit_w), 
	.srl8bit(srl8bit_w), 
	.sll8bit(sll8bit_w), 
	.ror8bit(ror8bit_w),
	.rol8bit(rol8bit_w),
	.nop8bit1(nop8bit1_w),
	.nop8bit2(nop8bit2_w), 
	.nop8bit3(nop8bit3_w), 
	.nop8bit4(nop8bit4_w)
);

endmodule














//






















////////////////
// Part 3
////////////////






// todo












//


















////////////////
// Part 4
////////////////






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
module MEM_general(data_out, address, data_in, WE, RE, clk, Enable);
parameter WORDSIZE = 8;
parameter NUM_WORDS = 512;

output [WORDSIZE-1:0] data_out;
reg [WORDSIZE-1:0] data_out;
input [WORDSIZE-1:0] data_in;
input [NUM_WORDS-1:0] address;
input WE, RE, clk, Enable;

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



/// RAM memory containing 512 words of 8 bits each, to project specification.
module MEM(data_out, address, data_in, WE, RE, clk, Enable);

output [7:0] data_out;
input [7:0] data_in;
input [511:0] address;
input WE, RE, clk, Enable;

MEM_general m0(data_out, address, data_in, WE, RE, clk, Enable);
defparam m0 .WORDSIZE=8;
defparam m0 .NUM_WORDS=512;


endmodule













////////////////
// Top module
////////////////










module project001
	(multout, ain, bin);
//	(aluout, ain, bin);
//	(MEMout, address, data_in, WE, RE, clk, Enable);


////////////////////
// Part 1 stimulus
////////////////////

output [7:0] multout;
input [3:0] ain, bin;

mult4bit m(multout, ain, bin);



////////////////////
// Part 2 stimulus
////////////////////

//output [7:0] aluout;
//input [7:0] ain, bin;
//input [3:0] ctrl;

//alu8bit m(aluout, ain, bin, ctrl);



////////////////////
// Part 3 stimulus
////////////////////

//output [7:0] aluout;
//input [7:0] ain, bin;
//input [3:0] ctrl;

//alu8bit m(aluout, ain, bin, ctrl);



////////////////////
// Part 4 stimulus
////////////////////

//) To test correctness, we will bring down the parameters to something manageable. 

//output [1:0] MEMout;
//input [1:0] data_in;
//input [3:0] address;
//input clk;
//input WE, RE, Enable;

//MEM_general m(MEMout, address, data_in, WE, RE, clk, Enable);
//defparam m .WORDSIZE=2;
//defparam m .NUM_WORDS=4;



endmodule



