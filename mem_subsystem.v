

module Mem_Subsystem (
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
    wire [3:0] ACK_DATA_L1;
    wire [3:0] ACK_DATA_MEM;

  

    


    L1D_Cache cache (
        .input_address(input_address),
        .CLK(CLK),
        .READY(READY),
        .VALID(VALID),
        .DATA(DATA),
        .LOAD(LOAD),
        .STORE(STORE),
        .data(data),
        .ACK_ADDR(ACK_ADDR),
        .ACK_DATA_L1(ACK_DATA_L1),
        .ACK_DATA_MEM(ACK_DATA_MEM)

        
    );

    Main_Memory memory (
        
        .CLK(CLK),
        .READY(READY),
        .VALID(VALID),
        .DATA(DATA),
        .LOAD(LOAD),
        .STORE(STORE),
        .ACK_ADDR(ACK_ADDR),
        .ACK_DATA_L1(ACK_DATA_L1),
        .ACK_DATA_MEM(ACK_DATA_MEM)


    );
endmodule
    







