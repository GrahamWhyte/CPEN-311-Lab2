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
							/*output logic [22:0] addr*/
							output logic start_read,
							output logic [1:0] dir);
	
	/*States that keyboard presses transition between*/
	/********outputs encoded in state bits (greycode):
			State[2]	State[1]	State[0]
			dir[1]		dir[0]		start_read
			direction	reset
	*/
	
	parameter Foreward = 3'b001;
	parameter Foreward_reset = 3'b010;
	parameter Foreward_pause = 3'b000;
	
	parameter Backward = 3'b101;
	parameter Backward_reset = 3'b110;
	parameter Backward_pause = 3'b100;
	
	/*TO BE DELETED: names assigned to dir[1:0] output for clarity
	 *basically the same as setting dir to upper two bits of current state*/
	 
	/*parameter read_forward = 2'b00;	
	parameter reset_forward = 2'b01;
	parameter read_backward = 2'b10;
	parameter reset_backward = 2'b11;*/

	logic [2:0] state; 
	logic [2:0] next_state;
	
	/*state register (reset handled in comb block)*/
	always_ff @(posedge clk)
		state <= next_state;
		
	/*next state logic*/
	always_comb begin
		case(state)
			Foreward_reset: 
				next_state = Foreward;
			
			Foreward: 
				if(key == `character_R || key == `character_lowercase_r)
					next_state = Foreward_reset;
				else if(key == `character_D || key == `character_lowercase_d)
					next_state = Foreward_pause;
				else if(key == `character_B || key == `character_lowercase_b)
					next_state = Backward;
				else
					next_state = state;
					
			Foreward_pause:
				if(key == `character_R || key == `character_lowercase_r)
					next_state = Foreward_reset;
				else if(key == `character_E || key == `character_lowercase_e)
					next_state = Foreward;
				else
					next_state = state;	
	
			Backward_reset: 
				next_state = Backward;
			
			Backward: 
				if(key == `character_R || key == `character_lowercase_r)
					next_state = Backward_reset;
				else if(key == `character_D || key == `character_lowercase_d)
					next_state = Backward_pause;
				else if(key == `character_B || key == `character_lowercase_b)
					next_state = Backward;
				else
					next_state = state;
					
			Backward_pause:
				if(key == `character_R || key == `character_lowercase_r)
					next_state = Backward_reset;
				else if(key == `character_E || key == `character_lowercase_e)
					next_state = Backward;
				else
					next_state = state;	
			
			default: next_state = Foreward_reset;
		endcase
	end
	
	/*encoded output logic -- see parameters section*/
	assign {dir, start_read} = state;
	
	
	
endmodule
	
						