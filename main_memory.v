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
        input wire RESET_ACK_L1,
        input wire ACK_COUNT_L1,
        output reg ACK_COUNT_MEM
        
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


    reg [3:0] word_sent = 0;
    reg address_received = 1'b0;
    
    reg [31:0] address = 32'b0;
 
    reg [31:0] buffer;
    integer i;
    integer flag;
    reg [31:0] maxError = 32'b0010000;
    
    reg [31:0] word;
    reg [31:0] base_word;

    reg [31:0] abs_diff;

    reg [31:0] base_count;
    
    
    reg isWordSent = 1'b0;

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
            base_word = mem_storage[start_address + word_sent];
            abs_diff = 32'b0;
            base_count = 32'b0;
            flag=0;
            for (i = 0; i < 8; i = i + 1) begin
                
                word =  mem_storage[start_address + i];
                abs_diff = (word > base_word) ? (word - base_word) : (base_word - word);
                if (abs_diff <= maxError && !flag) begin
                    base_count = base_count + 1;
                end
                else begin
                    flag=1;
                end
                
            end
            
            $display("Base word is: %h, and Base count is %h", base_word, base_count);

            
            DATA_MEM = base_word;
            ACK_DATA_MEM = 4'b0000;
            ACK_COUNT_MEM = 1'b0;
           
            
        end
        else if (LOAD && VALID && READY && address_received && ACK_COUNT_L1 == 0 && ACK_DATA_L1 == word_sent) begin
            
            ACK_ADDR_MEM = 1'b0;
            DATA_MEM = base_count;

            ACK_COUNT_MEM = 1'b1;
            word_sent = word_sent + base_count - 4'b0001;
            $display("The word sent is %h", word_sent);
            isWordSent = 1'b0;

        end


        else if (LOAD && VALID && READY && !isWordSent && address_received && ACK_COUNT_L1 && ACK_DATA_L1 == word_sent && ACK_DATA_L1 != 4'b0111) begin
            ACK_ADDR_MEM = 1'b0;
            start_address = ((address/8) * 8);
            base_word = mem_storage[start_address + word_sent + 4'b01];
            abs_diff = 32'b0;
            flag=0;
            base_count = 4'b0000;
            for (i = 0; i < 8; i = i + 1) begin
                
                word = mem_storage[start_address + i];
//                $display("base word is %h at %h and word is %h %h", base_word, i, word, abs_diff);
                abs_diff = (word > base_word) ? (word - base_word) : (base_word - word);
//                $display("base word is %h at %h and word is %h %h", base_word, i, word, abs_diff);
                if (abs_diff <= maxError && i > word_sent && !flag) begin
//                    $display("The word is %h and the absolute difference is %h", word, abs_diff);
                    base_count = base_count + 1;
                end
                else if (i> word_sent) begin
                    flag=1;
                end
                
                
            end
            
            
            DATA_MEM = base_word;
            word_sent = word_sent + 4'b0001;
            ACK_DATA_MEM = word_sent;
            ACK_COUNT_MEM = 1'b0;
            isWordSent = 1'b1;
            $display("2nd Base word is: %h, and Base count is %h %h the word sent is %h", base_word, base_count, ACK_DATA_MEM, word_sent);
        end

        else if (LOAD && VALID && READY && address_received && !ACK_COUNT_L1 && ACK_DATA_L1 == word_sent) begin
            $display("HLEOO");
            DATA_MEM = base_count;
            ACK_COUNT_MEM = 1'b1;
            word_sent = word_sent + base_count - 32'b01;
            isWordSent = 1'b0;
        end

        // Load has been completed
        else if (READY && ACK_DATA_L1 == 4'b0111 && ACK_COUNT_L1) begin
            $display("KK");
            address_received = 1'b0;
            word_sent = 4'b0000;
            READY = 1'b0;
            ACK_DATA_MEM = 4'b1111;
            RESET_ACK_MEM = 1'b1;
            address_received = 1'b0;
            ACK_COUNT_MEM = 1'b0;
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