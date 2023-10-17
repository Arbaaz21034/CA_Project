`timescale 1ns / 1ps

module L1D_Cache(
        input wire [31:0] input_address,  //This is the input address given by the user
        input wire CLK,  // Clock
        input wire READY,  // Controlled by Main Memory
        output wire VALID, // Controlled by this L1 D Cache
        inout wire [31:0] DATA,  // For store address and data is sent using this by L1DCache, For load data is received from Main memory using this in case of miss.
        input wire LOAD,   // This is input from user to categorise LOAD and STORE
        inout wire STORE,
        inout wire [31:0] data,  // output for final data to user and input from user for store
        inout wire [3:0] ACK_DATA_L1,
        inout wire [3:0] ACK_DATA_MEM,
        
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
    reg [7:0] valid_bits [0:SETS-1][0:WAYS-1];
    
    initial begin
        $readmemh("cache_data.mem", cache_data);
        $readmemh("cache_tags.mem", cache_tags);
        $readmemh("valid_bits.mem", valid_bits);
    end

   
    reg [31:0] fetched_data_from_mem [0:WORDS_PER_LINE-1];
    reg [3:0] word_fetched = 0;
    
    reg [1:0] fifo_counter[0:SETS];
    reg [1:0] block_age[0:SETS][0:WAYS-1];
   
    
    reg address_sent = 1'b0;
    reg valid_internal = 1'b0;
    reg ack_addr_internal = 1'b0;
    reg store_internal = 1'b0;
    reg [3:0] ack_data_l1_internal = 4'b1111;
    reg [3:0] ack_data_mem_internal = 4'b1111;
    reg [1:0] replace_way;
    reg [31:0] DATA_internal;
    reg [31:0] data_internal;
    initial begin
        $display("I am inside l1d");
    end
    integer i;
    integer way;

    always @(posedge CLK) begin 
        // LOAD operation received initially
        $display("I am ins %h",LOAD);
        if (LOAD && !VALID) begin 
            CACHE_HIT <= 1'b0; 
            $display("I am inside always");

            for (way = 0; way < WAYS; way=way+1) begin
                if (cache_tags[index][way] == tag && valid_bits[index][way]) begin
                    $display("I am not checking you");
                    data_internal <= cache_data[index][way][offset];
                    CACHE_HIT <= 1'b1;
                    if (CACHE_HIT) begin end
                end
            end
            if (!CACHE_HIT) begin
                valid_internal <= 1'b1;
            end
        end
        // Load Operation: Connection Handshake done -> Here address is sent
        else if (LOAD && VALID && READY && !address_sent) begin
            DATA_internal <= input_address;
            ack_addr_internal <= 1'b1;
            address_sent = 1'b1;
        end
        
        // Load Operation: Address has been received by the memory and word_to_be_fetched has been sent by mem
        else if (LOAD && VALID && READY && address_sent && !ACK_ADDR && ACK_DATA_MEM == word_fetched) begin
            fetched_data_from_mem[word_fetched] = DATA;
            ack_data_l1_internal <= word_fetched;
            
            // Load has been completed from L1 Cache side
            if (word_fetched == 4'b0111) begin
                word_fetched <= 0;
                replace_way <= 0;
                cache_full = 1'b1;
                for (way = 0; way < WAYS; way=way+1) begin
                    if (!valid_bits[index][way]) begin
                        replace_way <= way;
                        cache_full <= 1'b0;
                    end
                end
                if (cache_full) begin
                    for (way = 0; way < WAYS; way=way+1) begin
                        if (block_age[index][way] < block_age[index][replace_way]) begin
                            replace_way <= way;
                        end
                    end
                end
            
                for (i = 0; i < word_fetched; i = i + 1) begin
                    cache_data[index][replace_way][i] = fetched_data_from_mem[i];
                end
                valid_bits[index][replace_way] <= 1'b1;
                cache_tags[index][replace_way] <= tag;
                block_age[index][replace_way] <= fifo_counter[index];
                fifo_counter[index] <= fifo_counter[index] + 1'b1;
                
                data_internal <= fetched_data_from_mem[offset];
                valid_internal <= 1'b0;
           end

           word_fetched <= word_fetched + 1'b1;
        end
        
        
        
        
    end

    assign DATA =data_internal;  
    assign VALID = valid_internal;
    assign ACK_ADDR= ack_addr_internal;
    assign STORE=store_internal;
    assign ACK_DATA_L1=ack_data_l1_internal;
    assign ACK_DATA_MEM=ack_data_mem_internal;
    assign DATA=DATA_internal;
    assign data=data_internal;
    
    
endmodule