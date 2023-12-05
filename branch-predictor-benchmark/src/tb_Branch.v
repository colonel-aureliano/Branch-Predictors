//========================================================================
// tb_IntMul
//========================================================================
// A basic Verilog test bench for the multiplier

`default_nettype none
`timescale 1ps/1ps

`ifndef DESIGN
  `define DESIGN BranchBimodal
`endif

`ifndef PHT
  `define PHT 2048
`endif

`include `"`DESIGN.v`"

//------------------------------------------------------------------------
// Top-level module
//------------------------------------------------------------------------

module top(    input  logic         clk,
  input  logic         reset,
  input logic update_en,
  input logic update_val,
  input logic[31:0] PC,
  output logic prediction );


  //----------------------------------------------------------------------
  // Module instantiations
  //----------------------------------------------------------------------
  
  lab4_branch_`DESIGN #( `PHT ) dut (

    .*
  );
  

  

  endmodule
