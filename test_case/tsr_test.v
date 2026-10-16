integer i;
reg [7:0] rd, wr;

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

  // 1) read tsr -> check default value (expect 0x00)
  apb_read(ADDR_TSR, rd);
  if (rd !== 8'h00) begin
    $error("[TSR default] Expected 0x00, got 0x%0h", rd);
    $fatal;
  end else $display("[TSR default] OK: 0x%0h", rd);

  // 2-4) repeat 20 times:
  //     write random value to TSR (addr=2)
  //     read TSR and compare against 0 (software write should clear or be masked to 0)
  for (i = 0; i < 20; i = i + 1) begin
    wr = $urandom_range(0, 255);
    apb_write(ADDR_TSR, wr);
    apb_read (ADDR_TSR, rd);

    if (rd !== 8'h00) begin
      $error("[TSR RW #%0d] Expected 0x00 after write 0x%0h, got 0x%0h", i, wr, rd);
      $fatal;
    end else begin
      $display("[TSR RW #%0d] OK: wrote 0x%0h, read back 0x00", i, wr);
    end
  end

  $display("=== TEST PASSED: TSR default=0, write-random/read=0 repeated 20 times ===");
  $finish;
end