
`timescale 1ns / 1ps
module Mem_Subsystem (
    input wire [31:0] input_address,
    input wire LOAD,
    input wire STORE,
    inout wire [31:0] data,
    input wire [31:0] input_data,
    input wire CLK, 
    inout wire store_completed
    
   
);

    wire READY;
    wire VALID;
    wire [31:0] DATA_L1;
    wire [31:0] DATA_MEM;
    
    wire ACK_ADDR_L1;
    wire ACK_ADDR_MEM;
    
    wire [3:0] ACK_DATA_L1;
    wire [3:0] ACK_DATA_MEM;

    wire RESET_ACK_L1;
    wire RESET_ACK_MEM;

    wire ACK_COUNT_L1;
    wire ACK_COUNT_MEM;

  

    


    L1D_Cache cache (
        .input_address(input_address),
        .input_data(input_data),
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
        .RESET_ACK_L1(RESET_ACK_L1),
        .RESET_ACK_MEM(RESET_ACK_MEM),
        .store_completed(store_completed),
        .ACK_COUNT_L1(ACK_COUNT_L1),
        .ACK_COUNT_MEM(ACK_COUNT_MEM)

        
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
        .RESET_ACK_L1(RESET_ACK_L1),
        .RESET_ACK_MEM(RESET_ACK_MEM).
        .ACK_COUNT_L1(ACK_COUNT_L1),
        .ACK_COUNT_MEM(ACK_COUNT_MEM)
        
       


    );
endmodule
    







