//=========================================================================
// Branch Predictor Bimodal Design
//=========================================================================

`ifndef LAB4_BRANCH_BRANCH_BIMODAL_V
`define LAB4_BRANCH_BRANCH_BIMODAL_V

`include "vc/mem-msgs.v"
`include "vc/queues.v"
`include "vc/trace.v"
`include "vc/regfiles.v"

module lab4_branch_BranchBimodal
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

  logic pht_wen; 
  logic [1:0] pht_wdata; 
  logic [1:0] rdata; 

  lab4_branch_BranchBimodal_DPath #(PHT_size) dpath
  (
    .clk       (clk), 
    .reset     (reset), 
    .pht_wen   (pht_wen), 
    .pht_wdata (pht_wdata), 
    .PC        (PC), 
    .rdata     (rdata), 
    .prediction(prediction)   
  ); 

  lab4_branch_BranchBimodal_Ctrl ctrl 
  (
    .clk        (clk), 
    .reset      (reset), 
    .rdata      (rdata), 
    .update_en  (update_en), 
    .update_val (update_val), 
    .pht_wen    (pht_wen), 
    .pht_wdata  (pht_wdata)
  );


endmodule

module lab4_branch_BranchBimodal_Ctrl 
(
  input  logic       clk, 
  input  logic       reset, 

  input  logic [1:0] rdata, 

  input  logic       update_en, 
  input  logic       update_val, 
  output logic       pht_wen, 
  output logic [1:0] pht_wdata
);
  
  localparam pred_state = 1'd0; 
  localparam update_state = 1'd1; 

  logic state; 
  logic next_state; 

  always_ff @(posedge clk) begin 
    if ( reset ) begin 
      state <= pred_state; 
    end 
    else begin 
      state <= next_state; 
    end
  end


  always_comb begin 
    if ( update_en ) begin 
      next_state = update_state; 
    end else begin 
      next_state = pred_state; 
    end
  end

  always_comb begin 
    if ( update_en ) begin 
      pht_wen = 1'd1; 
      
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
      pht_wen = 1'd0; 
      pht_wdata = 2'hx; 
    end 
  end
  
endmodule


module lab4_branch_BranchBimodal_DPath 
#(
  parameter PHT_size = 2048, 

  parameter c_addr_nbits  = $clog2(p_num_entries)
)
(
  input logic         clk, 
  input logic         reset, 
  input logic         pht_wen, 
  input logic  [ 1:0] pht_wdata, 

  input logic  [31:0] PC, 

  output logic [ 1:0] rdata, 
  output logic        prediction 

);
  
  // segmenting PC to extract index 
  logic [c_addr_nbits-1:0] index; 
  assign index = PC[c_addr_nbits+1:2]; 
  
  vc_Regfile_1r1w #(2, PHT_size) pht
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
