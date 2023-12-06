//========================================================================
// utb_regfiles
//========================================================================
// A basic Verilog unit test bench for the regfiles module

`default_nettype none
`timescale 1ps/1ps

import "DPI-C" function void pass() ;
import "DPI-C" function void fail() ;

`include "regfiles.v"

//------------------------------------------------------------------------
// Top-level module
//------------------------------------------------------------------------

module top(  input logic clk, input logic linetrace );
    
    localparam num_entries = 32;
    localparam addr_nbits  = $clog2(num_entries);

    logic         reset;

      // Read port (combinational read)

    logic [addr_nbits-1:0] read_addr;
    logic [511:0] read_data;

      // Write port (sampled on the rising clock edge)

    logic         write_en;
    logic [addr_nbits-1:0] write_addr;
    logic [511:0] write_data;

    //----------------------------------------------------------------------
    // Module instantiations
    //----------------------------------------------------------------------
    
    // Instantiate the processor datapath
    resetRegfile_1r1w #(512,num_entries) DUT
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
        write_en = 0;
        write_addr = 0;
        write_data = 0;

        @(negedge clk);
        reset = 0; 
        write_addr = 2; 
        write_data = {32'd1, 32'd2,  32'd3, 32'd4, 32'd5, 32'd6, 32'd7, 32'd8, 32'd9, 32'd10, 32'd11, 32'd12, 32'd13, 32'd14, 32'd15, 32'd16}; 
        write_en = 1;
        @(negedge clk);         
        assertion("check response", write_data, DUT.rfile[2]);
        @(negedge clk); 
        write_addr = 3;
        @(negedge clk); 
        assertion("check response", write_data, DUT.rfile[3]);
        #1;
        write_addr = 5;
        write_en = 0;
        @(negedge clk); 
        assertion("check response", 0, DUT.rfile[5]);
        #1;
        reset = 1;
        @(negedge clk); 
        assertion("check response", 0, DUT.rfile[3]);
        assertion("check response", 0, DUT.rfile[2]);
        #2;
        reset = 0;
        @(negedge clk); 
        write_data = -1;
        write_en = 1;
        for ( integer i = 0; i < num_entries; i++) begin 
            write_addr = i[4:0];
            @(negedge clk); 
            assertion("check response", -1, DUT.rfile[i]);
        end
        write_data = 1;
        for ( integer i = 0; i < num_entries; i++) begin 
            write_addr = i[4:0];
            @(negedge clk); 
            assertion("check response", 1, DUT.rfile[i]);
        end
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
