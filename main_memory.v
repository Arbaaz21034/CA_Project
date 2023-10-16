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


module main_memory(
        inout reg [31: 0] DATA,
        input wire CLK,
        input wire VALID,
        output wire READY,
        input wire LOAD,
        input wire STORE,
        inout wire ACK 
    );
    
    parameter MEM_SIZE = 2048; // 2048 words
    
    reg [31: 0] mem_storage[0: MEM_SIZE-1];
    
    integer word_sent = 0;
    
    
    reg address_received=0;
    reg [31:0] address;
    
    always @(posedge CLK) begin
        if (LOAD && VALID && !READY) begin
            READY <= 1'b1;
        end
        else if (LOAD && VALID && READY && word_sent<7) begin
            address <= DATA;
            reg [31:0] start_address = floor(address / 8) * 8;
            DATA <= mem_storage[start_address + word_sent*(32'b0100)];
            word_sent++;
            
        end
        else if (LOAD && VALID && READY && word_sent==8) begin
            word_sent <= 0;
            READY<=0;
        
        end     
        if (STORE && VALID && !READY) begin
            READY <= 1'b1;
            address_received<=0;
        end
        else if (STORE && VALID && READY && !address_received) begin
            address <= DATA;
            address_received<=1;
        end
        else if (STORE && VALID && READY && address_received) begin
            data <= DATA;
            mem_storage[address_received]<=data;
            READY<=0;
        end
        
    end
endmodule
