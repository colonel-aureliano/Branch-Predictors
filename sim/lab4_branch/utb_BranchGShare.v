//========================================================================
// utb_BranchGShare
//========================================================================
// A basic Verilog unit test bench for the GShare Branch Predictor Design module

`default_nettype none
`timescale 1ps/1ps

import "DPI-C" function void pass() ;
import "DPI-C" function void fail() ;

`include "BranchGShare.v"
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
    lab4_branch_BranchGshare #(16) DUT
    ( 
        .*
    ); 
    // 4 index bits

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

        PC = {20'b0, 10'b10000011, 2'd0}; 

        #0.02; 
        assertion( "initial should predict 0", 1'b0, prediction); 
        @(negedge clk); 

        //----------------------------------------------------------------------
        // Update branch history 1 time 
        //----------------------------------------------------------------------
        
        $display("updating pht at %d", 3); 
        update_val = 1; 
        update_en = 1; 
        
        @(negedge clk); 
        update_en = 0;
        assertion4("global history after update ", 4'b01, DUT.glob_reg_out); 
        assertion2("rfile after update", 2'b01, DUT.pht.rfile[3]); // 0011 ^ 0000 = 0011
        @(negedge clk); 

        //----------------------------------------------------------------------
        // Update branch history 4 more times with 0
        //----------------------------------------------------------------------

        PC = {20'b0, 10'b10000011, 2'd0}; 

        for (integer i = 1; i < 5; i++) begin 
            $display("iteration: %d", i);
            update_val = 0; 
            update_en = 1; 
            
            @(negedge clk); 
            update_en = 0;

            assertion4("global history after update ", 4'b1 << i, DUT.glob_reg_out); 
            assertion2("rfile after update", 2'b00, DUT.pht.rfile[(4'b1 << (i-1))^(PC[2+3:2])]); 
            @(negedge clk); 
        end 
        assertion("prediction with history 0000", 1'b0, prediction);

        //----------------------------------------------------------------------
        // Update branch history 1 time, update pht[3] from 01 to 10
        //---------------------------------------------------------------------- 
        $display("updating pht at %d", 3); 
        PC = {20'b0, 10'b10000011, 2'd0};
        update_val = 1; 
        update_en = 1; 
        
        @(negedge clk); 
        update_en = 0;

        assertion4("global history after update ", 4'b01, DUT.glob_reg_out); 
        assertion2("rfile after update", 2'b10, DUT.pht.rfile[3]); // 0011 ^ 0000 = 0011
        @(negedge clk);  

        //----------------------------------------------------------------------
        // Update branch history 4 more times with 0
        //----------------------------------------------------------------------
        
        PC = {20'b0, 10'b10000011, 2'd0}; 

        for (integer i = 1; i < 5; i++) begin 
            $display("iteration: %d", i);
            update_val = 0; 
            update_en = 1; 
            
            @(negedge clk); 
            update_en = 0;

            assertion4("global history after update ", 4'b1 << i, DUT.glob_reg_out); 
            assertion2("rfile after update", 2'b00, DUT.pht.rfile[(4'b1 << (i-1))^(PC[2+3:2])]); 
            @(negedge clk); 
        end 

        assertion("prediction: ", 1'b1, prediction);

        //----------------------------------------------------------------------
        // Update branch history 1 time, update pht[0] from 10 to 11
        //----------------------------------------------------------------------
        
        $display("updating pht at %d", 3); 
        update_val = 1; 
        update_en = 1; 
        
        @(negedge clk); 
        update_en = 0;

        assertion4("global history after update ", 4'b01, DUT.glob_reg_out); 
        assertion2("rfile after update", 2'b11, DUT.pht.rfile[3]); 
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

            assertion4("global history after update ", (place_holder << 1) + 1, DUT.glob_reg_out); 
            assertion2("rfile after update", 2'b01, DUT.pht.rfile[place_holder^(PC[2+3:2])]); 
            assertion("small prediction", 1'b0, prediction); 

            assign place_holder = (place_holder << 1) + 1;
            @(negedge clk); 
        end 

        assertion("prediction at history 1111", 1'b0, prediction);

        //----------------------------------------------------------------------
        // Update branch history 4 more times with 1, history remain in 1111, update from 01 to 11
        //----------------------------------------------------------------------

        $display("Update branch history 4 more times with 1, history remain in 1111, update from 01 to 11");
        assign place_holder = 4'b1;  // should hold the expected index value
        for (integer i = 1; i < 5; i++) begin 
            $display("iteration: %d", i);
            update_val = 1; 
            update_en = 1; 
            
            @(negedge clk); 
            update_en = 0;

            if ( place_holder < 4'b11 ) place_holder = place_holder + 1; 

            assertion4("global history after update ", 4'b1111, DUT.glob_reg_out); 
            assertion2("rfile after update", place_holder[1:0], DUT.pht.rfile[15^(PC[2+3:2])]); 
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
        update_en = 0; 
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
        update_en = 0; 
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
        if ( index == 0 )          rf_index = 4'b1111; 
        else if ( index == 1 )     rf_index = 4'b1110; 
        else if ( index == 2 )     rf_index = 4'b1100; 
        else if ( index == 3 )     rf_index = 4'b1000; 
        else if ( index % 4 == 0 ) rf_index = 4'b0001; 
        else if ( index % 4 == 1 ) rf_index = 4'b0010; 
        else if ( index % 4 == 2 ) rf_index = 4'b0100; 
        else                       rf_index = 4'b1000; 

        if ( index == 0) assertion4("global history after update ", 4'b1110, DUT.index); 
        else if ( index == 1 ) assertion4("global history after update ", 4'b1100, DUT.index); 
        else if ( index % 4 == 2 ) assertion4("global history after update", 4'b1000, DUT.index); 
        else if ( index % 4 == 3 ) assertion4("global history after update", 4'b0001, DUT.index); 
        else if ( index % 4 == 0 ) assertion4("global history after update", 4'b0010, DUT.index); 
        else                       assertion4("global history after update", 4'b0100, DUT.index); 

        if ( index < 8 ) begin 
            if ( index % 4 < 3 ) assertion2("rfile after update", 2'b01, DUT.pht.rfile[rf_index]); 
            else                 assertion2("rfile after update", 2'b00, DUT.pht.rfile[rf_index]); 
        end else if ( index / 4 == 2) begin 
            if ( index % 4 < 3 ) assertion2("rfile after update", 2'b10, DUT.pht.rfile[rf_index]); 
            else                 assertion2("rfile after update", 2'b00, DUT.pht.rfile[rf_index]); 
        end else begin 
            if ( index % 4 < 3 ) assertion2("rfile after update", 2'b11, DUT.pht.rfile[rf_index]); 
            else                 assertion2("rfile after update", 2'b00, DUT.pht.rfile[rf_index]); 
        end

        if ( index < 11 || index % 4 == 2 ) assertion("prediction", 0, prediction); 
        else if ( index == 11 || index % 4 != 2 ) assertion("prediction", 1, prediction);
        
    endtask
    
    task ABAB ( integer index ); 
        $display("index: %d", index);
        if ( index <= 2 ) begin 
            rf_index = index[3:0]^4'b1111;
        end else if ( index % 2 == 1) begin 
            rf_index = 4'd5^4'b1111; 
        end else if (index % 2 == 0) begin 
            rf_index = 4'd10^4'b1111; 
        end

        if ( index == 0 ) begin 
            assertion4("global history after update ", 4'b1^4'b1111, DUT.index); 
        end else if ( index == 1 ) begin 
            assertion4("global history after update ", 4'b10^4'b1111, DUT.index); 
        end
        else if (index % 2 == 0) begin 
            assertion4("global history after update ", 4'b0101^4'b1111, DUT.index); 
        end else begin 
            assertion4("global history after update ", 4'b1010^4'b1111, DUT.index); 
        end

        if (index % 2 == 1) begin 
            assertion2("rfile after update", 2'b0, DUT.pht.rfile[rf_index]); 
        end else if (index < 6) begin 
            assertion2("rfile after update", 2'b01, DUT.pht.rfile[rf_index]); 
        end else if (index == 6) begin 
            assertion2("rfile after update", 2'b10, DUT.pht.rfile[rf_index]); 
        end else begin 
            assertion2("rfile after update", 2'b11, DUT.pht.rfile[rf_index]); 
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
