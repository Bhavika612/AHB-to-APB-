module BRIDGE #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,

    parameter IDLE        = 3'b000,
    parameter READ        = 3'b001,
    parameter RENABLE     = 3'b010,
    parameter WWAIT       = 3'b011,
    parameter WRITE       = 3'b100,
    parameter WRITE_P     = 3'b101,
    parameter WENABLE     = 3'b110,
    parameter WENABLE_P   = 3'b111
)(
    input                        hclk,
    input                        hresetn,
    input                        hselapb,
    input                        hwrite,
    input       [1:0]            htrans,
    input       [ADDR_WIDTH-1:0] haddr,
    input       [DATA_WIDTH-1:0] hwdata,
    input       [DATA_WIDTH-1:0] prdata,

    output reg  [ADDR_WIDTH-1:0] paddr,
    output reg  [DATA_WIDTH-1:0] pwdata,
    output reg                   psel,
    output reg                   penable,
    output reg                   pwrite,
    output reg                   hresp,
    output reg                   hready,
    output reg  [DATA_WIDTH-1:0] hrdata
);

    reg [2:0] present_state, next_state;
    reg [ADDR_WIDTH-1:0] haddr_temp;
    reg [DATA_WIDTH-1:0] hwdata_temp;
    reg hwrite_temp;
    reg valid;

    // Valid AHB transaction: HSEL = 1 and HTRANS is NONSEQ (2'b10) or SEQ (2'b11)
    always @(*) begin
        valid = (hselapb == 1'b1) && (htrans == 2'b10 || htrans == 2'b11);
    end

    // State transition
    always @(posedge hclk or negedge hresetn) begin
        if (!hresetn)
            present_state <= IDLE;
        else
            present_state <= next_state;
    end

    // FSM and signal control
    always @(*) begin
        next_state = present_state;
        psel       = 1'b0;
        penable    = 1'b0;
        pwrite     = 1'b0;
        hready     = 1'b1;
        hresp      = 1'b0;
        paddr      = {ADDR_WIDTH{1'b0}};
        pwdata     = {DATA_WIDTH{1'b0}};
        hrdata     = {DATA_WIDTH{1'b0}};

        case (present_state)
            IDLE: begin
                hready = 1'b1;
                if (valid) begin
                    if (!hwrite)
                        next_state = READ;
                    else
                        next_state = WWAIT;
                end
            end

            READ: begin
                psel   = 1'b1;
                paddr  = haddr;
                pwrite = 1'b0;
                hready = 1'b0;
                next_state = RENABLE;
            end

            RENABLE: begin
                penable = 1'b1;
                hrdata  = prdata;
                hready  = 1'b1;
                if (valid) begin
                    if (!hwrite)
                        next_state = READ;
                    else
                        next_state = WWAIT;
                end else begin
                    next_state = IDLE;
                end
            end

            WWAIT: begin
                haddr_temp  = haddr;
                hwdata_temp = hwdata;
                hwrite_temp = hwrite;
                if (valid)
                    next_state = WRITE_P;
                else
                    next_state = WRITE;
            end

            WRITE: begin
                psel   = 1'b1;
                paddr  = haddr_temp;
                pwdata = hwdata_temp;
                pwrite = 1'b1;
                hready = 1'b0;
                if (valid)
                    next_state = WENABLE_P;
                else
                    next_state = WENABLE;
            end

            WRITE_P: begin
                psel   = 1'b1;
                paddr  = haddr_temp;
                pwdata = hwdata_temp;
                pwrite = 1'b1;
                hready = 1'b0;
                next_state = WENABLE_P;
            end

            WENABLE: begin
                penable = 1'b1;
                hready  = 1'b1;
                if (valid) begin
                    if (!hwrite)
                        next_state = READ;
                    else
                        next_state = WWAIT;
                end else begin
                    next_state = IDLE;
                end
            end

            WENABLE_P: begin
                penable = 1'b1;
                hready  = 1'b1;
                if (valid) begin
                    if (hwrite)
                        next_state = WRITE_P;
                    else
                        next_state = READ;
                end else if (!hwrite) begin
                    next_state = READ;
                end
            end

            default: next_state = IDLE;
        endcase
    end

endmodule
