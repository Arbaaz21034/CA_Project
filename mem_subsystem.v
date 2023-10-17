module Memory_Subsystem (
    input wire [31:0] input_address,
    input wire CLK,
    inout wire LOAD,
    inout wire STORE,
    inout wire [31:0] data
);

    wire READY;
    wire VALID;
    wire ACK_ADDR;
    wire [3:0] ACK_DATA_L1;
    wire [3:0] ACK_DATA_MEM;

    l1_dcache cache (
        .input_address(input_address),
        .CLK(CLK),
        .READY(READY),
        .VALID(VALID),
        .DATA(data),
        .LOAD(LOAD),
        .STORE(STORE),
        .ACK_ADDR(ACK_ADDR),
        .ACK_DATA(ACK_DATA_L1)
    );

    main_memory memory (
        .DATA(data),
        .CLK(CLK),
        .VALID(VALID),
        .READY(READY),
        .LOAD(LOAD),
        .STORE(STORE),
        .ACK_DATA(ACK_DATA_MEM),
        .ACK_ADDR(ACK_ADDR)
    );

endmodule


//module Memory_Subsystem (
//    input wire [31:0] input_address,
//    input wire LOAD,
//    input wire STORE,
//    inout [31:0] data,
//    input wire CLK
//);

//    wire READY;
//    wire VALID;
//    wire [31:0] DATA;
//    wire ACK_ADDR;
//    wire [3:0] ACK_DATA_L1;
//    wire [3:0] ACK_DATA_MEM;

//    wire LOAD;
//    wire STORE;

    


//    L1D_Cache cache (
//        .input_address(input_address),
//        .CLK(CLK),
//        .READY(READY),
//        .VALID(VALID),
//        .DATA(DATA),
//        .LOAD(LOAD),
//        .STORE(STORE),
//        .data(data),
//        .ACK_ADDR(ACK_ADDR),
//        .ACK_DATA_L1(ACK_ADDR_L1),
//        .ACK_DATA_MEM(ACK_DATA_MEM)

        
//    );

//    Main_Memory memory (
        
//        .CLK(CLK),
//        .READY(READY),
//        .VALID(VALID),
//        .DATA(DATA),
//        .LOAD(LOAD),
//        .STORE(STORE),
//        .data(data),
//        .ACK_ADDR(ACK_ADDR),
//        .ACK_DATA_L1(ACK_ADDR_L1),
//        .ACK_DATA_MEM(ACK_DATA_MEM)


//    );
//endmodule
    







////module MemorySubsystem (
////    input wire [31:0] input_address,
////    input wire LOAD,
////    input wire STORE,
////    inout [31:0] data,
////    input wire CLK
////);

////    l1_dcache cache (
////        .input_address(input_address),
////        .CLK(CLK),
////        .data(data),

        
////    );

////    main_memory memory (
////        .CLK(CLK),
////    )

////    assign cache.LOAD = LOAD && memory.LOAD;

////    assign memory.STORE = STORE && cache.STORE;

////    assign cache.READY = memory.READY;

////    assign memory.VALID = cache.VALID;

////    assign cache.DATA = memory.DATA;
    
////    assign memory.DATA = cache.DATA;

////    assign cache.ACK_ADDR = memory.ACK_ADDR;
    
////    assign memory.ACK_DATA = cache.ACK_DATA;




