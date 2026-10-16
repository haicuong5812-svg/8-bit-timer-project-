// localparam [7:0] ADDR_TDR = 8'h00; 
// localparam [7:0] ADDR_TCR = 8'h01;
// localparam [7:0] ADDR_TSR = 8'h02;
localparam [7:0] TCR_MASK = 8'b1011_0011;


task automatic apb_write_slverr; 
  input  [7:0] addr;
  input  [7:0] data;
  output       slverr;
  reg          slverr;
begin
  slverr = 1'b0;
  @(posedge PCLK);
  PSEL    <= 1'b1;
  PENABLE <= 1'b0;
  PWRITE  <= 1'b1;
  PADDR   <= addr;
  PWDATA  <= data;

  @(posedge PCLK);
  PENABLE <= 1'b1;

  @(posedge PCLK);
  slverr  = PSLVERR; 
  PSEL    <= 1'b0;
  PENABLE <= 1'b0;
  PWRITE  <= 1'b0;
end
endtask


task automatic apb_read_slverr;
  input  [7:0] addr;
  output [7:0] data;
  output       slverr;
  reg          slverr;
begin
  slverr = 1'b0;
  @(posedge PCLK);
  PSEL    <= 1'b1;
  PENABLE <= 1'b0;
  PWRITE  <= 1'b0;
  PADDR   <= addr;

  @(posedge PCLK);
  PENABLE <= 1'b1;

  @(posedge PCLK);
  data = PRDATA;
  slverr  = PSLVERR; 
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

    addr = $urandom_range(3, 255); 
    wr   = $random;

    apb_write_slverr(addr, wr, werr);
    apb_read_slverr (addr, rd, rerr);


    if (werr || rerr) begin
      $display("[NULL-ADDRESS] OK: addr=0x%0h PSLVERR(w=%0b,r=%0b)", addr, werr, rerr);
    end else begin
      $error("[UNEXPECTED] addr=0x%0h valid without PSLVERR", addr);
      $fatal;
    end
  end

  $display("=== TEST DONE: null_address (non-existed only) ===");
  $finish;
end