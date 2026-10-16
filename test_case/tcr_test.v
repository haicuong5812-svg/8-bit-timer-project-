// Mask for writable bits in TCR: 8'b1011_0011 (bits 7,5,4,1,0)
localparam [7:0] TCR_MASK = 8'b1011_0011;
// localparam [7:0] ADDR_TCR = 8'h01; 

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

  // 1) read tcr -> check default value (expect 0x00)
  apb_read(ADDR_TCR, rd);
  if (rd !== 8'h00) begin
    $error("[TCR default] Expected 0x00, got 0x%0h", rd);
    $fatal;
  end else $display("[TCR default] OK: 0x%0h", rd);

  // 2-4) repeat 20 times: write random to TCR (addr=1), read back & masked compare
  for (i = 0; i < 20; i = i + 1) begin
    wr = $urandom_range(0, 255);
    apb_write(ADDR_TCR, wr);
    apb_read (ADDR_TCR, rd);

    if ( (rd & TCR_MASK) !== (wr & TCR_MASK) ) begin
      $error("[TCR RW #%0d] MISMATCH: wrote 0x%0h (mask 0x%0h -> 0x%0h), read 0x%0h (mask -> 0x%0h)",
             i, wr, TCR_MASK, (wr & TCR_MASK), rd, (rd & TCR_MASK));
      $fatal;
    end else begin
      $display("[TCR RW #%0d] OK: wrote 0x%0h -> masked 0x%0h, read 0x%0h -> masked 0x%0h",
               i, wr, (wr & TCR_MASK), rd, (rd & TCR_MASK));
    end
  end

  $display("=== TEST PASSED: TCR read/write with mask %b repeated 20 times ===", TCR_MASK);
  $finish;
end