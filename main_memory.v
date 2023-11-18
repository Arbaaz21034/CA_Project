`timescale 1ns / 1ps
module Main_Memory(
        input wire [31:0] DATA_L1,
        output reg [31:0] DATA_MEM,
        input wire CLK,
        input wire VALID,
        output reg READY,
        input wire LOAD,
        input wire STORE,
        input wire [3:0] ACK_DATA_L1,
        output reg [3:0] ACK_DATA_MEM,
        input wire ACK_ADDR_L1,
        output reg ACK_ADDR_MEM,

        output reg RESET_ACK_MEM,
        input wire RESET_ACK_L1
        
    );
    
    initial begin
        ACK_DATA_MEM = 4'b1111;
        ACK_ADDR_MEM = 1'b0;
        READY = 1'b0;
    end
    
    
    
    
    reg [31:0] start_address;
    
    
    
    parameter MEM_SIZE = 2048; // 2048 words
    
    reg [31: 0] mem_storage[0: MEM_SIZE-1];
    initial begin
        $readmemh("memory_data.mem", mem_storage);
    end


    reg [2:0] word_sent = 3'b000;
    reg address_received = 1'b0;
    
    reg [31:0] address = 32'b0;
 
    reg [31:0] buffer;
    
    always @(posedge CLK) begin

        if (LOAD && VALID && !READY) begin
            RESET_ACK_MEM = 1'b0;
            READY = 1'b1;
        end

        else if (LOAD && VALID && READY && !address_received && ACK_ADDR_L1) begin
            address = DATA_L1;
            ACK_ADDR_MEM = 1'b1;
            address_received = 1'b1;
            start_address = ((address/8) * 8);
            DATA_MEM = mem_storage[start_address + word_sent];
            ACK_DATA_MEM = 4'b0000;
            
        end

        else if (LOAD && VALID && READY && address_received && ACK_DATA_L1 == word_sent && ACK_DATA_L1 != 4'b0111) begin
            ACK_ADDR_MEM = 1'b0;
            start_address = ((address/8) * 8);
            word_sent = word_sent + 1'b1;
            DATA_MEM = mem_storage[start_address + word_sent];
            ACK_DATA_MEM = word_sent;
        end

        // Load has been completed
        else if (READY && ACK_DATA_L1 == 4'b0111) begin
            address_received = 1'b0;
            word_sent = 4'b0000;
            READY = 1'b0;
            ACK_DATA_MEM = 4'b1111;
            RESET_ACK_MEM = 1'b1;
            address_received = 1'b0;
            
        end  

        else if (STORE && VALID && !READY && ACK_DATA_MEM == 4'b1111) begin
            $display("lfhg1 %h", 1);
            READY = 1'b1;

        end   

        else if (STORE && VALID && READY && !address_received && ACK_ADDR_L1) begin
            $display("mem %h", address);
            address = DATA_L1;
            ACK_ADDR_MEM = 1'b1;
            address_received = 1'b1;
            
        end

        else if (STORE && VALID && READY && address_received && ACK_DATA_L1 == 4'b0000) begin
            buffer  = DATA_L1;
            $display("l1 %h", address);
            mem_storage[address] = buffer;
            address_received = 1'b0;
            ACK_DATA_MEM = 4'b0000;
            address_received = 1'b0;
            READY = 0;
        end

        else if (RESET_ACK_L1) begin 
            ACK_DATA_MEM = 4'b1111;
        end
        
    end
    
    
    

endmodule