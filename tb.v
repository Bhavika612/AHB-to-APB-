module tb;

//AHB Slave Interface
reg         HCLK, HRESETn, HSELAPB, HWRITE;
reg  [1:0]  HTRANS;
reg  [31:0] HADDR, HWDATA;
wire        HRESP;
wire [31:0] HRDATA;

//APB Signals
reg  [31:0] PRDATA;
wire        PSEL, PENABLE, PWRITE, HREADY;
wire [31:0] PADDR, PWDATA;

// Clock Generation
initial HCLK = 0;
always #1 HCLK = ~HCLK;  
// Simulation Control: DUMP VCD + INIT

`ifdef Single_Read
initial begin
    $dumpfile("Single_Read.vcd");
    $dumpvars;
end
initial begin
    // Single Read Transfer
    HRESETn = 0;
    HWRITE  = 0;
    HSELAPB = 0;
    HTRANS  = 2'b00;
    HADDR   = 32'h0;
    #3 HRESETn = 1;

    HSELAPB = 1;
    HTRANS  = 2'b10; // NONSEQ
    HADDR   = 32'h0000_0020;

    #2.1;
    HSELAPB = 0;
    HTRANS  = 2'b00;
    HADDR   = 32'hxxxx_xxxx;

    #1.9 PRDATA = 32'h0000_0010;  // Sample return data
    #2 $finish;
end
`endif

`ifdef Single_Write
initial begin
    $dumpfile("Single_Write.vcd");
    $dumpvars;
end
initial begin
    // Single Write Transfer
    HRESETn = 0;
    HWRITE  = 0;
    HSELAPB = 0;
    HTRANS  = 2'b00;
    HADDR   = 32'h0;
    #3 HRESETn = 1;

    HWRITE  = 1;
    HSELAPB = 1;
    HTRANS  = 2'b10; // NONSEQ
    HADDR   = 32'h0000_0000;

    #2 HWDATA = 32'h0000_00FF;

    #0.1 HWRITE = 1'bx;
         HSELAPB = 0;
         HTRANS = 2'b00;
         HADDR = 32'hxxxx_xxxx;

    #6 $finish;
end
`endif

`ifdef Burst_Read
initial begin
    $dumpfile("Burst_Read.vcd");
    $dumpvars;
end
initial begin
    // Burst Read Transfer
    HRESETn = 0;
    HWRITE  = 0;
    HSELAPB = 0;
    HTRANS  = 2'b00;
    HADDR   = 32'h0;
    #3 HRESETn = 1;

    HWRITE  = 0;
    HSELAPB = 1;
    HTRANS  = 2'b10; // NONSEQ
    HADDR   = 32'h0000_0000;

    #2.1 HTRANS = 2'b11; // SEQ
         HADDR  = 32'h0000_0100;
    #1.9 PRDATA = 32'hFFFF_FFFF;

    #2.1 HADDR  = 32'h0000_1000;
    #1.9 PRDATA = 32'hFFFF_FFFB;

    #2.1 HADDR  = 32'h0000_1100;
    #1.9 PRDATA = 32'hFFFF_FFF8;

    #2.1 HWRITE  = 1'bx;
         HADDR   = 32'hxxxx_xxxx;
         HTRANS  = 2'bxx;
         HSELAPB = 1'bx;
    #1.9 PRDATA = 32'hFFFF_FFF4;

    #6 $finish;
end
`endif

`ifdef Burst_Write
initial begin
    $dumpfile("Burst_Write.vcd");
    $dumpvars;
end
initial begin
    // Burst Write Transfer
    HRESETn = 0;
    HWRITE  = 0;
    HSELAPB = 0;
    HTRANS  = 2'b00;
    HADDR   = 32'h0;
    #3 HRESETn = 1;

    HWRITE  = 1;
    HSELAPB = 1;
    HTRANS  = 2'b10;
    HADDR   = 32'h0000_0000;

    #2.1 HWDATA = 32'h0000_000F;
          HADDR  = 32'h0000_0100;
          HTRANS = 2'b11;

    #2 HWDATA = 32'h0000_00F0;
         HADDR  = 32'h0000_1000;

    #4 HWDATA = 32'h0000_0F00;
         HADDR  = 32'h0000_1100;

    #4 HWDATA = 32'h0000_F000;
         HWRITE = 1'bx;
         HSELAPB = 1'bx;
         HTRANS = 2'bxx;
         HADDR = 32'hxxxx_xxxx;

    #8 $finish;
end
`endif

// DUT Instantiation

ahb2apb DUT (
    .HCLK    (HCLK),
    .HRESETn (HRESETn),
    .HSELAPB (HSELAPB),
    .HADDR   (HADDR),
    .HWRITE  (HWRITE),
    .HTRANS  (HTRANS),
    .HWDATA  (HWDATA),
    .HRESP   (HRESP),
    .HRDATA  (HRDATA),
    .HREADY  (HREADY),
    .PRDATA  (PRDATA),
    .PSEL    (PSEL),
    .PENABLE (PENABLE),
    .PADDR   (PADDR),
    .PWRITE  (PWRITE),
    .PWDATA  (PWDATA)
);

endmodule
