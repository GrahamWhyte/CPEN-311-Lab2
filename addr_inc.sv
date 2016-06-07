/*
Purpose: Sets address data will be read from
		 Outputs sound signal to audio

Inputs from top module: 50 MHz Clock, Rising edge of 22 KHz Clock synchonized with 50 MHz Clock 
Inputs from keyboard: start signal, direction to count, restart signal 
Inputs from flash: end signal, audio data 

Outputs: Address and bytes to read from 
		 Sound signal for audio 
		 Start and read signal to flash  
		 End signal to keyboard  
*/

`define address_max 23'h7FFFF

module addr_inc(clk, audioClk, start, dir, restart, endFlash, address, byteenable, startFlash, finish, read, songData, outData, volume_sig); 

input clk, audioClk, start, endFlash, dir, restart;  
input [31:0] songData; 
output startFlash, finish, read, volume_sig; 
output [3:0] byteenable; 
output [22:0] address; 
output [7:0] outData; //To audio 

parameter idle = 7'b0000_000; 
parameter readFlash = 7'b0001_001; 
parameter get_data_1 = 7'b0010_000; 
parameter read_data_1 = 7'b0011_000; 
parameter get_data_2 = 7'b0100_000; 
parameter read_data_2 = 7'b0101_000; 
parameter checkInc = 7'b0110_000; 
parameter inc_addr = 7'b0111_000; 
parameter dec_addr = 7'b1000_000; 
parameter finished = 7'b1001_010; 
parameter interrupt_1 = 7'b1010_100; 
parameter interrupt_2 = 7'b1011_100; 


logic [6:0] state; 
//logic flag;  

assign startFlash = state[0]; 
assign finish = state[1]; 
assign read = state[0]; 
assign volume_sig = state[2]; 

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
				   
		get_data_1: if(audioClk) state <= read_data_1; //Wait for rising edge of 22 KHz clock 
				  
		read_data_1: state <= interrupt_1; 

		interrupt_1: state <= get_data_2;
		
		get_data_2: if(audioClk) state <= read_data_2; //Wait for rising edge of 22 KHz clock  
		
		read_data_2: state <= interrupt_2;

		interrupt_2: state <= checkInc; 
				   
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




