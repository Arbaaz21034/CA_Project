

module Mem_Subsystem (
    input wire [31:0] input_address,
    input wire LOAD,
    input wire STORE,
    inout [31:0] data,
    input wire CLK
    
   
);

    wire READY;
    wire VALID;
    wire [31:0] DATA_L1;
    wire [31:0] DATA_MEM;
    
    wire ACK_ADDR_L1;
    wire ACK_ADDR_MEM;
    
    wire [3:0] ACK_DATA_L1;
    wire [3:0] ACK_DATA_MEM;

    wire RESET_ACK;

  

    


    L1D_Cache cache (
        .input_address(input_address),
        .CLK(CLK),
        .READY(READY),
        .VALID(VALID),
        .DATA_L1(DATA_L1),
        .DATA_MEM(DATA_MEM),
        .LOAD(LOAD),
        .STORE(STORE),
        .data(data),
        .ACK_ADDR_L1(ACK_ADDR_L1),
        .ACK_ADDR_MEM(ACK_ADDR_MEM),
        .ACK_DATA_L1(ACK_DATA_L1),
        .ACK_DATA_MEM(ACK_DATA_MEM),
        .RESET_ACK(RESET_ACK)

        
    );

    Main_Memory memory (
        
        .CLK(CLK),
        .READY(READY),
        .VALID(VALID),
        .DATA_L1(DATA_L1),
        .DATA_MEM(DATA_MEM),
        .LOAD(LOAD),
        .STORE(STORE),
        .ACK_ADDR_L1(ACK_ADDR_L1),
        .ACK_ADDR_MEM(ACK_ADDR_MEM),
        .ACK_DATA_L1(ACK_DATA_L1),
        .ACK_DATA_MEM(ACK_DATA_MEM),
        .RESET_ACK(RESET_ACK)
       


    );
endmodule
    







