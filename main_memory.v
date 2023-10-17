`timescale 1ns / 1ps
module Main_Memory(
        inout wire [31: 0] DATA,
        input wire CLK,
        input wire VALID,
        output wire READY,
        inout wire LOAD,
        input wire STORE,
        inout wire [3:0] ACK_DATA_L1,
        inout wire [3:0] ACK_DATA_MEM,
        inout wire ACK_ADDR
      
    );
    reg [3:0] ack_data_mem_internal = 4'b1111;
    reg [3:0] ack_data_l1_internal = 4'b1111;
    reg ready_internal = 1'b0;
    reg [3:0] ack_addr_internal = 1'b0;
    reg [31:0] start_address;
    reg [31:0] DATA_internal;
    reg LOAD_internal = 1'b0;
    
    parameter MEM_SIZE = 2048; // 2048 words
    
    reg [31: 0] mem_storage[0: MEM_SIZE-1];
    initial begin
        $readmemh("memory_data.mem", mem_storage);
    end
    reg [2:0] word_sent = 3'b000;
    reg address_received = 1'b0;
    ///////////////////////////////
    initial begin
        ack_data_mem_internal <= 4'b1111;
    end
//////////////////////////////////
    reg [31:0] address = 1'b0;
    reg [31:0] buffer; 
    
    
    always @(posedge CLK) begin

        if (LOAD && VALID && !READY) begin
            ready_internal <= 1'b1;
        end

        else if (LOAD && VALID && READY && !address_received && ACK_ADDR) begin
            address = DATA;
            ack_addr_internal <= 1'b0;
            address_received <= 1'b1;
            start_address <= address & 32'hFFFFFFF8;
            DATA_internal <= mem_storage[start_address + word_sent*(32'b0100)];
            ack_data_mem_internal = 4'b0000;
            
            
        end

        else if (LOAD && VALID && READY && address_received && ACK_DATA_L1 == word_sent && ACK_DATA_L1 != 4'b0111) begin
            start_address <= address & 32'hFFFFFFF8;
            word_sent = word_sent + 1'b1;
            DATA_internal = mem_storage[start_address + word_sent*(32'b0100)];
            ack_data_mem_internal <= word_sent;

        end

        // Load has been completed
        else if (LOAD && VALID && READY && ACK_DATA_L1 == 4'b0111) begin
            word_sent = 4'b0000;
            ready_internal = 0;
            ack_data_mem_internal = 4'b1111;
            ack_data_l1_internal = 4'b1111;
            address_received = 1'b0;
//            LOAD_internal <= 1'b0;
        
        end     


        
    end
    
    assign ACK_DATA_MEM = ack_data_mem_internal;
    assign ACK_DATA_L1 = ack_data_l1_internal;
    assign ACK_ADDR= ack_addr_internal;
    assign READY = ready_internal;
    assign DATA= DATA_internal;
    assign LOAD= LOAD_internal;
endmodule