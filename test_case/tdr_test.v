integer i;
  reg [7:0] rd, wr;

  initial begin
    PSEL    = 0;
    PENABLE = 0;
    PWRITE  = 0;
    PADDR   = 8'h00;
    PWDATA  = 8'h00;

    PRESETn = 0;
    repeat (3) @(posedge PCLK);
    PRESETn = 1;

    apb_read(8'h00, rd); 
    if (rd !== 8'h00) begin
      $error("[TDR default] Expected 0x00, got 0x%0h", rd);
      $fatal;
    end else begin
      $display("[TDR default] OK: 0x%0h", rd);
    end

    for (i = 0; i < 20; i = i + 1) begin
      wr = $urandom_range(0, 255);
      apb_write(8'h00, wr); 
      apb_read (8'h00, rd);
      if (rd !== wr) begin
        $error("[TDR RW #%0d] MISMATCH: wrote 0x%0h, read 0x%0h", i, wr, rd);
        $fatal;
      end else begin
        $display("[TDR RW #%0d] OK: wrote 0x%0h, read 0x%0h", i, wr, rd);
      end
    end

    $display("=== TEST PASSED: TDR read/write repeated 20 times ===");
    $finish;
  end
