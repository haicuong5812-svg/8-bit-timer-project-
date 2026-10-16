module Psl(
	input clk,
	input rstn,
	input [2:0] select_reg,
	output reg pslverr
);
	always @(*) begin

		if (|select_reg) begin
			pslverr = 1'b0; 
		end else begin
			pslverr = 1'b1; 
		end
	end

endmodule
