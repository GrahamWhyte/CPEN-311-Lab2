/*Sets address data will be read from
Inputs from keyboard: Direction to count, start bit, restart signal 
Inputs from flash: end signal, data in flash 

Outputs: Address and bytes to read from 
		 Sound signal for audio 
		 Start signal for flash and end signal 
*/

`define address_max 23'h7FFFF

module addr_inc(clk, audioClk, start, dir, restart, endFlash, address, byteenable, startFlash, finish, read, songData, outData); 

input clk, audioClk, start, endFlash, dir, restart;  
input [31:0] songData; 
output startFlash, finish, read; 
output [3:0] byteenable; 
output [22:0] address; 
output [7:0] outData; //To audio 

parameter idle = 6'b0000_00; 
parameter readFlash = 6'b0001_01; 
parameter get_data_1 = 6'b0010_00; 
parameter read_data_1 = 6'b0011_00; 
parameter get_data_2 = 6'b0100_00; 
parameter read_data_2 = 6'b0101_00; 
parameter checkInc = 6'b0110_00; 
parameter inc_addr = 6'b0111_00; 
parameter dec_addr = 6'b1000_00; 
parameter finished = 6'b1001_10; 


logic [5:0] state; 
//logic flag;  

assign startFlash = state[0]; 
assign finish = state[1]; 
assign read = state[0]; 

assign byteenable = 4'b1111; //always read all data 
		
//Next state logic 
always_ff@(posedge clk) begin 
	case(state) 
		
		idle: begin 
			  if(start) state <= readFlash; 
			  end 
			  
		readFlash: begin 
				   if(endFlash) state <= get_data_1; 
				   end 
				   
		get_data_1: if(audioClk) state <= read_data_1; 
				  
		read_data_1: state <= get_data_2;  
		
		get_data_2: if(audioClk) state <= read_data_2; 
		
		read_data_2: state <= checkInc; 
				   
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
	case (state)
	
		read_data_1: begin 
			if (dir) outData <= songData [31:24]; 
			else outData <= songData [15:8]; 
			address <= address; //address does not change in this state 
		end 
		
		read_data_2: begin 
			if(dir) outData <= songData [15:8]; 
			else outData <= songData [31:24]; 
			address <= address; //address does not change in this state  
			end 
		
		dec_addr: begin
			if (restart) address <= `address_max; 
			else begin  
			address <= address - 23'd1; 
				if (address == 0) 
					address <= `address_max;  
			end 
			outData <= outData; //data does not change in this state 
		end 
		
		inc_addr: begin 
			if(restart) address <= 0;   
			else begin 
				address <= address + 23'd1; 
				if (address > `address_max) 
					address <= 0; 
			end 
			outData <= outData; //data does not change in this state  	  
		end 
		
		default: begin 
			address <= address; 
			outData <= outData;
			end
		
	endcase 
end 

endmodule 




