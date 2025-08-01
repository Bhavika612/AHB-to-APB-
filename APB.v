module APB_SLAVE #(
    parameter ADDR_WIDTH = 8,              
    parameter DATA_WIDTH = 32,             
    parameter BASE_ADDR  = 24'h400000      // Valid address prefix
)(
    input  wire                    PCLK,      
    input  wire                    PRESETn,   
    input  wire                    PSEL,      
    input  wire                    PENABLE,   
    input  wire                    PWRITE,    
    input  wire [31:0]             PADDR,     
    input  wire [DATA_WIDTH-1:0]   PWDATA,    
    output reg  [DATA_WIDTH-1:0]   PRDATA,    
    output reg                     PREADY,    
    output reg  [1:0]              PSLVERR    
);

    // Memory declaration
    localparam MEM_DEPTH = 1 << ADDR_WIDTH;
    reg [DATA_WIDTH-1:0] memory [0:MEM_DEPTH-1];

    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            PRDATA   <= {DATA_WIDTH{1'b0}};
            PREADY   <= 1'b0;
            PSLVERR  <= 2'b00;
        end else begin
            PREADY <= 1'b0;
            PSLVERR <= 2'b00;

            if (PSEL && PENABLE) begin
                PREADY <= 1'b1;

                // Check for valid address region
                if (PADDR[31:ADDR_WIDTH] == BASE_ADDR) begin
                    if (PWRITE) begin
                        memory[PADDR[ADDR_WIDTH-1:0]] <= PWDATA;
                    end else begin
                        PRDATA <= memory[PADDR[ADDR_WIDTH-1:0]];
                    end
                end else begin
                    PSLVERR <= PWRITE ? 2'b01 : 2'b10; // Write error or read error
                end
            end
        end
    end
endmodule
