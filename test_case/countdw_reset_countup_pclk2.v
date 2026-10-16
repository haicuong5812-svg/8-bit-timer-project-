// Test Sequence
reg [7:0] tdr_val_pre_reset, rd_data; 
reg       reset_check_pass;
integer   i;

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

  // 1. Write value and Load 
  tdr_val_pre_reset = $random % 256; 
  $display("[%0t] TEST: Writing 0x%0h to TDR", $time, tdr_val_pre_reset);
  apb_write(ADDR_TDR, tdr_val_pre_reset); 
  $display("[%0t] TEST: Loading TCNT from TDR", $time);
  apb_write(ADDR_TCR, TCR_LOAD_VAL); 

  // 2. Start timer: EN=1, DOWN mode, PCLK/2
  $display("[%0t] TEST: Starting count-down PCLK/2", $time);
  apb_write(ADDR_TCR, TCR_RUN_DW_PCLK2); 
  
  // 3. runtime
  #1000; 
  
  // 4. Trigger Reset
  $display("[%0t] TEST: Triggering RESET (PRESETn=0)", $time);
  PRESETn <= 1'b0; 
  repeat (5) @(posedge PCLK); 
  PRESETn <= 1'b1; 
  $display("[%0t] TEST: Releasing RESET (PRESETn=1)", $time);
  #100;

  // 5. Check if registers TDR, TCR, TSR are reset to 0
  reset_check_pass = 1'b1; 
  apb_read(ADDR_TDR, rd_data); 
  if (rd_data !== 8'h00) begin
    $error("[%0t] [RESET CHECK] FAULTY: TDR not reset to 0 (Value=0x%0h)", $time, rd_data); 
    reset_check_pass = 1'b0; 
  end
  
  apb_read(ADDR_TCR, rd_data);
  if (rd_data !== 8'h00) begin
    $error("[%0t] [RESET CHECK] FAULTY: TCR not reset to 0 (Value=0x%0h)", $time, rd_data);
    reset_check_pass = 1'b0; 
  end
  
  apb_read(ADDR_TSR, rd_data);
  if (rd_data !== 8'h00) begin
    $error("[%0t] [RESET CHECK] FAULTY: TSR not reset to 0 (Value=0x%0h)", $time, rd_data);
    reset_check_pass = 1'b0; 
  end

  if (reset_check_pass) begin
      $display("[%0t] [RESET CHECK] PASS: TDR, TCR, TSR are reset to 0", $time); 
  end else begin
      $fatal; 
  end
  
  // 6. Start new operation: Count-up 
  $display("[%0t] TEST: Writing 0x%0h (same value) to TDR", $time, tdr_val_pre_reset);
  apb_write(ADDR_TDR, tdr_val_pre_reset); 
  $display("[%0t] TEST: Loading TCNT from TDR", $time);
  apb_write(ADDR_TCR, TCR_LOAD_VAL);
  
  $display("[%0t] TEST: Starting count-up PCLK/2", $time);
  apb_write(ADDR_TCR, TCR_RUN_UP_PCLK2); 

  // 7. wait OVF
  #8000; 

  // 8. Check OVF flag (1)
  apb_read(ADDR_TSR, rd_data); 
  if (rd_data[0] == 1'b1) begin 
    $display("[%0t] [POST-RESET CHECK] PASS: Overflow flag is set after reset (TSR=0x%0h)", $time, rd_data); 
  end else begin
    $error("[%0t] [POST-RESET CHECK] FAULTY: Overflow flag not set after reset (TSR=0x%0h)", $time, rd_data); 
  end
  
  #100;
  $display("=== TEST DONE: countdw_reset_countup_pclk2 ==="); 
  $finish; 
end