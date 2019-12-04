


// calculate the log base 2 of input integer. 
// based on examples in stx_cookbook.
function integer log2; 
	input integer val;
	begin
		log2 = 0;
		while (val > 0) begin
			val = val >> 1;
			log2 = log2 + 1;
		end
		if (log2 != 0) log2 = log2 - 1;
	end
endfunction





