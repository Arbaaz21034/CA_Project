`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.10.2023 21:39:59
// Design Name: 
// Module Name: l1_dcache
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


module L1D_Cache(
        input wire [31:0] input_address,  //This is the input address given by the user
        input wire CLK,  // Clock
        input wire READY,  // Controlled by Main Memory
        output wire VALID, // Controlled by this L1 D Cache
        inout wire [31:0] DATA,  
        input wire LOAD,   // This is input from user to categorise LOAD and STORE
        inout wire STORE,
        inout wire [31:0] data,  // output for final data to user and input from user for store
        input wire [3:0] ACK_DATA_MEM,
        output wire [3:0] ACK_DATA_L1,
        inout wire ACK_ADDR
    );
    
    parameter OFFSET_BITS = 3;
    parameter INDEX_BITS = 4;
    parameter TAG_BITS = 32 - OFFSET_BITS - INDEX_BITS;
    parameter WAYS = 4;
    parameter WORDS_PER_LINE = 8;
    parameter SETS = 16;
    
    wire [TAG_BITS-1:0] tag = input_address[31:OFFSET_BITS+INDEX_BITS];
    wire [INDEX_BITS-1:0] index = input_address[OFFSET_BITS+INDEX_BITS-1:OFFSET_BITS];
    wire [OFFSET_BITS-1:0] offset = input_address[OFFSET_BITS-1:0];
    
    reg CACHE_HIT = 0;
    reg cache_full = 0;
    
    reg [31:0] cache_data[0:SETS-1][0:WAYS-1][0:WORDS_PER_LINE-1];
    reg [TAG_BITS-1:0] cache_tags[0:SETS-1][0:WAYS-1];
    reg valid_bits[0:SETS-1][0:WAYS-1]=0;
    
    reg [31:0] fetched_data_from_mem [0:WORDS_PER_LINE-1];
    reg [3:0] word_fetched = 0;
    
    reg [1:0] fifo_counter[0:SETS];
    reg [31:0] block_age[0:SETS][0:WAYS-1];
    
    
    reg address_sent = 1'b0;

    ACK_DATA_L1 = 4'b1111;

    always @(posedge CLK) begin 
        // LOAD operation received initially
        if (LOAD && !VALID) begin 
            CACHE_HIT = 1'b0; 
            for (int way = 0; way < WAYS; way++) begin
                if (cache_tags[index][way] == tag && valid_bits[index][way]) begin
                    data <= cache_data[index][way][offset];
                    CACHE_HIT <= 1'b1;
                    break;
                end
            end
            if (!CACHE_HIT) begin
                VALID <= 1'b1;
            end
        end
        // Load Operation: Connection Handshake done -> Here address is sent
        else if (LOAD && VALID && READY && !address_sent) begin
            DATA <= input_address
            ACK_ADDR = 1'b1;
            address_sent = 1'b1;
        end
        
        // Load Operation: Address has been received by the memory and word_to_be_fetched has been sent by mem
        else if (LOAD && VALID && READY && address_sent && !ACK_ADDR && ACK_DATA_MEM == word_to_be_fetched) begin
            fetched_data_from_mem[word_to_be_fetched] = DATA;
            
            ACK_DATA_L1 = word_to_be_fetched;
            
            // Load has been completed from L1 Cache side
            if (word_to_be_fetched == 4'b0111) begin
                ACK_DATA_L1 = 4'b1111;
                word_to_be_fetched = 0;
                replace_way <= 0;
                cache_full = 1'b1;
                for (int way = 0; i < WAYS; way++) begin
                    if (!valid_bits[index][way]) begin
                        replace_way <= way;
                        cache_full <= 1'b0;
                    end
                end
                if (cache_full) begin
                    for (int way = 0; way < WAYS; way++) begin
                        if (block_age[index][way] < block_age[index][replace_way]) begin
                            replace_way <= way;
                        end
                    end
                end
            
                cache_data[index][replace_way] <= fetched_data_from_mem;
                valid_bits[index][way] <= 1'b1;
                cache_tags[index][replace_way] <= tag;
                block_age[index][replace_way] <= fifo_counter[index];
                fifo_counter[index] <= fifo_counter[index] + 1'b1;
                
                data = fetched_data_from_mem[offset];
                VALID = 1'b0;
           end

           word_to_be_fetched = word_to_be_fetched + 1'b1;

           
        end
        
        
        // Store Operation Initially
        else if (STORE && !VALID) begin
            VALID <= 1'b1;
            for (int way = 0; way < WAYS; way++) begin
                if (cache_tags[index][way] == tag && valid_bits[index][way]) begin
                    cache_data[index][way] <= data;
                    
                end
            end
        end
        
        // Handshake done and now address is to be sent
        else if (STORE && VALID && READY && !address_sent) begin
            DATA = input_address;
            address_sent = 1'b1;
            ACK_ADDR = 1'b1;
        end
        
        // Address is sent and received by the memory
        else if (STORE && VALID && READY && address_sent && !ACK_ADDR) begin
            DATA = data;
            ACK_DATA_L1 = 4'b0000;
        end
        
        // Store Completed ACK_DATA is 1 meaning that the data has be received by memory
        else if (STORE && VALID && READY && ACK_DATA_MEM == 4'b0000) begin
            address_sent = 1'b0;
            ACK_DATA_L1 = 4'b1111;
            VALID = 0;
            STORE = 0;
           
        end
        
            
            
           
       
    end
            
        
                
        
    
    
endmodule
