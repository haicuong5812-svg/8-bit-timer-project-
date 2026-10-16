module Mux (
	input [7:0] paddr,
	output reg [2:0] select_reg
);

	always @(paddr) begin
  		case (paddr)
    			8'h0 : select_reg <= 3'b001;
    			8'h1 : select_reg <= 3'b010;
    			8'h2 : select_reg <= 3'b100;
    			default : select_reg <= 3'b000;
  		endcase
	end
endmodule
