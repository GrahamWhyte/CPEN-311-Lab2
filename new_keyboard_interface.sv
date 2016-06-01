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

/*This FSM module decides the read_mem, direction, and reset values to feed into
address FSM based on the keyboard inputs*/
module new_keyboard_interface(input logic clk, 
							input logic [7:0] key, 
							input readFinish,
							output logic start_read,
							output logic dir,
							output logic restart); 
	
	/*States that keyboard presses transition between*/
	/********outputs encoded in state bits (greycode):
			State[2]	State[1]	State[0]
			dir[1]		dir[0]		start_read
			direction	reset
	*/
	
	parameter check_key = 5'b000_00; 
	parameter Foreward = 5'b001_01;
	parameter Foreward_reset = 5'b010_00;
	parameter Foreward_pause = 5'b011_00;
	
	parameter Backward = 5'b100_11;
	parameter Backward_reset = 5'b101_00;
	parameter Backward_pause = 5'b110_00;
	
	/*TO BE DELETED: names assigned to dir[1:0] output for clarity
	 *basically the same as setting dir to upper two bits of current state*/
	 
	/*parameter read_forward = 2'b00;	
	parameter reset_forward = 2'b01;
	parameter read_backward = 2'b10;
	parameter reset_backward = 2'b11;*/

	assign dir = state[1]; 
	assign start_read = state[0]; 
	
	logic [4:0] state; 
	logic [4:0] next_state;
	
	/*state register (reset handled in comb block)*/
	always_ff @(posedge clk)
		state <= next_state;
		
	/*next state logic*/
	always_comb begin
		case(state)
		
			check_key: begin 
						if (key == `character_E) next_state = Foreward; 
						else if (key == `character_B) next_state = Backward_pause; 
						else if (key == `character_F) next_state = Foreward_pause; 
						else next_state = state; 
						
						//restart = 0; 
						end 
			
			
			Foreward_reset: begin 
				//restart = 1'b1; 
				next_state = Foreward;
			end 
			
			Foreward: begin 
				if(!readFinish) next_state = state; 
				else begin 
					if(key == `character_R || key == `character_lowercase_r)
						next_state = Foreward_reset;
					else if(key == `character_D || key == `character_lowercase_d)
						next_state = Foreward_pause;
					else if(key == `character_B || key == `character_lowercase_b)
						next_state = Backward;
					else
						next_state = state;
				end 
				/*if(readFinish) restart = 0;
				else restart = restart; */
				end 
					
			Foreward_pause: begin 
				if(key == `character_R || key == `character_lowercase_r)
					next_state = Foreward_reset;
				else if(key == `character_E || key == `character_lowercase_e)
					next_state = Foreward;
				else
					next_state = state;	
				//restart = 0; 
				end 
				
			Backward_reset: begin 
				next_state = Backward;
				end 
			
			Backward: begin 
				if(!readFinish) next_state = state; 
				else begin
					if(key == `character_R || key == `character_lowercase_r)
						next_state = Backward_reset;
					else if(key == `character_D || key == `character_lowercase_d)
						next_state = Backward_pause;
					else if(key == `character_F || key == `character_lowercase_f)
						next_state = Foreward;
					else
						next_state = state;
				end 
				/*if(readFinish) restart = 0; 
				else restart = restart; */
				end 
				
			Backward_pause: begin 
				if(key == `character_R || key == `character_lowercase_r)
					next_state = Backward_reset;
				else if(key == `character_E || key == `character_lowercase_e)
					next_state = Backward;
				else
					next_state = state;	
					
				//restart = 0; 
				end 
				
			default: begin 
					next_state = check_key;
					//restart = restart; 
				end 
		endcase
	end
	
	/*encoded output logic -- see parameters section*/
	//assign {dir, start_read} = state[1:0];  
	always_ff@(posedge clk) begin 	
		case(state)
		
			Foreward_reset: restart <= 1'b1; 
			
			Foreward: begin 
					  if(readFinish) restart <= 1'b0; 
					  else restart <= restart; 
					  end 
			
			Backward: begin 
					  if(readFinish) restart <= 1'b0; 
					  else restart <= restart; 
					  end 
			
			Backward_reset: restart <= 1'b1; 
			
			default: restart <= restart; 
		endcase 
	end 
	
	
endmodule
	
						