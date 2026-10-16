module Syn_CLK(
	input  pclk_i,
	input  rst_i,
	input  clk_i,
	output clk
);

	wire not_in;
	assign  clk = clk_i & (!not_in);
	FF1 ff0 (.clk(pclk_i), .rst(rst_i), .q(clk_i), .D(not_in));
endmodule
