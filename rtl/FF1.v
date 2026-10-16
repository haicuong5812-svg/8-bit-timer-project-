module FF1 (
	input clk,
  	input rst,
  	input q,
  	output reg D
);
  	always @(posedge clk or negedge rst) begin
    		if (!rst) D <= 1'b0; 
		else D <= q;
  	end
endmodule

