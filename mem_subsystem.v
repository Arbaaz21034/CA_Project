

module Memory_Subsystem (
    input wire [31:0] input_address,
    input wire LOAD,
    input wire STORE,
    inout [31:0] data,
    input wire CLK
);

    wire READY;
    wire VALID;
    wire [31:0] DATA;
    wire ACK_ADDR;
    wire [3:0] ACK_DATA;


    L1D_Cache cache (
        .input_address(input_address),
        .CLK(CLK),
        .READY(READY),
        .VALID(VALID),
        .DATA(DATA),
        .data(data),

        
    );

    Main_Memory memory (
        .CLK(CLK),
    )

    assign cache.LOAD = LOAD && memory.LOAD;

    assign memory.STORE = STORE && cache.STORE;

    assign cache.READY = memory.READY;

    assign memory.VALID = cache.VALID;

    assign cache.DATA = memory.DATA;
    
    assign memory.DATA = cache.DATA;

    assign cache.ACK_ADDR = memory.ACK_ADDR;
    
    assign memory.ACK_DATA = cache.ACK_DATA;





