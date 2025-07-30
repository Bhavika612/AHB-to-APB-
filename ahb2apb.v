
// FSM State Encoding
`define IDLE     3'b000
`define READ     3'b001
`define WWAIT    3'b010
`define WRITE    3'b011
`define WRITEP   3'b100
`define WENABLE  3'b101
`define WENABLEP 3'b110
`define RENABLE  3'b111

module ahb2apb (
    input  wire        HCLK,
    input  wire        HRESETn,
    input  wire        HSELAPB,
    input  wire        HWRITE,
    input  wire [1:0]  HTRANS,
    input  wire [31:0] HADDR,
    input  wire [31:0] HWDATA,
    input  wire [31:0] PRDATA,
    
    output reg         HREADY,
    output reg         HRESP,
    output reg [31:0]  HRDATA,
    
    output reg         PSEL,
    output reg         PENABLE,
    output reg         PWRITE,
    output reg [31:0]  PADDR,
    output reg [31:0]  PWDATA
);

// Internal Signals
reg [2:0] ps, ns;               // Present and Next state
reg [31:0] TMP_HADDR, TMP_HWDATA;
reg valid;
reg HWrite;

//VALID Transfer Check
always @(*) begin
    if (HSELAPB && (HTRANS == 2'b10 || HTRANS == 2'b11))
        valid = 1'b1;
    else
        valid = 1'b0;
end

//FSM State Update 
always @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn)
        ps <= `IDLE;
    else
        ps <= ns;
end

//FSM Combinational Logic 
always @(*) begin
    // Default values
    HRESP   = 1'b0;
    PSEL    = 1'b0;
    PENABLE = 1'b0;
    PWRITE  = 1'b0;
    HREADY  = 1'b1;

    case (ps)
        `IDLE: begin
            if (!valid)
                ns = `IDLE;
            else if (valid && !HWRITE)
                ns = `READ;
            else
                ns = `WWAIT;
        end

        `READ: begin
            PSEL   = 1'b1;
            PADDR  = HADDR;
            PWRITE = 1'b0;
            PENABLE= 1'b0;
            HREADY = 1'b0;
            ns = `RENABLE;
        end

        `RENABLE: begin
            PENABLE = 1'b1;
            HRDATA  = PRDATA;
            HREADY  = 1'b1;

            if (valid && !HWRITE)
                ns = `READ;
            else if (valid && HWRITE)
                ns = `WWAIT;
            else
                ns = `IDLE;
        end

        `WWAIT: begin
            PENABLE     = 1'b0;
            TMP_HADDR   = HADDR;
            HWrite      = HWRITE;

            if (!valid)
                ns = `WRITE;
            else
                ns = `WRITEP;
        end

        `WRITE: begin
            PSEL    = 1'b1;
            PADDR   = TMP_HADDR;
            PWDATA  = HWDATA;
            PWRITE  = 1'b1;
            PENABLE = 1'b0;
            HREADY  = 1'b0;

            if (!valid)
                ns = `WENABLE;
            else
                ns = `WENABLEP;
        end

        `WRITEP: begin
            PSEL      = 1'b1;
            PADDR     = TMP_HADDR;
            PWDATA    = HWDATA;
            PWRITE    = 1'b1;
            PENABLE   = 1'b0;
            HREADY    = 1'b0;
            TMP_HADDR = HADDR;
            HWrite    = HWRITE;
            ns = `WENABLEP;
        end

        `WENABLE: begin
            PENABLE = 1'b1;
            HREADY  = 1'b1;

            if (valid && !HWRITE)
                ns = `READ;
            else if (valid && HWRITE)
                ns = `WWAIT;
            else
                ns = `IDLE;
        end

        `WENABLEP: begin
            PENABLE = 1'b1;
            HREADY  = 1'b1;

            if (!valid && HWrite)
                ns = `WRITE;
            else if (valid && HWrite)
                ns = `WRITEP;
            else
                ns = `READ;
        end

        default: begin
            ns = `IDLE;
        end
    endcase
end

endmodule
