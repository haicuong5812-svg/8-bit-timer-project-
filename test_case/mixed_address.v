// localparam [7:0] ADDR_TDR = 8'h00; 
// localparam [7:0] ADDR_TCR = 8'h01;
// localparam [7:0] ADDR_TSR = 8'h02;
localparam [7:0] TCR_MASK = 8'b1011_0011;

task apb_write_slverr;
  input  [7:0] addr;
  input  [7:0] data;
  output       slverr;
  reg          slverr;
begin
  slverr = 1'b0;

  // SETUP
  @(posedge PCLK);
  PSEL    <= 1'b1;
  PENABLE <= 1'b0;
  PWRITE  <= 1'b1;
  PADDR   <= addr;
  PWDATA  <= data;

  // ACCESS
  @(posedge PCLK);
  PENABLE <= 1'b1;


  @(posedge PCLK);
  slverr  = PSLVERR;
  PSEL    <= 1'b0;
  PENABLE <= 1'b0;
  PWRITE  <= 1'b0;
end
endtask


task apb_read_slverr;
  input  [7:0] addr;
  output [7:0] data;
  output       slverr;
  reg          slverr;
begin
  slverr = 1'b0;

  // SETUP
  @(posedge PCLK);
  PSEL    <= 1'b1;
  PENABLE <= 1'b0;
  PWRITE  <= 1'b0;
  PADDR   <= addr;

  // ACCESS
  @(posedge PCLK);
  PENABLE <= 1'b1;


  // SAMPLE
  @(posedge PCLK);
  data = PRDATA;
  slverr  = PSLVERR;

  // TEARDOWN
  PSEL    <= 1'b0;
  PENABLE <= 1'b0;
end
endtask

integer i;
reg [7:0] addr, wr, rd;
reg       werr, rerr;

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

  for (i = 0; i < 20; i = i + 1) begin
    addr = $random; // use low 8 bits
    wr   = $random;

    apb_write_slverr(addr, wr, werr);
    apb_read_slverr (addr, rd, rerr);

    if (werr || rerr) begin
      $display("NULL-ADDRESS addr=0x%0h PSLVERR(w=%0b,r=%0b)", addr, werr, rerr);
    end else begin
      if (addr == ADDR_TDR) begin
        if (rd !== wr) begin
          $error("[TDR] MISMATCH: addr=0x%0h wrote 0x%0h read 0x%0h", addr, wr, rd);
          $fatal;
        end else
          $display("[TDR] OK: addr=0x%0h wrote 0x%0h read 0x%0h", addr, wr, rd);

      end else if (addr == ADDR_TCR) begin
        if ( (rd & TCR_MASK) !== (wr & TCR_MASK) ) begin
          $error("[TCR] MISMATCH: addr=0x%0h wrote 0x%0h(mask->0x%0h) read 0x%0h(mask->0x%0h)",
                 addr, wr, (wr & TCR_MASK), rd, (rd & TCR_MASK));
          $fatal;
        end else
          $display("[TCR] OK: addr=0x%0h wrote 0x%0h(mask->0x%0h) read 0x%0h(mask->0x%0h)",
                   addr, wr, (wr & TCR_MASK), rd, (rd & TCR_MASK));

      end else if (addr == ADDR_TSR) begin
        if (rd !== 8'h00) begin
          $error("[TSR] EXPECT 0: addr=0x%0h wrote 0x%0h read 0x%0h", addr, wr, rd);
          $fatal;
        end else
          $display("[TSR] OK: addr=0x%0h wrote 0x%0h read 0x00", addr, wr);

      end else begin
        $display("[UNEXPECTED] addr=0x%0h valid without PSLVERR", addr);
      end
    end
  end

  $display("=== TEST DONE: mixed_address sequence repeated 20 times ===");
  $finish;
end