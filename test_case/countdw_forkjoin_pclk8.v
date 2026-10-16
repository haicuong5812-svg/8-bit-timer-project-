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
  if (tdr_val < 8'h20) tdr_val = 8'h20; 
  $display("[%0t] TEST: Writing 0x%0h to TDR (addr=0x%0h)", $time, tdr_val, ADDR_TDR);
  apb_write(ADDR_TDR, tdr_val);

  // 2. Load value from TDR into TCNT
  $display("[%0t] TEST: Loading TCNT from TDR (writing 0x%0h to TCR)", $time, TCR_LOAD_VAL);
  apb_write(ADDR_TCR, TCR_LOAD_VAL);
  
  // 3. Start timer: EN=1, DOWN mode, PCLK/8
  $display("[%0t] TEST: Starting count-down PCLK/8 (writing 0x%0h to TCR)", $time, TCR_RUN_DW_PCLK8);
  apb_write(ADDR_TCR, TCR_RUN_DW_PCLK8);

  // 4. Fork two threads to check underflow status (TSR[1])
  fork
    begin : thread_1 
      #4000; 
      apb_read(ADDR_TSR, rd_tsr_1);
      
      if (rd_tsr_1[1] == 1'b1) begin // Check UDF bit (TSR[1])
        $display("[%0t] [THREAD 1] PASS: Underflow flag is set (TSR=0x%0h)", $time, rd_tsr_1);
      end else begin
        $error("[%0t] [THREAD 1] FAULTY: Underflow flag not set (TSR=0x%0h)", $time, rd_tsr_1);
      end

    end
    
    begin : thread_2 
      #2000; 
      apb_read(ADDR_TSR, rd_tsr_2);

      if (rd_tsr_2[1] == 1'b1) begin // Check UDF bit (TSR[1])
        $error("[%0t] [THREAD 2] FAULTY: Underflow flag is set too early (TSR=0x%0h)", $time, rd_tsr_2);
      end else begin
        $display("[%0t] [THREAD 2] PASS: Underflow flag is not set yet (TSR=0x%0h)", $time, rd_tsr_2);
      end

    end
  join

  #100;
  $display("=== TEST DONE: countdw_forkjoin_pclk8 ===");
  $finish;
end