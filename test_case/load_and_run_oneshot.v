// test_case/load_and_run_oneshot.v
// Test kiem tra chuc nang "Load-va-Run" trong 1 thao tac ghi.
reg [7:0] tdr_val;
reg [7:0] rd_tsr;

initial begin
  // 1. Khoi tao + reset
  PSEL    = 0;
  PENABLE = 0;
  PWRITE  = 0;
  PADDR   = 8'h00;
  PWDATA  = 8'h00;
  PRESETn = 0;
  repeat (3) @(posedge PCLK);
  PRESETn = 1;

  // 2. Ghi gia tri vao TDR
  tdr_val = 8'h80; // (128)
  $display("[%0t] TEST: Writing 0x%0h to TDR", $time, tdr_val);
  apb_write(ADDR_TDR, tdr_val);

  // 3. Cho LOAD=1:
  // Ghi vao TCR voi ca LOAD=1 VA EN=1
  // Gia tri: 8'b1001_0000 = 8'h90
  // (LOAD=TCR[7]=1, EN=TCR[4]=1, CLK_SEL=TCR[1:0]=00 -> PCLK/2)
  $display("[%0t] TEST: Writing 0x90 to TCR (LOAD=1, EN=1)", $time);
  apb_write(ADDR_TCR, 8'h90); 

  // 4. Doi cho overflow
  // PCLK = 10ns, PCLK/2 = 20ns
  // So dem = 256 - 128 = 128
  // Thoi gian du kien = 128 * 20ns = 2560ns
  #3000; // Doi 3000ns

  // 5. Doc TSR
  apb_read(ADDR_TSR, rd_tsr);

  // 6. Kiem tra Overflow (TSR[0])
  if (rd_tsr[0] == 1'b1) begin
    $display("[%0t] [PASS] Overflow flag is set (TSR=0x%0h). 'Load-and-Run' one-shot SUCCESSFUL.", $time, rd_tsr);
  end else begin
    $error("[%0t] [FAULTY] Overflow flag not set (TSR=0x%0h). Counter did not run!", $time, rd_tsr);
  end

  #100;
  $display("=== TEST DONE: load_and_run_oneshot ===");
  $finish;
end
