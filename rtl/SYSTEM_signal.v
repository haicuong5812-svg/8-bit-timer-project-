module SYSTEM_signal(
	output reg sys_clk, sys_reset
);
	initial begin
       		sys_clk = 1'b0;
       		#10;
       		forever begin
         		#10 sys_clk = !sys_clk;
       		end
    	end

    	initial begin
       		sys_reset = 1'b0;
       		#100 sys_reset = 1'b1;
    	end

endmodule
