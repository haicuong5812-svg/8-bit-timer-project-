module Prd (
	input clk,
	input rstn,
	input pready,	
	input psel,
	input pwrite,
	input penable,
	input [7:0] paddr,
	input [7:0] TDR,
	input [7:0] TCR,
	input [7:0] TSR,
	output reg [7:0] out
);

	wire ready1, en;

	assign ready1 = psel & !pwrite & !penable;
	assign en = ready1;

	always @(posedge clk or negedge rstn) begin
  		if (!rstn) begin
    			out <= 8'h00;
  		end else if (en) begin
  			case (paddr)
    				8'h0 : out <= TDR;
    				8'h1 : out <= TCR;
    				8'h2 : out <= TSR;
    				default: out <= 8'h00;
  			endcase
		end else begin
			out <= out;
		end
	end
endmodule
