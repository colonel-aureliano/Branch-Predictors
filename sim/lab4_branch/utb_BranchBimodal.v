//========================================================================
// utb_CacheBase
//========================================================================
// A basic Verilog unit test bench for the Cache Base Design module

`default_nettype none
`timescale 1ps/1ps


`include "BranchBimodal.v"
`include "vc/trace.v"

//------------------------------------------------------------------------
// Top-level module
//------------------------------------------------------------------------

module top(  input logic clk, input logic linetrace );

    logic         reset;
    logic         update_en;
    logic         update_val;
    logic         PC;
    logic         prediction;
    //----------------------------------------------------------------------
    // Module instantiations
    //----------------------------------------------------------------------
    
    // Instantiate the processor datapath
    lab4_branch_BranchBimodal DUT
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
        @(negedge clk); 

        reset = 1
        $finish();
    end
  
    task assertion( string varname, [31:0] expected, [31:0] actual ); 
        begin 
            assert(expected == actual) begin
                $display("%s is correct.  Expected: %h, Actual: %h", varname, expected, actual); pass();
            end else begin
                $display("%s is incorrect.  Expected: %h, Actual: %h", varname, expected, actual); fail(); 
            end 
        end
    endtask

    task assertion512( string varname, [511:0] expected, [511:0] actual ); 
        begin 
            assert(expected == actual) begin
                $display("%s is correct.  Expected: %h, Actual: %h", varname, expected, actual); pass();
            end else begin
                $display("%s is incorrect.  Expected: %h, Actual: %h", varname, expected, actual); fail(); 
            end 
        end
    endtask

    initial begin 
        for (integer i = 0; i < 20000; i++) begin 
            @(negedge clk);
            clock_counter = !clock_counter; 
        end

        $display("test time exceeded, Terminating"); 
        $finish();
    end

endmodule
