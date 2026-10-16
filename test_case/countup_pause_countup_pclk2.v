// Test Sequence
reg [7:0] tdr_val;
reg [7:0] rd_tsr;
integer time_to_ovf, run_time_1, pause_time, run_time_2;

initial begin
  // init
  PSEL    = 0;
  PENABLE = 0;
  PWRITE  = 0;
  PADDR   = 8'h00;
  PWDATA  = 8'h00;

  // reset
  PRESETn = 0;
  repeat (3) @(posedge PCLK);
  PRESETn = 1;

  // 1. Write random value to TDR
  tdr_val = 8'h80; // 128
  $display("[%0t] TEST: Writing 0x%0h to TDR (addr=0x%0h)", $time, tdr_val, ADDR_TDR);
  apb_write(ADDR_TDR, tdr_val);

  // 2. Load value from TDR into TCNT
  $display("[%0t] TEST: Loading TCNT from TDR (writing 0x%0h to TCR)", $time, TCR_LOAD_VAL);
  apb_write(ADDR_TCR, TCR_LOAD_VAL);
  
  time_to_ovf = (256 - tdr_val) * 20; 
  run_time_1 = 1000; 
  pause_time = 2000; 
  run_time_2 = 2000; 

  // 3. Start timer: EN=1, UP mode, PCLK/2
  $display("[%0t] TEST: Starting count-up PCLK/2 (writing 0x%0h to TCR)", $time, TCR_RUN_UP_PCLK2);
  apb_write(ADDR_TCR, TCR_RUN_UP_PCLK2);
  
  // 4. Runtime
  #(run_time_1);
  
  // 5. Pause timer (off EN)
  $display("[%0t] TEST: Pausing timer (writing 0x%0h to TCR)", $time, TCR_PAUSE_PCLK2);
  apb_write(ADDR_TCR, TCR_PAUSE_PCLK2);

  // 6. wait 
  #(pause_time);

  // 7. Check OVF flag (0)
  apb_read(ADDR_TSR, rd_tsr);
  if (rd_tsr[0] == 1'b1) begin
    $error("[%0t] [PAUSE CHECK] FAULTY: Overflow flag set during pause (TSR=0x%0h)", $time, rd_tsr);
  end else begin
    $display("[%0t] [PAUSE CHECK] PASS: Overflow flag not set during pause (TSR=0x%0h)", $time, rd_tsr);
  end

  // 8. Resume timer (on EN)
  $display("[%0t] TEST: Resuming timer (writing 0x%0h to TCR)", $time, TCR_RUN_UP_PCLK2);
  apb_write(ADDR_TCR, TCR_RUN_UP_PCLK2);
  
  // 9. wait
  #(run_time_2);

  // 10. Check OVF flag (1)
  apb_read(ADDR_TSR, rd_tsr);
  if (rd_tsr[0] == 1'b1) begin
    $display("[%0t] [RESUME CHECK] PASS: Overflow flag is set after resume (TSR=0x%0h)", $time, rd_tsr);
  end else begin
    $error("[%0t] [RESUME CHECK] FAULTY: Overflow flag not set after resume (TSR=0x%0h)", $time, rd_tsr);
  end

  #100;
  $display("=== TEST DONE: countup_pause_countup_pclk2 ===");
  $finish;
end