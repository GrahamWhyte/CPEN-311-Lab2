/*Sets address data will be read from
Inputs from keyboard: Direction to count, start bit, restart signal 
Inputs from flash: end signal, data in flash 

Outputs: Address and bytes to read from 
		 Sound signal for audio 
		 Start signal for flash and end signal 
*/

`define address_max 23'h7FFFF

module addr_inc(clk, audioClk, start, dir, restart, endFlash, address, byteenable, startFlash, finish, songData, outData); 

input clk, audioClk, start, endFlash, dir, restart;  
input [31:0] songData; 
output startFlash, finish; 
output [3:0] byteenable; 
output [22:0] address; 
output [7:0] outData; //To audio 

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

assign startFlash = state[0]; 
assign finish = state[1]; 
 

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
				   
		get_data: if(audioClk) state <= read_data; 
				  
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
	case (state)
	
		read_data: begin 
			if (flag) begin //Flag = 1 means odd address 
			outData <= songData [31:24]; 
			flag <= ~flag;
			end
		
			else begin //Flag = 0 means even address 
			outData <= songData [15:8]; 
			flag <= ~flag;  
			end  
			address <= address; //address does not change in this state 
		end 
		
		dec_addr: begin
			if (restart) begin 
				address <= `address_max;
				flag <= 1'b1; //Odd numbered address
			end 
			else begin 
			flag <= flag; 
			address <= address - 23'd1; 
				if (address < 0) 
					address <= `address_max;  
			end 
			outData <= outData; //data does not change in this state 
		end 
		
		inc_addr: begin 
			if(restart) begin 
				address <= 0; 
				flag <= 0; //Even numbered address 
			end 
			else begin 
				flag <= flag; 
				address <= address + 23'd1; 
				if (address > `address_max) 
					address <= 0; 
			end 
			outData <= outData; //data does not change in this state  	  
		end 
		
		default: begin 
			address <= address; 
			outData <= outData;
			flag <= flag; 
		end
		
	endcase 
end 

endmodule 





