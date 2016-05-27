/*Sets address data will be read from
Inputs from keyboard: Direction to count, start bit, restart signal 
Inputs from flash: end signal, data in flash 

Outputs: Address and bytes to read from 
		 Sound signal for audio 
		 Start signal for flash and end signal 
*/

module addr_inc(clk, audioClk, start, change, endFlash, address, byteenable, startFlash, finish, songData, outData); 

input clk, audioClk, start, endFlash;
input [1:0] change;  
input [31:0] songData; 
output startFlash, finish; 
output [3:0] byteenable; 
output [22:0] address; 
output [15:0] outData; //To audio 

parameter idle = 5'b000_00; 
parameter readFlash = 5'b001_01; 
parameter checkInc = 5'b010_00; 
parameter inc_addr = 5'b011_00; 
parameter dec_addr = 5'b100_00; 
parameter finished = 5'b101_10; 
parameter get_data = 5'b110_00; 
parameter read_data = 5'b111_00; 

logic [4:0] state; 
logic flag; 

wire dir, restart; 

assign startFlash = state[0]; 
assign finish = state[1]; 

assign dir = change[1]; 
assign restart = change[0]; 

assign byteenable = 4'b1111; //always read all data 
		
//Next state logic 
always_ff@(posedge clk) begin 
	case(state) 
		
		idle: begin 
			  if(start) state <= readFlash; 
			  end 
			  
		readFlash: begin 
				   if(endFlash) state <= get_data; 
				   end 
				   
		get_data: begin 
				  if (audioClk) state <= read_data;
				  end 
				  
		read_data: state <= checkInc; 
				   
		checkInc: begin 
				  if(dir) state <= dec_addr; 
				  else state <= inc_addr; 
				  end 
				  
		dec_addr: begin 
					state <= finished; 
				end 
		
		inc_addr: begin 
					state <= finished; 
				end 
				  
		finished: state <= idle; 
		
		default: state <= idle; 
		
	endcase 
end 

//Output logic 
always_ff@(posedge clk) begin 
	
	if (state == read_data) begin 
		if (flag) begin
			outData = songData [31:16]; 
			flag = ~flag;
		end 
		else begin 
			outData = songData [15:0]; 
			flag = ~flag;  
		end 
	end 
	
	else if (state == dec_addr) begin 
		if (restart) 
			address = 524287;
		else begin 
		address = address - 1; 
			if (address < 0) 
				address = 0;  
		end 
		end 
	
	else if (state == inc_addr) begin 
		if(restart) 
			address = 0; 
		else begin 
			address = address + 1; 
			if (address > 524287) 
				address = 524287; 
		end 
		end 
			 
end 

endmodule 
	
		



