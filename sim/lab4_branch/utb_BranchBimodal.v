//========================================================================
// utb_CacheBase
//========================================================================
// A basic Verilog unit test bench for the Cache Base Design module

`default_nettype none
`timescale 1ps/1ps


`include "BranchBimodal.v"
`include "vc/trace.v"
`include "vc/regfiles.v"
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


        #20; 
        $finish();
    end
  
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
