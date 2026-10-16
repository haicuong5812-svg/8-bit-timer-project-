`timescale 1ns/1ps

module tb_cnt_tmr;

  // Clock & reset
  reg        PCLK;
  reg        PRESETn;

  // APB-lite signals
  reg        PSEL;
  reg        PENABLE;
  reg        PWRITE;
  reg  [7:0] PADDR;
  reg  [7:0] PWDATA;
  wire [7:0] PRDATA;
  wire       PREADY;
  wire       PSLVERR;

  localparam [7:0] ADDR_TDR = 8'h00;
  localparam [7:0] ADDR_TCR = 8'h01;
  localparam [7:0] ADDR_TSR = 8'h02;
  
  // TCR Bit definitions for IP_TIMER
  localparam [7:0] TCR_LOAD_VAL = 8'h80;
  
  localparam [7:0] TCR_RUN_UP_PCLK2 = 8'h10;
  localparam [7:0] TCR_RUN_UP_PCLK4 = 8'h11;
  localparam [7:0] TCR_RUN_UP_PCLK8 = 8'h12;
  localparam [7:0] TCR_RUN_UP_PCLK16 = 8'h13;
  
  localparam [7:0] TCR_RUN_DW_PCLK2 = 8'h30;
  localparam [7:0] TCR_RUN_DW_PCLK4 = 8'h31;
  localparam [7:0] TCR_RUN_DW_PCLK8 = 8'h32;
  localparam [7:0] TCR_RUN_DW_PCLK16 = 8'h33;
  
  localparam [7:0] TCR_PAUSE_PCLK2 = 8'h00;
  localparam [7:0] TCR_PAUSE_DW_PCLK2 = 8'h20;
  
  localparam [7:0] TCR_DISABLED_DW_PCLK2 = 8'h20; 
  localparam [7:0] TCR_DISABLED_UP_PCLK2 = 8'h00; 

  // DUT 
  IP_TIMER dut (
    .PCLK    (PCLK),
    .PRESETn (PRESETn),
    .PSEL    (PSEL),
    .PENABLE (PENABLE),
    .PWRITE  (PWRITE),
    .PADDR   (PADDR),
    .PWDATA  (PWDATA),
    .PRDATA  (PRDATA),
    .PREADY  (PREADY),
    .PSLVERR (PSLVERR)
  );

  initial PCLK = 1'b0;
  always  #5 PCLK = ~PCLK;

  // APB write (WAIT=0)
  task automatic apb_write(input [7:0] addr, input [7:0] data);
  begin
    @(posedge PCLK);
    PSEL    <= 1'b1;
    PENABLE <= 1'b0;
    PWRITE  <= 1'b1;
    PADDR   <= addr;
    PWDATA  <= data;

    @(posedge PCLK);
    PENABLE <= 1'b1;

    @(posedge PCLK);
    PSEL    <= 1'b0;
    PENABLE <= 1'b0;
    PWRITE  <= 1'b0;
  end
  endtask

  // APB read (WAIT=0)
  task automatic apb_read(input [7:0] addr, output [7:0] data);
  begin
    @(posedge PCLK);
    PSEL    <= 1'b1;
    PENABLE <= 1'b0;
    PWRITE  <= 1'b0;
    PADDR   <= addr;

    @(posedge PCLK);
    PENABLE <= 1'b1;

    @(posedge PCLK);
    data = PRDATA;
    PSEL    <= 1'b0;
    PENABLE <= 1'b0;
  end
  endtask

  `include "../test_case/testcase.v"

endmodule