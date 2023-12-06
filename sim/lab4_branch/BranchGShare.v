//=========================================================================
// Branch Predictor Gshare Design
//=========================================================================

`ifndef LAB4_BRANCH_BRANCH_GSHARE_V
`define LAB4_BRANCH_BRANCH_GSHARE_V

`include "regfiles.v"
`include "regs.v" 

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

  localparam c_addr_nbits  = $clog2(PHT_size);

  // control signals
  logic glob_reg_en;
  logic [ 1:0] pht_wdata;

  // ==================================== 
  // Datapath
  // ==================================== 

  logic [c_addr_nbits-1:0] glob_reg_out;
  logic [c_addr_nbits-1:0] glob_reg_update;

  vc_EnResetReg #(c_addr_nbits) glob_reg 
  (
    .clk (clk), 
    .reset (reset), 
    .d    ( glob_reg_update ), 
    .q    ( glob_reg_out ), 
    .en   ( glob_reg_en ) 
  );

  logic [c_addr_nbits-2:0] extender; 
  assign extender = 0; 
  assign glob_reg_update = {extender,update_val} + (glob_reg_out << 1);

  logic [c_addr_nbits-1:0] index; 
  assign index = PC[c_addr_nbits-1+2:2] ^ glob_reg_out;
  // assuming lowest 2 bits of PC are always 0

  logic [ 1:0] rdata;

  vc_ResetRegfile_1r1w #(2, PHT_size) pht
  (
    .clk(clk), 
    .reset(reset), 

    .read_addr(index),
    .read_data(rdata),
    .write_en(update_en),
    .write_addr(index),
    .write_data(pht_wdata)
  );

  assign prediction = rdata[1];

  // ==================================== 
  // Control Unit
  // ==================================== 
  
  assign glob_reg_en = update_en;

  always_comb begin 
    if ( update_en ) begin       
      casez ( rdata ) 
        2'b00:   if ( update_val ) pht_wdata = 2'b1; 
                 else pht_wdata = 2'b0; 
        2'b11:   if ( update_val ) pht_wdata = 2'b11; 
                 else pht_wdata = 2'b10; 
        default: if ( update_val ) pht_wdata = rdata + 1; 
                 else pht_wdata = rdata - 1; 
      endcase
    end 
    else begin 
      pht_wdata = 2'hx; 
    end 
  end

endmodule

`endif
