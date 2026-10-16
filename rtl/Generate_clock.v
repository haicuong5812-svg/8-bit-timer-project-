module Generate_clock(
	input clk,
	input rst,
	input [1:0] sel,
	output clk_o
);
	wire in0, in1, in2, in3;
	wire q0, q1, q2, q3;

	assign  in0 = ~q0;
	FF1 ff0 (.clk(clk), .rst(rst), .q(in0), .D(q0));

	assign  in1 = ~q1;
	FF1 ff1 (.clk(q0),  .rst(rst), .q(in1), .D(q1));

	assign  in2 = ~q2;
	FF1 ff2 (.clk(q1),  .rst(rst), .q(in2), .D(q2));

	assign  in3 = ~q3;
	FF1 ff3 (.clk(q2),  .rst(rst), .q(in3), .D(q3));

	assign  clk_o = sel[1] ? sel[0] ? q3 : q2 : sel[0] ? q1 : q0;
endmodule
