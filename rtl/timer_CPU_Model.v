module timer_CPU_Model(
        input cpu_clk, cpu_reset, cpu_pready, cpu_pslverr,
        input [7:0] cpu_prdata,
        output reg cpu_psel, cpu_penable, cpu_pwrite,
        output reg [7:0] cpu_paddr, cpu_pwdata
);

// Read data from register
        task READ;
                input [7:0] address;
                begin
                        @(posedge cpu_clk);
                        #1;
                        cpu_psel = 1'b1;
                        cpu_pwrite = 1'b0;
                        cpu_paddr = address;
                        $display ("Start read at address = %h", address, "\n");
                        @(posedge cpu_clk);
                        #1;
                        cpu_penable = 1'b1;
                        //turn off control signal
                        @(posedge cpu_clk);
                        #1;
                        cpu_psel = 1'b0;
                        cpu_pwrite = 1'b0;
                        cpu_penable = 1'b0;
                        cpu_paddr = 8'b0;
                        @(posedge cpu_clk);
                        #1;
                        $display ("Read transfer finished ", "\n");
                end
        endtask


// Write data to register
        task NORMAL_WRITE;
                input [7:0] address, data;
                begin
                        @(posedge cpu_clk);
                        #1;
                        cpu_psel = 1'b1;
                        cpu_pwrite = 1'b1;
                        cpu_paddr = address;
                        cpu_pwdata = data;
                        $display ("Start write to address = %h, data = %h\n", address, data);
                        @(posedge cpu_clk);
                        #1;
                        cpu_penable = 1'b1;
                        //turn off control signal
                        @(posedge cpu_clk);
                        #1;
                        cpu_penable = 1'b0;
                        cpu_psel = 1'b0;
                        cpu_pwrite = 1'b0;
                        cpu_paddr = 8'b0;
                        cpu_pwdata = 8'b0;
                        @(posedge cpu_clk);
                        #1;
                        $display ("Write transfer finished\n");
                end
        endtask


//check register
        task CHECK_READ;
                input [7:0]  data, address;
                output [1:0] err_flg;
                if (data == cpu_prdata) begin
                        $display (" DATA: %h ", cpu_prdata);
                        $display ("PADSSED");
                        err_flg[0] = 1'b1;
                end else if((data != cpu_prdata) && (address > 8'h07)) begin
                        $display (" DATA: %h, EXPECTED: %h ", cpu_prdata, data);
                        $display (" FAILED ");
                        err_flg[0] = 1'b1;
                end else begin
                        $display (" DATA: %h, EXPECTED: %h ", cpu_prdata, data);
                        $display (" FAILED READ ");
                        err_flg[1] = 1'b1;
                end
        endtask



        task CHECK;
                input  [7:0] data;
                input  [7:0] out;
                output [1:0] err_flg;

                if (data == out) begin
                        $display (" PADSSED ");
                        err_flg[0] = 1'b1;
                end else begin
                        $display (" FAILED  ");
                        err_flg[1] = 1'b1;
                end
        endtask



        task CHECK_WRITE;
                input  [7:0] address, data;
                input  [7:0] A, B, C, D, E, F, G, H;
                output [1:0] err_flg;

                case (address)
                        8'h0 : CHECK(data, A, err_flg);
                        8'h1 : CHECK(data, B, err_flg);
                        8'h2 : CHECK(data, C, err_flg);
                        8'h3 : CHECK(data, D, err_flg);
                        8'h4 : CHECK(data, E, err_flg);
                        8'h5 : CHECK(data, F, err_flg);
                        8'h6 : CHECK(data, G, err_flg);
                        8'h7 : CHECK(data, H, err_flg);
                        default: begin
                                $display (" ERROR ADDRESS ");
                        end
                endcase
        endtask



// Check TCNT
        task CHECK_CNT;
                input  [7:0] data_TDR, CNT;
                output [1:0] err_flg;

                begin
                        $display("Start check data between TDR register and initial vaue of CNT\n");
                        if (data_TDR == CNT) begin
                                $display ("Data = %h, Expected = %h\n", data_TDR, CNT);
                                $display (" PADSSED ");
                                err_flg = 2'b01;
                        end else begin
                                $display ("Data = %h, Expected = %h\n", data_TDR, CNT);
                                $display (" FAILED ");
                                err_flg = 2'b10;
                        end
                        $display("Check data finished\n");
                end
        endtask



// Check pass/fail
        task CHECK_BY_PASS;
                input [1:0] err_flg;
                begin
                        if (err_flg[1]) begin
                                $display(" TEST FAIL ");
                        end else if (err_flg[0]) begin
                                $display(" TEST PASS  ");
                        end
                end
        endtask

endmodule

