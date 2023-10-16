

module MemorySubsystem (
    input wire [31:0] input_address,
    input wire LOAD,
    input wire STORE,
    inout [31:0] data,
    input wire CLK
);

    l1_dcache cache (
        .input_address(input_address),
        .CLK(CLK),
        .data(data),

        
    );

    main_memory memory (
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





