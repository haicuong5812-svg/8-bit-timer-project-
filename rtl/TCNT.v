module TCNT (
	input PCLK,
	input PRESETn,
	input CLK_in,
	input [7:0] TDR,
	input EN,
	input LOAD,
	input DOWN,
	output [7:0] CNT
);

	wire [7:0] next_count, initial_value;
	wire  [7:0] sum;
	wire [7:0] MOD;
	wire enCLK;

	localparam MODADD = 8'h01;
	localparam MODSUB = 8'hFF;

	assign  next_count    = (EN && enCLK) ? sum : CNT; 
    	assign  initial_value = LOAD ? TDR  : next_count;

	assign  MOD = DOWN ? (MODSUB & {8{EN}}) : (MODADD & {8{EN}});

	FF8 ff_CNT (.clk(PCLK), .rst(PRESETn), .q(initial_value), .D(CNT));

	assign sum = CNT + MOD;

	Syn_CLK SynCLK (.pclk_i(PCLK), .rst_i(PRESETn), .clk_i(CLK_in), .clk(enCLK));
endmodule

