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
							input logic [7:0] keyey, 
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
	
	parameter check_key = 6'b000_000; 
	parameter Foreward = 6'b001_001;
	parameter Foreward_reset = 6'b010_101;
	parameter Foreward_pause = 6'b011_000;
	
	parameter Backward = 6'b100_011;
	parameter Backward_reset = 6'b101_111;
	parameter Backward_pause = 6'b110_000;
	
	/*TO BE DELETED: names assigned to dir[1:0] output for clarity
	 *basically the same as setting dir to upper two bits of current state*/
	 
	/*parameter read_forward = 2'b00;	
	parameter reset_forward = 2'b01;
	parameter read_backward = 2'b10;
	parameter reset_backward = 2'b11;*/

	assign restart = state[2]; 
	assign dir = state[1]; 
	assign start_read = state[0]; 
	
	logic [5:0] state; 
	logic [7:0] outKey; 
	//logic [5:0] next_state;
	
	/*state register (reset handled in comb block)*/
	/*always_ff @(posedge clk)
		state <= next_state;
	*/
	/*next state logic*/
	//always_comb begin
	
	assign outKey = key; 
	
	always_ff@(posedge clk) begin
		case(state)
		
			check_key: begin 
						if (key == `character_E) state <= Foreward; 
						else if (key == `character_B) state <= Backward_pause; 
						else if (key == `character_F) state <= Foreward_pause;
						else state <= check_key; 
						end 
			
			
			Foreward_reset: if (readFinish) state <= Foreward;  
			
			Foreward: begin 
					if(key == `character_R || key == `character_lowercase_r)
						state <= Foreward_reset;
					else if(key == `character_D || key == `character_lowercase_d)
						state <= Foreward_pause;
					else if(key == `character_B || key == `character_lowercase_b)
						state <= Backward;
					else state <= Foreward; 
				end 
					
			Foreward_pause: begin 
				if(key == `character_R || key == `character_lowercase_r)
					state <= Foreward_reset;
				else if(key == `character_E || key == `character_lowercase_e)
					state <= Foreward;
				else state <= Foreward_pause; 
				end 
				
			Backward_reset: if (readFinish) state <= Backward;
		
			
			Backward: begin 
					if(key == `character_R || key == `character_lowercase_r)
						state <= Backward_reset;
				    else if(key == `character_D || key == `character_lowercase_d)
						state <= Backward_pause;
					else if(key == `character_F || key == `character_lowercase_f)
						state <= Foreward;
					else
						state <= Backward;
				end 
				
			Backward_pause: begin 
				if(key == `character_R || key == `character_lowercase_r)
					state <= Backward_reset;
				else if(key == `character_E || key == `character_lowercase_e)
					state <= Backward;
				else
					state <= Backward_pause;	
				end 
				
			default: state <= check_key; 
		endcase
	end
	
	
	
endmodule
						