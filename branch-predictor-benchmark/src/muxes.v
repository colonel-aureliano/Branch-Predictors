//========================================================================
// Verilog Components: Muxes
//========================================================================

`ifndef VC_MUXES_V
`define VC_MUXES_V

//------------------------------------------------------------------------
// 2 Input Mux
//------------------------------------------------------------------------

module vc_Mux2
#(
  parameter p_nbits = 1
)(
  input  logic [p_nbits-1:0] in0, in1,
  input  logic               sel,
  output logic [p_nbits-1:0] out
);

  always_comb
  begin
    case ( sel )
      1'd0 : out = in0;
      1'd1 : out = in1;
      default : out = {p_nbits{1'bx}};
    endcase
  end

endmodule

`endif /* VC_MUXES_V */

