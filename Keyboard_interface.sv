`define no_key 8'h00 
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


module Keyboard_interface(input clk, input [7:0] key, /*output logic [22:0] next_addr,*/ output logic [22:0] addr, output logic dir); 

parameter check_key = 5'b000_00; 
parameter key_D = 5'b001_00; 
parameter key_E = 5'b010_00;
parameter key_F = 5'b011_00; 
parameter key_B = 5'b100_00;
parameter key_R = 5'b101_00; 

logic [4:0] state;   

//assign next_addr = addr; 

always_ff@(posedge clk) 
	
	case(state) 
	
		check_key:  begin 
					if (key == `character_lowercase_d || key == `character_D) 
					begin 
						state <= key_D; 
					end 
					
					else if (key == `character_lowercase_e || key == `character_E) 
					begin 
						state <= key_E; 
					end 
					
					
					else if (key == `character_lowercase_f || key == `character_F) 
					begin 
						state <= key_F; 
					end 
					
					
					else if (key == `character_lowercase_b || key == `character_B) 
					begin 
						state <= key_B; 
					end 
					
					
					else if (key == `character_lowercase_r || key == `character_R) 
					begin 
						state <= key_R; 
					end
					end 
					
		key_D: begin 
			    if (key != `no_key)  
				begin 
					state <= check_key;
				end 
			   end 
				
		key_E: begin 
				if (dir) 
				begin 
					addr <= addr - 23'd2;
				end 
				
				else begin  
					addr <= addr + 23'd2;  
				end 
				
				if (key != `no_key)   
				begin 
					state <= check_key;
				end 
				
			end 
				
		key_F: begin 
				dir = 0; 
				state <= check_key; 
			   end 
				
		key_B: begin 
				dir = 1; 
				state <= check_key; 
			   end 
				
		key_R: begin 
				if (dir) 
				begin 
					addr <= 23'h7FFFE; 
				end 
				
				else begin 
					addr <= 23'h00000; 
				end 
				
				state <= check_key; 
				end 
				
		default: state <= check_key; 
		
	endcase 
	
	/*always_comb 
		case (state) 
		
		key_E: begin 
				if (dir) 
				begin 
					addr = addr - 23'd2;
				end 
				
				else begin  
					addr = addr + 23'd2;  
				end
			end 
				
		key_R: begin 
				if (dir) 
				begin 
					addr = 23'h7FFFE; 
				end 
				
				else begin 
					addr = 23'h00000; 
				end 
			end 
				
		default: addr = addr; 
		
		endcase 
	*/
		

endmodule 
				
 

