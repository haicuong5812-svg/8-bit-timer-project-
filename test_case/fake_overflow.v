// Test Sequence
reg [7:0] rd_tsr;

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

  // 1. Write 0xFF to TDR
  $display("[%0t] TEST: Writing 0xFF to TDR", $time);
  apb_write(ADDR_TDR, 8'hFF);

  // 2. Load 0xFF into TCNT
  $display("[%0t] TEST: Loading 0xFF into TCNT", $time);
  apb_write(ADDR_TCR, TCR_LOAD_VAL);

  // 3. Set timer to Disabled, Count-Up, PCLK/2
  $display("[%0t] TEST: Settfing timer (EN=0, UP=1)", $time);
  apb_write(ADDR_TCR, TCR_DISABLED_UP_PCLK2);
  
  // 4. Write 0x00 to TDR
  $display("[%0t] TEST: Writing 0x00 to TDR", $time);
  apb_write(ADDR_TDR, 8'h00);
  
  // 5. Load 0x00 into TCNT
  $display("[%0t] TEST: Loading 0x00 into TCNT", $time);
  apb_write(ADDR_TCR, TCR_LOAD_VAL);
  
  // 6. Ensure timer stays Disabled (EN=0, LOAD=0)
  $display("[%0t] TEST: Setting timer (EN=0, UP=1)", $time);
  apb_write(ADDR_TCR, TCR_DISABLED_UP_PCLK2);
  
  // 7. Wait and Check OVF flag
  #100; 
  apb_read(ADDR_TSR, rd_tsr);
  
  if (rd_tsr[0] == 1'b1) begin // Check OVF bit (TSR[0])
    $error("[%0t] [FAKE OVF CHECK] FAULTY: Fake Overflow detected! (TSR=0x%0h)", $time, rd_tsr);
  end else begin
    $display("[%0t] [FAKE OVF CHECK] PASS: Overflow flag not set (TSR=0x%0h)", $time, rd_tsr);
  end
  
  #100;
  $display("=== TEST DONE: fake_overflow ===");
  $finish;
end