/*
Purpose: Control flash memory reads with keyboard 

Inputs from top module: 50 MHz clock, Last key pressed, Key pressed signal
Inputs from address increment: read complete signal 

Outputs to address increment: start signal, direction to count, restart signal 
*/ 


`define character_B 8'h42  
`define character_D 8'h44 
`define character_E 8'h45 
`define character_F 8'h46 
`define character_R 8'h52 
`define character_lowercase_b 8'h62
`define character_lowercase_d 8'h64 
`define character_lowercase_e 8'h65 
`define character_lowercase_f 8'h66
`define character_lowercase_r 8'h72 

module new_keyboard_interface(input logic clk, 
							input logic [7:0] key, 
							input readFinish,
							input dataReady, 
							output logic start_read,
							output logic dir,
							output logic restart); 
	

	parameter check_key = 6'b000_000; 
	parameter Foreward = 6'b001_001;
	parameter Foreward_reset = 6'b010_101;
	parameter Foreward_pause = 6'b011_000;
	parameter Backward = 6'b100_011;
	parameter Backward_reset = 6'b101_111;
	parameter Backward_pause = 6'b110_000;
	
	assign restart = state[2]; 
	assign dir = state[1]; 
	assign start_read = state[0]; 
	
	logic [5:0] state; 
	
	always_ff@(posedge clk) begin
		case(state)
		
			check_key: begin 
						if (key == `character_E) state <= Foreward; 
						else if (key == `character_B) state <= Backward_pause; 
						else if (key == `character_F) state <= Foreward_pause;
						else state <= check_key; 
						end 
			
			
			Foreward_reset: begin 
							if (readFinish) 
								state <= Foreward; //Wait for complete read after resetting 
							end 
			
			Foreward: begin 
					if(key == `character_R || key == `character_lowercase_r) begin 
						if(dataReady) state <= Foreward_reset; //Only reset when key is pressed 
						else state <= Foreward; 
					end 
					else if(key == `character_D || key == `character_lowercase_d)
						state <= Foreward_pause;
					else if(key == `character_B || key == `character_lowercase_b)
						state <= Backward;
					else state <= Foreward; 
				end 
					
			Foreward_pause: begin 
				if(key == `character_R || key == `character_lowercase_r) begin 
					state <= Foreward_reset; 
				end 
				else if(key == `character_E || key == `character_lowercase_e)
					state <= Foreward;
				else if(key == `character_B || key == `character_lowercase_b) 
					state <= Backward_pause; 
				else state <= Foreward_pause; 
				end 
				
			Backward_reset: if (readFinish) state <= Backward; //Wait for complete read after resetting 
		
			
			Backward: begin 
					if(key == `character_R || key == `character_lowercase_r) begin 
						if (dataReady) state <= Backward_reset;  //Only reset when key is pressed 
						else state <= Backward; 
					end 
				    else if(key == `character_D || key == `character_lowercase_d)
						state <= Backward_pause;
					else if(key == `character_F || key == `character_lowercase_f)
						state <= Foreward;
					else
						state <= Backward;
				end 
				
			Backward_pause: begin 
				if(key == `character_R || key == `character_lowercase_r) begin 
					state <= Backward_reset; 
				end 
				else if(key == `character_E || key == `character_lowercase_e)
					state <= Backward;
				else if(key == `character_F || key == `character_lowercase_f) 
					state <= Foreward_pause; 
				else
					state <= Backward_pause;	
				end 
				
			default: state <= check_key; 
		endcase
	end
endmodule
						