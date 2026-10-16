module FF8 (
  	input clk,
  	input rst,
  	input [7:0] q,
  	output reg [7:0] D
);
  	always @(posedge clk or negedge rst) begin
    		if (!rst) D <= 8'h00; 
		else D <= q;
  	end
endmodule
