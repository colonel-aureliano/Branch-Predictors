//=========================================================================
// Branch Predictor Gshare Design
//=========================================================================

`ifndef LAB4_BRANCH_BRANCH_GSHARE_V
`define LAB4_BRANCH_BRANCH_GSHARE_V

`include "vc/mem-msgs.v"
`include "vc/queues.v"
`include "vc/trace.v"


module lab4_branch_BranchGshare
#(
  parameter PHT_size  = 2048
)
(
  input  logic         clk,
  input  logic         reset,
  input logic update_en,
  input logic update_val,
  input logic [31:0] PC,
  output logic prediction

);


endmodule

`endif
