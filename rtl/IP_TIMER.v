module IP_TIMER (
	input PCLK,
	input PRESETn,
	input PSEL,
	input PENABLE,
	input PWRITE,
	input [7:0] PADDR,
	input [7:0] PWDATA,
	output [7:0] PRDATA,
	output PREADY,
	output PSLVERR
);
	wire [7:0] TDR;
	wire [7:0] TCR;
	wire [7:0] CNT;
	wire S_TMR_UDF;
	wire S_TMR_OVF;
	wire clk_div;
	wire load_pulse;

	RW_Controller CU (.PCLK(PCLK), .PRESETn(PRESETn), .PSEL(PSEL), .PENABLE(PENABLE), .PWRITE(PWRITE), .PADDR(PADDR), .PWDATA(PWDATA), .S_TMR_UDF(S_TMR_UDF), .S_TMR_OVF(S_TMR_OVF), .PRDATA(PRDATA), .PREADY(PREADY), .PSLVERR(PSLVERR), .TDR(TDR), .TCR(TCR), .load_pulse(load_pulse));

	Generate_clock Clock_Div (.clk(PCLK), .rst(PRESETn), .sel(TCR[1:0]), .clk_o(clk_div));

	TCNT COUNTER (.PCLK(PCLK), .PRESETn(PRESETn), .CLK_in(clk_div), .TDR(TDR), .EN(TCR[4]), .LOAD(load_pulse), .DOWN(TCR[5]), .CNT(CNT));

	SFR ACC (.PCLK(PCLK), .PRESETn(PRESETn), .EN(TCR[4]), .LOAD(load_pulse), .DOWN(TCR[5]),  .CNT(CNT), .S_TMR_UDF(S_TMR_UDF), .S_TMR_OVF(S_TMR_OVF));

endmodule
