//=========================================================================
// Branch Predictor Global Design
//=========================================================================

`ifndef LAB4_BRANCH_BRANCH_GLOBAL_V
`define LAB4_BRANCH_BRANCH_GLOBAL_V

`include "regs.v" 
`include "regfiles.v" 

module lab4_branch_BranchGlobal
#(
  parameter PHT_size  = 2048
)
(
  input  logic        clk,
  input  logic        reset,
  input  logic        update_en,
  input  logic        update_val,
  input  logic [31:0] PC,
  output logic        prediction

);

  logic glob_reg_en; 
  logic glob_mux_sel; 
  logic pht_wen; 
  logic [1:0] pht_wdata; 
  logic [1:0] rdata; 

  lab4_branch_BranchGlobal_DPath #(PHT_size) dpath
  (
    .clk       (clk), 
    .reset     (reset), 
    .update_val (update_val),
    .pht_wen   (pht_wen), 
    .pht_wdata (pht_wdata), 
    .glob_reg_en (glob_reg_en), 
    .glob_mux_sel (glob_mux_sel), 
    .PC        (PC), 
    .rdata     (rdata), 
    .prediction(prediction)   
  ); 

  lab4_branch_BranchGlobal_Ctrl ctrl 
  (
    .clk        (clk), 
    .reset      (reset), 
    .rdata      (rdata), 
    .update_en  (update_en), 
    .update_val (update_val), 
    .pht_wen    (pht_wen), 
    .pht_wdata  (pht_wdata), 
    .glob_reg_en (glob_reg_en), 
    .glob_mux_sel (glob_mux_sel)
  );


endmodule

module lab4_branch_BranchGlobal_Ctrl 
(
  input  logic       clk, 
  input  logic       reset, 

  input  logic [1:0] rdata, 

  input  logic       update_en, 
  input  logic       update_val, 

  output logic       pht_wen, 
  output logic [1:0] pht_wdata, 
  output logic       glob_reg_en, 
  output logic       glob_mux_sel
);
  
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

  assign pht_wen = update_en; 
  assign glob_mux_sel = !reset; 
  assign glob_reg_en = reset || update_en; 
  
endmodule


module lab4_branch_BranchGlobal_DPath 
#(
  parameter PHT_size = 2048, 

  parameter c_addr_nbits  = $clog2(PHT_size)
)
(
  input logic         clk, 
  input logic         reset, 
  input logic         update_val,

  input logic         pht_wen, 
  input logic  [ 1:0] pht_wdata, 
  input logic         glob_reg_en, 
  input logic         glob_mux_sel, 

  input logic  [31:0] PC, 

  output logic [ 1:0] rdata, 
  output logic        prediction 

);
  
  logic [c_addr_nbits-1:0] next_glob; 

  logic [c_addr_nbits-1:0] index; 
  vc_EnResetReg #(c_addr_nbits) glob_reg 
  (
    .clk (clk), 
    .reset (reset), 
    .d    ( next_glob ), 
    .q    ( index ), 
    .en   ( glob_reg_en ) 
  );

  logic [c_addr_nbits-2:0] extender; // line not coverable as it's hardcoded to 0; meant for zero-extension
  assign extender = 0; 

  assign next_glob = ( index << 1 ) + {extender, update_val}; 

  
  vc_ResetRegfile_1r1w #(2, PHT_size) pht
  (
    .clk(clk), 
    .reset(reset), 

    .read_addr(index),
    .read_data(rdata),
    .write_en(pht_wen),
    .write_addr(index),
    .write_data(pht_wdata)
  );


  assign prediction = rdata[1]; 

endmodule

`endif
