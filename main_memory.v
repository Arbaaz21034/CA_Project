`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.10.2023 21:38:57
// Design Name: 
// Module Name: main_memory
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Main_Memory(
        inout reg [31: 0] DATA,
        input wire CLK,
        input wire VALID,
        output wire READY,
        inout wire LOAD,
        input wire STORE,
        inout wire [3:0] ACK_DATA_L1,
        inout wire [3:0] ACK_DATA_MEM,
        inout wire ACK_ADDR,
       

    );
    
    parameter MEM_SIZE = 2048; // 2048 words
    
    reg [31: 0] mem_storage[0: MEM_SIZE-1];
    //read mem hexadecimal: TODO 
    reg [2:0] word_sent = 3'b000;
    
    reg address_received = 1'b0;
    ACK_DATA_MEM = 4'b1111;

    reg [31:0] address = 1'b0;

    reg [31:0] buffer; 
    
    
    always @(posedge CLK) begin

        if (LOAD && VALID && !READY) begin
            READY <= 1'b1;
        end

        else if (LOAD && VALID && READY && !address_received && ACK_ADDR) begin
            address = DATA;
            ACK_ADDR = 1'b0;
            address_received = 1'b1;
            reg [31:0] start_address = address & 32'hFFFFFFF8;
            DATA = mem_storage[start_address + word_sent*(32'b0100)];
            ACK_DATA_MEM = 4'b0000;
            
            
        end

        else if (LOAD && VALID && READY && address_received && ACK_DATA_L1 == word_sent && ACK_DATA_L1 != 4'b0111) begin
            reg [31:0] start_address = address & 32'hFFFFFFF8;
            word_sent = word_sent + 1'b1;
            DATA = mem_storage[start_address + word_sent*(32'b0100)];
            ACK_DATA_MEM = word_sent;

        end

        // Load has been completed
        else if (LOAD && VALID && READY && ACK_DATA_L1 == 4'b0111) begin
            word_sent = 4'b0000;
            READY = 0;
            ACK_DATA_MEM = 4'b1111;
            ACK_DATA_L1 = 4'b1111;
            address_received = 1'b0;
            LOAD = 1'b0;
        
        end     


        else if (STORE && VALID && !READY) begin
            READY <= 1'b1;
            
        end

        else if (STORE && VALID && READY && !address_received && ACK_ADDR) begin
            address = DATA;
            address_received = 1'b1;
            ACK_ADDR = 1'b0;
            ACK_DATA_MEM = 4'b0000;
        end

        else if (STORE && VALID && READY && address_received && ACK_DATA_L1 == 4'b0000) begin
            buffer  = DATA;
            mem_storage[address] = buffer;
            address_received = 1'b0;
            ACK_DATA_MEM = 4'b0000;
            READY = 0;
        end


        
    end
endmodule
