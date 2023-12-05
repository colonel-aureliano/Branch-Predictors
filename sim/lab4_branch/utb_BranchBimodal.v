//========================================================================
// utb_CacheBase
//========================================================================
// A basic Verilog unit test bench for the Cache Base Design module

`default_nettype none
`timescale 1ps/1ps


`include "BranchBimodal.v"
`include "trace.v"
`include "regfiles.v"
//------------------------------------------------------------------------
// Top-level module
//------------------------------------------------------------------------

module top(  input logic clk, input logic linetrace );

    logic         reset;
    logic         update_en;
    logic         update_val;
    logic  [31:0] PC;
    logic         prediction;
    //----------------------------------------------------------------------
    // Module instantiations
    //----------------------------------------------------------------------
    
    // Instantiate the processor datapath
    lab4_branch_BranchBimodal #(1024) DUT
    ( 
        .*
    ); 

    //----------------------------------------------------------------------
    // Run the Test Bench
    //----------------------------------------------------------------------

    initial begin

        $display("Start of Testbench");
        // Initalize all the signal inital values.
        reset = 1; 
        update_en = 0; 
        update_val = 0; 
        PC = 0; 
        @(negedge clk); 
        
        reset = 0; 
        @(negedge clk); 
        
        //----------------------------------------------------------------------
        // Predict 0 on first round
        //----------------------------------------------------------------------

        PC = {20'b0, 10'd131, 2'd0}; 

        #0.02; 
        assertion( "initial should predict 0", 1'b0, prediction); 
        @(negedge clk); 

        //----------------------------------------------------------------------
        // Update branch taken 
        //----------------------------------------------------------------------
        
        PC = {20'b0, 10'd131, 2'd0}; 
        update_val = 1; 
        update_en = 1; 
        
        @(negedge clk); 
        update_en = 0;

        assertion2( "pht after update ", 2'b01, DUT.dpath.pht.rfile[131]); 
        assertion("prediction after update", 1'b0, prediction);

        
        @(negedge clk); 

        //----------------------------------------------------------------------
        // Update branch taken from 01 to 10
        //----------------------------------------------------------------------

        PC = {20'b0, 10'd131, 2'd0}; 
        update_val = 1; 
        update_en = 1; 

        @(negedge clk); 
        update_en = 0;   
        assertion2( "pht after update ", 2'b10, DUT.dpath.pht.rfile[131]); 
        assertion("prediction after update", 1'b1, prediction);
      
        //----------------------------------------------------------------------
        // Update branch taken from 10 to 11
        //----------------------------------------------------------------------

        PC = {20'b0, 10'd131, 2'd0}; 
        update_val = 1; 
        update_en = 1; 

        @(negedge clk); 
        update_en = 0;   
        assertion2( "pht after update ", 2'b11, DUT.dpath.pht.rfile[131]); 
        assertion("prediction after update", 1'b1, prediction);

        //----------------------------------------------------------------------
        // Update branch taken from 11 stay at 11
        //----------------------------------------------------------------------

        PC = {20'b0, 10'd131, 2'd0}; 
        update_val = 1; 
        update_en = 1; 

        @(negedge clk); 
        update_en = 0;   
        assertion2( "pht after update ", 2'b11, DUT.dpath.pht.rfile[131]); 
        assertion("prediction after update", 1'b1, prediction);

        //----------------------------------------------------------------------
        // Update branch not taken from 11 to  10
        //----------------------------------------------------------------------
        
        PC = {20'b0, 10'd131, 2'd0}; 
        update_val = 0; 
        update_en = 1; 
        
        @(negedge clk); 
        update_en = 0;

        assertion2( "pht after update ", 2'b10, DUT.dpath.pht.rfile[131]); 
        assertion("prediction after update", 1'b1, prediction);

        
        @(negedge clk); 

        //----------------------------------------------------------------------
        // Update branch taken from 10 to 01
        //----------------------------------------------------------------------

        PC = {20'b0, 10'd131, 2'd0}; 
        update_val = 0; 
        update_en = 1; 

        @(negedge clk); 
        update_en = 0;   
        assertion2( "pht after update ", 2'b01, DUT.dpath.pht.rfile[131]); 
        assertion("prediction after update", 1'b0, prediction);
      
        //----------------------------------------------------------------------
        // Update branch taken from 01 to 00
        //----------------------------------------------------------------------

        PC = {20'b0, 10'd131, 2'd0}; 
        update_val = 0; 
        update_en = 1; 

        @(negedge clk); 
        update_en = 0;   
        assertion2( "pht after update ", 2'b00, DUT.dpath.pht.rfile[131]); 
        assertion("prediction after update", 1'b0, prediction);

        //----------------------------------------------------------------------
        // Update branch taken from 00 stay at 00
        //----------------------------------------------------------------------

        PC = {20'b0, 10'd131, 2'd0}; 
        update_val = 0; 
        update_en = 1; 

        @(negedge clk); 
        update_en = 0;   
        assertion2( "pht after update ", 2'b00, DUT.dpath.pht.rfile[131]); 
        assertion("prediction after update", 1'b0, prediction);

        //----------------------------------------------------------------------
        // resetting
        //----------------------------------------------------------------------
        reset = 1; 
        @(negedge clk); 
        reset = 0; 
        @(negedge clk); 


        //----------------------------------------------------------------------
        // Loop with no branches
        //----------------------------------------------------------------------
        $display("Test loop with no branches"); 

        PC = {20'b0, 10'h1FF, 2'd0}; 

        for ( integer i = 0; i < 10; i++) begin 
            // loop 
            update_val = 0; 
            update_en = 0; 
            @(negedge clk); 
            assertion2("pht after update", 2'b00, DUT.dpath.pht.rfile[10'h1FF]);
            assertion("prediction after update", 1'b0, prediction);
        end
        
        //----------------------------------------------------------------------
        // Loop with one branch, always taken
        //----------------------------------------------------------------------
        reset = 1; 
        @(negedge clk); 
        reset = 0; 
        @(negedge clk); 
        
        $display("Test loop with one single branch, always taken"); 

        PC = {20'b0, 10'd13, 2'd0}; 

        for ( integer i = 1; i < 11; i++) begin 
            // loop 
            update_val = 1; 
            update_en = 1; 
            @(negedge clk); 
            update_en = 0;
            if (i < 3) begin 
                assertion2("pht after update", i[1:0], DUT.dpath.pht.rfile[13]);
            end else begin 
                assertion2("pht after update", 2'b11, DUT.dpath.pht.rfile[13]);
            end
            if (i < 2) begin 
                assertion("prediction after update", 1'b0, prediction);
            end else begin 
                assertion("prediction after update", 1'b1, prediction);
            end
        end

        //----------------------------------------------------------------------
        // Loop with one branch, always not taken from 00
        //----------------------------------------------------------------------
        
        $display("Test loop with one single branch, always not taken from 00"); 

        PC = {20'b0, 10'd13, 2'd0}; 

        for ( integer i = 1; i < 11; i++) begin 
            // loop 
            update_val = 0; 
            update_en = 1; 
            @(negedge clk); 
            update_en = 0;
            
            if (i == 1) begin 
                assertion2("pht after update", 2'b10, DUT.dpath.pht.rfile[13]);
                assertion("prediction after update", 1'b1, prediction);
            end else if (i == 2) begin 
                assertion2("pht after update", 2'b01, DUT.dpath.pht.rfile[13]);
                assertion("prediction after update", 1'b0, prediction);
            end else begin 
                assertion2("pht after update", 2'b00, DUT.dpath.pht.rfile[13]);
                assertion("prediction after update", 1'b0, prediction);
            end
        end

        //----------------------------------------------------------------------
        // Loop with one branch, alternate taken and not taken
        //----------------------------------------------------------------------
        reset = 1; 
        @(negedge clk); 
        reset = 0; 
        @(negedge clk); 
        
        $display("Test loop with one single branch, alternate taken and not taken "); 

        PC = {20'b0, 10'd13, 2'd0}; 

        for ( integer i = 1; i < 11; i++) begin 
            // loop 
            integer indicator = (i % 2); // taken, not taken, taken, not taken, ... 
            update_val = indicator[0];
            update_en = 1; 
            @(negedge clk); 
            update_en = 0;
            
            test_ABAB(i); 
        end

        //----------------------------------------------------------------------
        // Loop with one branch, alternate AAAB (A = taken)
        //----------------------------------------------------------------------
        reset = 1; 
        @(negedge clk); 
        reset = 0; 
        @(negedge clk); 
        
        $display("Test loop with one single branch, AAAB "); 

        PC = {20'b0, 10'd13, 2'd0}; 

        for ( integer i = 0; i < 20; i++) begin 
            // loop 
            integer indicator = (i % 4); // taken, taken, taken, not taken, taken ... 
            // 01, 10, 11, 10, 11, 11, 11, 10, 11, 11, 11, 10, ....
            update_val = indicator < 3;
            update_en = 1; 
            @(negedge clk); 
            update_en = 0;
            
            test_AAAB(i);
        end

        //----------------------------------------------------------------------
        // Loop with one branch, alternate BBBA (A = taken)
        //----------------------------------------------------------------------
        reset = 1; 
        update_val = 0; 
        update_en = 1; 
        @(negedge clk); 
        reset = 0; 
        @(negedge clk); 
        
        $display("Test loop with one single branch, BBBA "); 

        PC = {20'b0, 10'd13, 2'd0}; 

        for ( integer i = 0; i < 20; i++) begin 
            // loop 
            integer indicator = (i % 4); // nnnt, nnnt, nnnt
            update_val = indicator >= 3;
            update_en = 1; 
            @(negedge clk); 
            update_en = 0;
            
            test_BBBA(i);
        end

        //----------------------------------------------------------------------
        // Loop with one branch, alternate ABBA (A = taken)
        //----------------------------------------------------------------------
        reset = 1; 
        update_val = 0; 
        update_en = 1; 
        @(negedge clk); 
        reset = 0; 
        @(negedge clk); 
        
        $display("Test loop with one single branch, ABBA "); 

        PC = {20'b0, 10'd13, 2'd0}; 

        for ( integer i = 0; i < 20; i++) begin 
            // loop 
            integer indicator = (i % 4); // nnnt, nnnt, nnnt
            update_val = indicator == 0 || indicator == 3;
            update_en = 1; 
            @(negedge clk); 
            update_en = 0;
            
            test_ABBA(i);
        end

        //----------------------------------------------------------------------
        // Loop with one branch, alternate AAB (A = taken)
        //----------------------------------------------------------------------
        reset = 1; 
        update_val = 0; 
        update_en = 1; 
        @(negedge clk); 
        reset = 0; 
        @(negedge clk); 
        
        $display("Test loop with one single branch, AAB "); 

        PC = {20'b0, 10'd13, 2'd0}; 

        for ( integer i = 0; i < 27; i++) begin 
            // loop 
            integer indicator = (i % 3); // nnnt, nnnt, nnnt
            update_val = indicator < 2;
            update_en = 1; 
            @(negedge clk); 
            update_en = 0;
            
            test_AAB(i);
        end

        //----------------------------------------------------------------------
        // Loop with one branch, alternate BBA (A = taken)
        //----------------------------------------------------------------------
        reset = 1; 
        update_val = 0; 
        update_en = 1; 
        @(negedge clk); 
        reset = 0; 
        @(negedge clk); 
        
        $display("Test loop with one single branch, BBA "); 

        PC = {20'b0, 10'd13, 2'd0}; 

        for ( integer i = 0; i < 27; i++) begin 
            // loop 
            integer indicator = (i % 3); // nnt, nnt
            update_val = indicator == 2;
            update_en = 1; 
            @(negedge clk); 
            update_en = 0;
            
            test_BBA(i, 10'd13);
        end


        #20; 
        $finish();
    end

    task test_BBA( integer index, [9:0] addr); 
        // 00 00 01     00 00 01    00 00 01    
        if (index % 3 < 2) begin 
            assertion2("pht after update", 2'b00, DUT.dpath.pht.rfile[addr]);
            assertion("prediction after update", 1'b0, prediction);
        end else begin 
            assertion2("pht after update", 2'b01, DUT.dpath.pht.rfile[addr]);
            assertion("prediction after update", 1'b0, prediction);
        end

    endtask


    task test_AAB( integer index); 
        // 01, 10, 01      10, 11, 10,    11, 11, 10     11, 11, 10     11
        if ( index / 3 == 0) begin 
            if (index == 1) begin 
                assertion2("pht after update", 2'b10, DUT.dpath.pht.rfile[13]);
                assertion("prediction after update", 1'b1, prediction);
            end else begin 
                assertion2("pht after update", 2'b01, DUT.dpath.pht.rfile[13]);
                assertion("prediction after update", 1'b0, prediction);
            end
        end else if ( index / 3 == 1)begin 
            if (index%3 == 1) begin 
                assertion2("pht after update", 2'b11, DUT.dpath.pht.rfile[13]);
                assertion("prediction after update", 1'b1, prediction);
            end else begin 
                assertion2("pht after update", 2'b10, DUT.dpath.pht.rfile[13]);
                assertion("prediction after update", 1'b1, prediction);
            end
        end else begin 
            if ( index % 3 < 2) begin 
                assertion2("pht after update", 2'b11, DUT.dpath.pht.rfile[13]);
                assertion("prediction after update", 1'b1, prediction);
            end
            else begin 
                assertion2("pht after update", 2'b10, DUT.dpath.pht.rfile[13]);
                assertion("prediction after update", 1'b1, prediction);
            end
        end

    endtask

  
    task test_ABBA( integer index); 
        // 01, 00, 00, 01,   10, 01, 00, 01,    10, 01, 00, 01
        if ((index / 4) == 0) begin 
            if ( index % 4 == 0 || index % 4 == 3) begin 
                assertion2("pht after update", 2'b01, DUT.dpath.pht.rfile[13]);
                assertion("prediction after update", 1'b0, prediction);
            end
            else begin 
                assertion2("pht after update", 2'b00, DUT.dpath.pht.rfile[13]);
                assertion("prediction after update", 1'b0, prediction);
            end
        end else begin 
            if ( index % 2 == 1) begin 
                assertion2("pht after update", 2'b01, DUT.dpath.pht.rfile[13]);
                assertion("prediction after update", 1'b0, prediction);
            end
            else if (index % 4 == 0) begin 
                assertion2("pht after update", 2'b10, DUT.dpath.pht.rfile[13]);
                assertion("prediction after update", 1'b1, prediction);
            end else begin 
                assertion2("pht after update", 2'b00, DUT.dpath.pht.rfile[13]);
                assertion("prediction after update", 1'b0, prediction);
            end
        end

    endtask

    task test_BBBA( integer index ); 
        // 00, 00, 00, 01, 00, 00, 00, 01
        $display("index: %d", index);
        if ( index % 4 < 3) begin 
            assertion2("pht after update", 2'b00, DUT.dpath.pht.rfile[13]);
            assertion("prediction after update", 1'b0, prediction);
        end
        else begin 
            assertion2("pht after update", 2'b01, DUT.dpath.pht.rfile[13]);
            assertion("prediction after update", 1'b0, prediction);
        end
    endtask

    task test_AAAB( integer index ); 
        if ( index == 0 ) begin 
            assertion2("pht after update", 2'b01, DUT.dpath.pht.rfile[13]);
            assertion("prediction after update", 1'b0, prediction);
        end 
        else if ( index == 1 ) begin 
            assertion2("pht after update", 2'b10, DUT.dpath.pht.rfile[13]);
            assertion("prediction after update", 1'b1, prediction);
        end
        else if ( index % 4 < 3) begin 
            assertion2("pht after update", 2'b11, DUT.dpath.pht.rfile[13]);
            assertion("prediction after update", 1'b1, prediction);
        end
        else begin 
            assertion2("pht after update", 2'b10, DUT.dpath.pht.rfile[13]);
            assertion("prediction after update", 1'b1, prediction);
        end
    endtask

    task test_ABAB( integer index ); 
        if ( index % 2 == 1) begin 
            assertion2("pht after update", 2'b01, DUT.dpath.pht.rfile[13]);
            assertion("prediction after update", 1'b0, prediction);
        end else begin 
            assertion2("pht after update", 2'b00, DUT.dpath.pht.rfile[13]);
            assertion("prediction after update", 1'b0, prediction);
        end
    endtask


    task assertion( string varname, [0:0] expected, [0:0] actual ); 
        begin 
            assert(expected == actual) begin
                $display("%s is correct.  Expected: %h, Actual: %h", varname, expected, actual); pass();
            end else begin
                $display("%s is incorrect.  Expected: %h, Actual: %h", varname, expected, actual); fail(); 
            end 
        end
    endtask

    task assertion2( string varname, [1:0] expected, [1:0] actual ); 
        begin 
            assert(expected == actual) begin
                $display("%s is correct.  Expected: %b, Actual: %b", varname, expected, actual); pass();
            end else begin
                $display("%s is incorrect.  Expected: %b, Actual: %b", varname, expected, actual); fail(); 
            end 
        end
    endtask

    logic clock_counter; 
    initial begin 
        clock_counter = 0; 
        for (integer i = 0; i < 20000; i++) begin 
            @(posedge clk);
            clock_counter = !clock_counter; 
        end

        $display("test time exceeded, Terminating"); 
        $finish();
    end

endmodule
