module one_hertz_clock(one_hertz_clock, LEDR);
	input one_hertz_clock;
	output reg[7:0] LEDR = 8'b00000001;
	reg flag = 0; 
	
	
	always @(posedge one_hertz_clock) begin
		//case(current_state)
		if (flag) begin  
			LEDR = LEDR >> 1; 
			if (LEDR == 8'b00000001) 
				flag = ~flag;
		end 
		else begin 
			LEDR = LEDR << 1; 
			if (LEDR == 8'b10000000) 
				flag = ~flag;
		end 	
	end
endmodule
