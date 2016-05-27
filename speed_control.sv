/*This module takes the speed control pulses in and generates the count_to variable that
  feeds into the clock divider*/
module speed_control(input logic speed_up, speed_down, speed_reset, clk, 
					output logic [31:0] out_count);
					
	
	always_ff @(posedge clk)
		if(speed_reset) begin
			out_count <= 32'h470;
		end else if(speed_up) begin
			out_count <= out_count - 32'h20;
		end else if(speed_down) begin
			out_count <= out_count + 32'h20;
		end else begin
			out_count <= out_count;
		end
	
endmodule 