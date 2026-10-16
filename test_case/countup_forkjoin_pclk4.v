// Test Sequence
reg [7:0] tdr_val;
reg [7:0] rd_tsr_1, rd_tsr_2;

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
  tdr_val = $random;
  $display("[%0t] TEST: Writing 0x%0h to TDR (addr=0x%0h)", $time, tdr_val, ADDR_TDR);
  apb_write(ADDR_TDR, tdr_val);

  // 2. Load value from TDR into TCNT
  $display("[%0t] TEST: Loading TCNT from TDR (writing 0x%0h to TCR)", $time, TCR_LOAD_VAL);
  apb_write(ADDR_TCR, TCR_LOAD_VAL);
  
  // 3. Start timer: EN=1, UP mode, PCLK/4
  $display("[%0t] TEST: Starting count-up PCLK/4 (writing 0x%0h to TCR)", $time, TCR_RUN_UP_PCLK4);
  apb_write(ADDR_TCR, TCR_RUN_UP_PCLK4);

  // 4. Fork two threads to check overflow status
  fork
    begin : thread_1
      #10000; 
      apb_read(ADDR_TSR, rd_tsr_1);
      if (rd_tsr_1[0] == 1'b1) // Check OVF bit (TSR[0])
        $display("[%0t] [THREAD 1] PASS: Overflow flag is set (TSR=0x%0h)", $time, rd_tsr_1);
      else
        $error("[%0t] [THREAD 1] FAULTY: Overflow flag not set (TSR=0x%0h)", $time, rd_tsr_1);
    end
    
    begin : thread_2
      #7000; 
      apb_read(ADDR_TSR, rd_tsr_2);
      if (rd_tsr_2[0] == 1'b1) // Check OVF bit (TSR[0])
        $error("[%0t] [THREAD 2] FAULTY: Overflow flag is set too early (TSR=0x%0h)", $time, rd_tsr_2);
      else
        $display("[%0t] [THREAD 2] PASS: Overflow flag is not set yet (TSR=0x%0h)", $time, rd_tsr_2);
    end
  join

  #100;
  $display("=== TEST DONE: countup_forkjoin_pclk4 ===");
  $finish;
end