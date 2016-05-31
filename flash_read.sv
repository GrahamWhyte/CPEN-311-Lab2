module flash_read(clk, waitrequest, data_valid, start, finish); 

input clk, start, data_valid, waitrequest; 
output finish;  


logic [4:0] state;    

                  //432_10 
parameter idle = 5'b000_00; 
//parameter check_read = 5'b001_00; 
parameter slave_ready = 5'b010_00; 
parameter wait_read = 5'b011_00; 
parameter finished = 5'b100_01; 

assign finish = state[0]; 

always_ff@(posedge clk)
	case(state) 
		
		idle: 
			begin 
				if(start) state <= slave_ready; 
			end 
			
		/*check_read: 
			begin 
				if(read) state <= slave_ready; 
			end */
			
		slave_ready: 
			begin
				if(~waitrequest) state <= wait_read; 
			end 
			
		wait_read: 
			begin 
				if(~data_valid) state <= finished; 
			end 
			
		finished: state <= idle;

		default: state <= idle; 
		
	endcase 
	
endmodule 

