module Pre (
	input clk,
	input rstn,
	input psel,
	input penable,
	output reg pready
);

	always @(posedge clk or negedge rstn) begin
  		if (!rstn) begin
    			pready <= 1'b0;
  		end else begin
  			pready <= (psel & !penable);
		end
	end
endmodule
