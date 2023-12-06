//========================================================================
// utb_reg
//========================================================================
// A basic Verilog unit test bench for the regs module

`default_nettype none
`timescale 1ps/1ps

import "DPI-C" function void pass() ;
import "DPI-C" function void fail() ;

`include "regs.v"

//------------------------------------------------------------------------
// Top-level module
//------------------------------------------------------------------------

module top(  input logic clk, input logic linetrace );
    
    logic         reset;

      // Read port (combinational read)

    logic [511:0] q;

      // Write port (sampled on the rising clock edge)

    logic         en;
    logic [511:0] d;

    //----------------------------------------------------------------------
    // Module instantiations
    //----------------------------------------------------------------------
    
    // Instantiate the processor datapath
    enResetReg #(512) DUT
    ( 
        .*
    ); 

    //----------------------------------------------------------------------
    // Run the Test Bench
    //----------------------------------------------------------------------

    logic [511:0] expected;
    initial begin

        $display("Start of Testbench");
        // Initalize all the signal inital values.
        reset = 1; 
        en = 0;
        d = 0;

        @(negedge clk);
        reset = 0; 
        d = {32'd1, 32'd2,  32'd3, 32'd4, 32'd5, 32'd6, 32'd7, 32'd8, 32'd9, 32'd10, 32'd11, 32'd12, 32'd13, 32'd14, 32'd15, 32'd16}; 
        en = 1;
        @(negedge clk);         
        assertion("check response", d, DUT.q);
        #1;
        en = 0;
        @(negedge clk); 
        assertion("check response", d, DUT.q);
        #1;
        reset = 1;
        @(negedge clk); 
        assertion("check response", 0, DUT.q);
        #2;
        reset = 0;
        @(negedge clk); 
        d = -1;
        en = 1;
        @(negedge clk); 
        assertion("check response", -1, DUT.q);
        d = 1;
        @(negedge clk); 
        assertion("check response", 1, DUT.q);
        $finish();

    end
  
    task assertion( string varname, [511:0] expected, [511:0] actual ); 
        begin 
            assert(expected == actual) begin
                $display("%s is correct.  Expected: %h, Actual: %h", varname, expected, actual); pass();
            end else begin
                $display("%s is incorrect.  Expected: %h, Actual: %h", varname, expected, actual); fail(); 
            end 
        end
    endtask

endmodule
