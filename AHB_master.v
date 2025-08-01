module AHB_MASTER #(
    parameter ADDR_WIDTH  = 32,
    parameter DATA_WIDTH  = 32,
    parameter HSIZE_VALUE = 3'b010,   // Default: 32-bit transfer
    parameter HPROT_VALUE = 4'b0011   // Default: data access, non-privileged, secure, non-bufferable
)(
    input  wire                   HCLK,
    input  wire                   HRESETn,
    input  wire                   HREADY,
    input  wire [1:0]             HRESP,
    input  wire [DATA_WIDTH-1:0]  HRDATA,
    input  wire                   request_write,
    input  wire                   request_read,
    input  wire [DATA_WIDTH-1:0]  write_data,
    input  wire [ADDR_WIDTH-1:0]  read_addr,
    input  wire [ADDR_WIDTH-1:0]  write_addr,
    output reg  [ADDR_WIDTH-1:0]  HADDR,
    output reg  [DATA_WIDTH-1:0]  HWDATA,
    output reg                    HWRITE,
    output reg  [2:0]             HSIZE,
    output reg  [2:0]             HBURST,
    output reg  [3:0]             HPROT,
    output reg  [1:0]             HTRANS,
    output reg  [DATA_WIDTH-1:0]  read_data,
    output reg                    error_flag
);

    // AHB transfer types
    localparam IDLE   = 2'b00;
    localparam BUSY   = 2'b01;
    localparam NONSEQ = 2'b10;
    localparam SEQ    = 2'b11;

    reg [1:0] state;

    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            HADDR      <= {ADDR_WIDTH{1'b0}};
            HWDATA     <= {DATA_WIDTH{1'b0}};
            HWRITE     <= 1'b0;
            HSIZE      <= HSIZE_VALUE;
            HBURST     <= 3'b000;
            HPROT      <= HPROT_VALUE;
            HTRANS     <= IDLE;
            state      <= IDLE;
            read_data  <= {DATA_WIDTH{1'b0}};
            error_flag <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    error_flag <= 1'b0; // Clear error flag
                    if (request_write) begin
                        HADDR  <= write_addr; 
                        HWDATA <= write_data;
                        HWRITE <= 1'b1;
                        HTRANS <= NONSEQ;
                        state  <= BUSY;
                    end else if (request_read) begin
                        HADDR  <= read_addr;
                        HWRITE <= 1'b0;
                        HTRANS <= NONSEQ;
                        state  <= BUSY;
                    end else begin
                        HTRANS <= IDLE;
                    end
                end

                BUSY: begin
                    if (HREADY) begin
                        if (HRESP == 2'b00) begin
                            if (!HWRITE) begin
                                read_data <= HRDATA;
                            end
                        end else begin
                            error_flag <= 1'b1;
                        end
                        HTRANS <= IDLE;
                        state  <= IDLE;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
