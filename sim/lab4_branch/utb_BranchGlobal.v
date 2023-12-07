//========================================================================
// utb_BranchGlobal
//========================================================================
// A basic Verilog unit test bench for the Global Branch Predictor Design module

`default_nettype none
`timescale 1ps/1ps

import "DPI-C" function void pass() ;
import "DPI-C" function void fail() ;

`include "BranchGlobal.v"
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
    lab4_branch_BranchGlobal #(16) DUT
    ( 
        .*
    ); 

    //----------------------------------------------------------------------
    // Run the Test Bench
    //----------------------------------------------------------------------

    logic [3:0] place_holder;
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
        // Update branch history 1 time 
        //----------------------------------------------------------------------
        
        $display("updating %d", 0); 
        update_val = 1; 
        update_en = 1; 
        
        @(negedge clk); 
        update_en = 0;

        assertion4("global history after update ", 4'b01, DUT.dpath.index); 
        assertion2("rfile after update", 2'b01, DUT.dpath.pht.rfile[0]); 
        @(negedge clk); 

        //----------------------------------------------------------------------
        // Update branch history 4 more times with 0
        //----------------------------------------------------------------------

        for (integer i = 1; i < 5; i++) begin 
            $display("iteration: %d", i);
            update_val = 0; 
            update_en = 1; 
            
            @(negedge clk); 
            update_en = 0;

            assertion4("global history after update ", 4'b1 << i, DUT.dpath.index); 
            assertion2("rfile after update", 2'b00, DUT.dpath.pht.rfile[4'b1 << (i-1)]); 
            @(negedge clk); 
        end 
        assertion("prediction with history 0000", 1'b0, prediction);

        //----------------------------------------------------------------------
        // Update branch history 1 time, update pht[0] from 01 to 10
        //----------------------------------------------------------------------
        
        $display("updating %d", 0); 
        update_val = 1; 
        update_en = 1; 
        
        @(negedge clk); 
        update_en = 0;

        assertion4("global history after update ", 4'b01, DUT.dpath.index); 
        assertion2("rfile after update", 2'b10, DUT.dpath.pht.rfile[0]); 
        @(negedge clk); 

        //----------------------------------------------------------------------
        // Update branch history 4 more times with 0
        //----------------------------------------------------------------------

        for (integer i = 1; i < 5; i++) begin 
            $display("iteration: %d", i);
            update_val = 0; 
            update_en = 1; 
            
            @(negedge clk); 
            update_en = 0;

            assertion4("global history after update ", 4'b1 << i, DUT.dpath.index); 
            assertion2("rfile after update", 2'b00, DUT.dpath.pht.rfile[4'b1 << (i-1)]); 
            @(negedge clk); 
        end 

        assertion("prediction: ", 1'b1, prediction);

        //----------------------------------------------------------------------
        // Update branch history 1 time, update pht[0] from 10 to 11
        //----------------------------------------------------------------------
        
        $display("updating %d", 0); 
        update_val = 1; 
        update_en = 1; 
        
        @(negedge clk); 
        update_en = 0;

        assertion4("global history after update ", 4'b01, DUT.dpath.index); 
        assertion2("rfile after update", 2'b11, DUT.dpath.pht.rfile[0]); 
        @(negedge clk); 

        //----------------------------------------------------------------------
        // Update branch history 4 more times with 1
        //----------------------------------------------------------------------
        
        assign place_holder = 1; 
        for (integer i = 1; i < 5; i++) begin 
            $display("iteration: %d", i);
            update_val = 1; 
            update_en = 1; 
            
            @(negedge clk); 
            update_en = 0;

            assertion4("global history after update ", (place_holder << 1) + 1, DUT.dpath.index); 
            assertion2("rfile after update", 2'b01, DUT.dpath.pht.rfile[place_holder]); 
            assertion("small prediction", 1'b0, prediction); 

            assign place_holder = (place_holder << 1) + 1;
            @(negedge clk); 
        end 

        assertion("prediction at history 1111", 1'b0, prediction);

        //----------------------------------------------------------------------
        // Update branch history 4 more times with 1, history remain in 1111, update from 01 to 11
        //----------------------------------------------------------------------
        
        assign place_holder = 4'b1;  // should hold the expected index value
        for (integer i = 1; i < 5; i++) begin 
            $display("iteration: %d", i);
            update_val = 1; 
            update_en = 1; 
            
            @(negedge clk); 
            update_en = 0;

            if ( place_holder < 4'b11 ) place_holder = place_holder + 1; 

            assertion4("global history after update ", 4'b1111, DUT.dpath.index); 
            assertion2("rfile after update", place_holder[1:0], DUT.dpath.pht.rfile[15]); 
            assertion("small prediction", place_holder[1], prediction); 

            
            @(negedge clk); 
        end 

        assertion("prediction at history 1111", 1'b1, prediction);

        //----------------------------------------------------------------------
        // loop with one branch ABAB
        //----------------------------------------------------------------------

        $display("=======================loop with one branch ABAB===========");
        reset = 1; 
        update_val = 0; 
        update_en = 1; 
        @(negedge clk); 
        reset = 0; 
        @(negedge clk); 
        
        $display("Test loop with one single branch, ABAB "); 

        PC = 32'hFFFFFFFF; 
        // 0000, -> 0001 -> 0010 -> 0101 -> 1010 -> 0101 -> 1010 -> 0101 -> 1010 -> ...
        //      1       0       1       0       1       0       1       0       1 
        //      01      00      01      00      01      00      10      00      11
        //          0       0       0       0       0       0       0       1
        for ( integer i = 0; i < 25; i++) begin 
            update_val = i % 2 == 0; 
            update_en = 1; 
            
            @(negedge clk); 
            update_en = 0;
            ABAB(i); 
        end

        //----------------------------------------------------------------------
        // loop with one branch AAAB
        //----------------------------------------------------------------------

        $display("=======================loop with AAAB picked pattern===========");
        reset = 1; 
        update_val = 0; 
        update_en = 1; 
        @(negedge clk); 
        reset = 0; 
        @(negedge clk); 
        

        PC = 32'hFFFFFFFF; 
        place_holder = 0; 
        // 0000, -> 0001 -> 0011 -> 0111 -> 1110 -> 1101 -> 1011 -> 0111 -> 1110 -> 1101 -> 1011 -> 0110 -> 1110 -> 1101 -> 1011 -> 0110
        //      1       1       1       0       1       1       1       0       1       1       1       0       1       1       1       
        //      01      01      01      00      01      01      01      00      10      10      10      00      11      11      11      0 
        //          0       0       0       0       0       0       0       0       0       0       0       1       1       1       0   
        for ( integer i = 0; i < 25; i++) begin 
            update_val = i % 4 < 3; 
            update_en = 1; 
            
            @(negedge clk); 
            update_en = 0;

            AAAB(i);

        end


        #20; 
        $finish();
    end

    logic [3:0] rf_index; 
    task AAAB (integer index); 
        if ( index == 0 )          rf_index = 0; 
        else if ( index == 1 )     rf_index = 1; 
        else if ( index == 2 )     rf_index = 3; 
        else if ( index == 3 )     rf_index = 4'b0111; 
        else if ( index % 4 == 0 ) rf_index = 4'b1110; 
        else if ( index % 4 == 1 ) rf_index = 4'b1101; 
        else if ( index % 4 == 2 ) rf_index = 4'b1011; 
        else                       rf_index = 4'b0111; 

        if ( index == 0) assertion4("global history after update ", 4'b1, DUT.dpath.index); 
        else if ( index == 1 ) assertion4("global history after update ", 4'b11, DUT.dpath.index); 
        else if ( index % 4 == 2 ) assertion4("global history after update", 4'b0111, DUT.dpath.index); 
        else if ( index % 4 == 3 ) assertion4("global history after update", 4'b1110, DUT.dpath.index); 
        else if ( index % 4 == 0 ) assertion4("global history after update", 4'b1101, DUT.dpath.index); 
        else                       assertion4("global history after update", 4'b1011, DUT.dpath.index); 

        if ( index < 8 ) begin 
            if ( index % 4 < 3 ) assertion2("rfile after update", 2'b01, DUT.dpath.pht.rfile[rf_index]); 
            else                 assertion2("rfile after update", 2'b00, DUT.dpath.pht.rfile[rf_index]); 
        end else if ( index / 4 == 2) begin 
            if ( index % 4 < 3 ) assertion2("rfile after update", 2'b10, DUT.dpath.pht.rfile[rf_index]); 
            else                 assertion2("rfile after update", 2'b00, DUT.dpath.pht.rfile[rf_index]); 
        end else begin 
            if ( index % 4 < 3 ) assertion2("rfile after update", 2'b11, DUT.dpath.pht.rfile[rf_index]); 
            else                 assertion2("rfile after update", 2'b00, DUT.dpath.pht.rfile[rf_index]); 
        end

        if ( index < 11 || index % 4 == 2 ) assertion("prediction", 0, prediction); 
        else if ( index == 11 || index % 4 != 2 ) assertion("prediction", 1, prediction);
        
    endtask
    
    task ABAB ( integer index ); 
        $display("index: %d", index);
        if ( index <= 2 ) begin 
            rf_index = index[3:0];
        end else if ( index % 2 == 1) begin 
            rf_index = 4'd5; 
        end else if (index % 2 == 0) begin 
            rf_index = 4'd10; 
        end

        if ( index == 0 ) begin 
            assertion4("global history after update ", 4'b1, DUT.dpath.index); 
        end else if ( index == 1 ) begin 
            assertion4("global history after update ", 4'b10, DUT.dpath.index); 
        end
        else if (index % 2 == 0) begin 
            assertion4("global history after update ", 4'b0101, DUT.dpath.index); 
        end else begin 
            assertion4("global history after update ", 4'b1010, DUT.dpath.index); 
        end

        if (index % 2 == 1) begin 
            assertion2("rfile after update", 2'b0, DUT.dpath.pht.rfile[rf_index]); 
        end else if (index < 6) begin 
            assertion2("rfile after update", 2'b01, DUT.dpath.pht.rfile[rf_index]); 
        end else if (index == 6) begin 
            assertion2("rfile after update", 2'b10, DUT.dpath.pht.rfile[rf_index]); 
        end else begin 
            assertion2("rfile after update", 2'b11, DUT.dpath.pht.rfile[rf_index]); 
        end

        if ( index <= 6 || index % 2 == 0) begin 
            assertion("prediction", 0, prediction); 
        end else begin 
            assertion("prediction", 1, prediction); 
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

    task assertion4( string varname, [3:0] expected, [3:0] actual ); 
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
