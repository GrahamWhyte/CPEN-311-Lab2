/*This module takes the speed control pulses in and generates the count_to variable that
  feeds into the clock divider*/
`define default_speed 32'h8E0
module speed_control(input speed_up, speed_down, speed_reset, clk,  
					output logic [31:0] out_count);
					
	logic [31:0] temp_count = `default_speed; 
	
	always_ff @(posedge clk) begin 
		case ({speed_up, speed_down, speed_reset})
			3'b001: temp_count <= `default_speed; 
			3'b010: temp_count <= temp_count - 32'h10; 
			3'b100: temp_count <= temp_count + 32'h10; 
			default: temp_count <= temp_count; 
		endcase 
	end 
	
	assign out_count = temp_count; 
	
endmodule 