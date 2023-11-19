`timescale 1ns / 1ps



module Mem_Subsystem_tb(
    
);

    // Parameters
    reg [31:0] tb_input_address;
    reg tb_LOAD;
    reg tb_STORE;
    reg tb_CLK;
    wire [31:0] tb_data;
    reg [31:0] tb_input_data;


    wire store_completed;

    // Instantiate the Mem_Subsystem
    Mem_Subsystem uut (
        .input_address(tb_input_address),
        .LOAD(tb_LOAD),
        .STORE(tb_STORE),
        .data(tb_data),
        .input_data(tb_input_data),
        .CLK(tb_CLK),
        .store_completed(store_completed)
       
    );

    initial begin
        // Testbench Initialization
        tb_LOAD = 0;
        tb_STORE = 0;
        tb_CLK = 0;

        // Wait for few clock cycles
        #10;

        // Test Load Operation
//        tb_input_address = 32'h00000019;  // Sample address
//        tb_LOAD = 1;
//        #250; 
        
//        // Observe the data output
//        $display("Data for address %h: %h", tb_input_address, tb_data);
        
//        tb_LOAD = 0;
//        // Wait for few clock cycles
//        #10;

//        // Test Load Operation
//        tb_input_address = 32'h00000004;  // Sample address
//        tb_LOAD = 1;
//        #250; // Simulate 10 clock cycles
        
        
//        // Observe the data output
//        $display("Data for address %h: %h", tb_input_address, tb_data);
        
//        tb_LOAD = 0;
//        // Wait for few clock cycles
//        #10;

//        // Test Load Operation
//        tb_input_address = 32'h00000019;  // Sample address
//        tb_LOAD = 1;
//        #250; // Simulate 10 clock cycles
        
//        // Observe the data output
//        $display("Data for address %h: %h", tb_input_address, tb_data);


//        tb_STORE = 0;
//        // Wait for few clock cycles
//        #10;

//        // Test STORE Operation
//        tb_input_address = 32'h00000019;  // Sample address
//        tb_input_data = 32'h00000019;
//        tb_STORE = 1;
//        #250; // Simulate 10 clock cycles
        
        
        
//        tb_LOAD = 0;
//        // Wait for few clock cycles
//        #10;

//        // Test Load Operation
//        tb_input_address = 32'h00000019;  // Sample address
//        tb_LOAD = 1;
//        #250; // Simulate 10 clock cycles
        
//        // Observe the data output
//        $display("Data for address %h: %h", tb_input_address, tb_data);
        

//        tb_STORE = 0;
//        // Wait for few clock cycles
//        #10;

//        // Test STORE Operation
//        tb_input_address = 32'h00000020;  // Sample address
//        tb_input_data = 32'h00000020;
//        tb_STORE = 1;
//        #250; // Simulate 10 clock cycles
        
        
        tb_LOAD = 0;
        // Wait for few clock cycles
        #10;

        // Test Load Operation
        tb_input_address = 32'h00000008;  // Sample address
        tb_LOAD = 1;
        #500; // Simulate 10 clock cycles
        
        // Observe the data output
        $display("Data for address %h: %h", tb_input_address, tb_data);
        
        
        
        
        $stop; // Stop the simulation
    end

    // Clock Generation
    always begin
        #5 tb_CLK = ~tb_CLK;
        
    end
    
    always @(tb_data) begin
        tb_LOAD = 0;
    end

    always @(store_completed) begin
        tb_STORE = 0;
    end

endmodule
