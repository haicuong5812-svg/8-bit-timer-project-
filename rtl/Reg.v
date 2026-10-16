module Reg (
	input clk,
	input rstn,
	input psel,
	input pwrite,
	input penable,
	input pready,
	input sel_reg,
	input [7:0] pwdata,
	output reg [7:0] out
);

	wire sel_mux;
	wire [7:0] bus;

	assign sel_mux = psel & pwrite & penable & pready & sel_reg;
	assign bus = sel_mux ? pwdata : out;

	always @(posedge clk, negedge rstn) begin
		if (!rstn) begin
    			out <=  8'h0;
  		end else begin
  			out <=  bus;
		end
	end
endmodule
