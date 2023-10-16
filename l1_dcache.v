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


module l1_dcache(
        input wire [31:0] input_address,  //This is the input address given by the user
        input wire CLK,  // Clock
        input wire READY,  // Controlled by Main Memory
        output wire VALID, // Controlled by this L1 D Cache
        inout wire [31:0] DATA,  // For store address and data is sent using this by L1DCache, For load data is received from Main memory using this in case of miss.
        input wire LOAD_STORE,   // This is input from user to categorise LOAD and STORE
        input wire last_bit,
        inout wire [31:0] data,  // This is output for final data to user and input from user for store
        output wire sent_bit,  
        inout wire ACK
    );
    
    parameter OFFSET_BITS = 5;
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
    integer word_fetched = 0;
    
    reg [1:0] fifo_counter[0:SETS];
    reg [1:0] block_age[0:SETS][0:WAYS-1];
    
    reg address_sent = 1'b0;
    
    always @(posedge CLK) begin 
        if (!LOAD_STORE && !VALID) begin 
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
        
        else if (!LOAD_STORE && VALID && READY && !address_sent) begin
            DATA <= input_address;
            address_sent <= 1'b1;
        end
        
        else if (!LOAD_STORE && VALID && READY && address_sent) begin
            fetched_data_from_mem[word_fetched] <= DATA;
            word_fetched <= word_fetched + 1;
            
            if (word_fetched == 7) begin
                word_fetched = 0;
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
                
                data <= fetched_data_from_mem[offset];
                VALID <= 1'b0;
           end
        end
        
        
        
        else if (LOAD_STORE && !VALID) begin
            VALID <= 1'b1;
            for (int way = 0; way < WAYS; way++) begin
                if (cache_tags[index][way] == tag && valid_bits[index][way]) begin
                    cache_data[index][way] <= data;
                    
                end
            end
        end
        
        else if (LOAD_STORE && VALID && READY && !address_sent) begin
            DATA <= input_address;
            address_sent <= 1'b1;
            sent_bit<=0;
        end
        
        else if (LOAD_STORE && VALID && READY && address_sent) begin
            if(sent_bit==0) begin
                DATA <= data;
                sent_bit<=1;
            end
            else
            begin
                VALID<=0;
            end
        end
        
            
            
           
       
    end
            
        
                
        
    
    
endmodule
