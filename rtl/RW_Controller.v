module RW_Controller (
	input PCLK,
	input PRESETn,
	input PSEL,
	input PENABLE,
	input PWRITE,
	input [7:0] PADDR,
	input [7:0] PWDATA,
	input S_TMR_UDF,
	input S_TMR_OVF,
	output [7:0] PRDATA,
	output PREADY,
	output PSLVERR,
	output [7:0] TDR,
	output [7:0] TCR,
	output load_pulse
);

	reg  [1:0] TSR;
	wire [7:0] TSR_buf;
	wire [2:0] sel_reg;
	wire err;
	wire [7:0] RBPWDATA;
	wire TSR_OVF, TSR_UDF;
	wire pready_internal;

	Mux mu (.paddr(PADDR), .select_reg(sel_reg));

	Reg Reg_TDR (.clk(PCLK), .rstn(PRESETn), .psel(PSEL), .pwrite(PWRITE), .penable(PENABLE), .pready(pready_internal), .sel_reg(sel_reg[0]), .pwdata(RBPWDATA), .out(TDR));
	Reg Reg_TCR (.clk(PCLK), .rstn(PRESETn), .psel(PSEL), .pwrite(PWRITE), .penable(PENABLE), .pready(pready_internal), .sel_reg(sel_reg[1]), .pwdata(RBPWDATA), .out(TCR));
	Reg Reg_TSR (.clk(PCLK), .rstn(PRESETn), .psel(PSEL), .pwrite(PWRITE), .penable(PENABLE), .pready(pready_internal), .sel_reg(sel_reg[2]), .pwdata(RBPWDATA), .out(TSR_buf));

	assign  RBPWDATA = sel_reg[0] ? PWDATA : sel_reg[1] ? {PWDATA[7], 1'h0, PWDATA[5:4], 2'h0, PWDATA[1:0]} : sel_reg[2] ? {6'h0, (PWDATA[1:0] ? 2'h0 : PWDATA[1:0])} : 8'h0;
	assign  load_pulse = PWRITE && PENABLE && pready_internal && sel_reg[1] && PWDATA[7];

	always @(posedge PCLK, negedge PRESETn) begin

		if (!PRESETn) begin
    			TSR[0] <=  1'b0;
  		end else if (S_TMR_OVF) begin
  			TSR[0] <=  1'b1;
		end else if (PWRITE && PENABLE && pready_internal && sel_reg[2]) begin
			TSR[0] <=  TSR_buf[0];
		end
		
		if (!PRESETn) begin
  			TSR[1] <=  1'b0;
		end else if (S_TMR_UDF) begin
			TSR[1] <=  1'b1;
		end else if (PWRITE && PENABLE && pready_internal && sel_reg[2]) begin
			TSR[1] <=  TSR_buf[1];
		end
	end

	Prd read_reg (.clk (PCLK), .rstn (PRESETn), .pready (pready_internal), .psel (PSEL), .pwrite (PWRITE), .penable(PENABLE), .paddr (PADDR), .TDR (TDR), .TCR (TCR), .TSR ({TSR_buf[7:2], TSR}), .out (PRDATA));

	Pre pready_signal (.clk(PCLK), .rstn (PRESETn), .psel (PSEL), .penable (PENABLE), .pready (pready_internal));

	Psl pslerr_signal (.clk (PCLK), .rstn (PRESETn), .select_reg (sel_reg), .pslverr (err));
	assign PREADY = pready_internal;
	assign  PSLVERR = err & PREADY;

endmodule

