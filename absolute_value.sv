module absolute_value(input clk, input [n-1:0] data, output [n-1:0] abs); 

parameter n = 8; 
wire [n-1:0] extended = {n{data[n-1]}};  

always_ff@(posedge clk) begin 
	abs <= (extended^data) - (extended); 
end 

endmodule  