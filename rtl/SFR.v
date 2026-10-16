module SFR (
	input PCLK,
	input PRESETn,
	input EN,
	input LOAD,
	input DOWN,
	input [7:0] CNT,	
	output S_TMR_UDF,
	output S_TMR_OVF
);
	wire inst0;
	wire [7:0] lastCNT;
	wire udf_eq_00;
	wire udf_eq_ff;
	wire ovf_eq_00;
	wire ovf_eq_ff;

	assign  inst0 = EN & (!LOAD);

	FF8 ff_CNT (.clk(PCLK), .rst(PRESETn), .q(CNT), .D(lastCNT));

	assign  udf_eq_00 = (lastCNT == 8'h00) ? 1'b1 : 1'b0;
	assign  udf_eq_ff = (CNT == 8'hFF) ? 1'b1 : 1'b0;	
	assign  S_TMR_UDF = inst0 & DOWN & udf_eq_00 & udf_eq_ff;
	
	assign  ovf_eq_00 = (lastCNT == 8'hFF) ? 1'b1 : 1'b0;
	assign  ovf_eq_ff = (CNT == 8'h00) ? 1'b1 : 1'b0;
	assign  S_TMR_OVF = inst0 & (!DOWN) & ovf_eq_00 & ovf_eq_ff;
endmodule
