`timescale 1ns / 1ps

module main_memory(
//        inout reg [31: 0] DATA,
inout wire [31:0] DATA,
        input wire CLK,
        input wire VALID,
        output wire READY,
        inout wire LOAD,
        input wire STORE,
        inout wire [3:0] ACK_DATA_L1,
        inout wire ACK_ADDR 
    );
    
    parameter MEM_SIZE = 2048; // 2048 words
    
    reg [31: 0] mem_storage[0: MEM_SIZE-1];
    //read mem hexadecimal: TODO 
    reg [2:0] word_sent = 3'b000;
    reg [3:0] ack_data_internal;
    reg address_received = 1'b0;
    reg ready_internal;
    reg [31:0] address = 1'b0;
    reg [31:0] start_address;
    reg [31:0] data_internal;
    reg load_internal;
    ACK_DATA_MEM = 4'b1111;
initial begin
    ack_data_internal <= 4'b1000;
    end

    always @(posedge CLK) begin

        if (LOAD && VALID && !READY) begin
            ready_internal <= 1'b1;
        end

        else if (LOAD && VALID && READY && !address_received && ACK_ADDR) begin
            address <= DATA;
            ack_data_internal <= 1'b0;
            address_received <= 1'b1;
            start_address <= floor(address / 8) * 8;
            data_internal <= mem_storage[start_address + word_sent*(32'b0100)];
            ack_data_internal <= 4'b0000;
            
        end

        else if (LOAD && VALID && READY && address_received && ACK_DATA == word_sent) begin
            start_address <= floor(address / 8) * 8;
            word_sent <= word_sent + 1'b1;
            data_internal <= mem_storage[start_address + word_sent*(32'b0100)];
            ack_data_internal <= word_sent;

        end

        // Load has been completed
        else if (LOAD && VALID && READY && ACK_DATA == 4'b0101) begin
            word_sent = 4'b0000;
            ready_internal <= 0;
            ack_data_internal <= 4'b1000;
            address_received <= 1'b0;
            load_internal = 1'b0;
        
        end     


        else if (STORE && VALID && !READY) begin
            ready_internal <= 1'b1;
            
        end

        else if (STORE && VALID && READY && !address_received && ACK_ADDR) begin
            address = DATA;
            address_received = 1'b1;
            ack_data_internal = 1'b0;
        end

        else if (STORE && VALID && READY && address_received && ACK_DATA == 4'b0000) begin
            data = DATA;
            mem_storage[address_received] <= data;
            address_received = 1'b0;
            ack_data_internal <= 4'b0001;
            ready_internal <= 0;
        end
            

    end
    assign ACK_DATA = ack_data_internal;
    assign READY = ready_internal;
    assign DATA= data_internal;
    assign LOAD= load_internal;
    
endmodule