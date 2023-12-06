`ifndef REGS_V
`define REGS_V

module enResetReg
#(
  parameter p_nbits       = 1,
  parameter p_reset_value = 0
)(
  input  logic               clk,   // Clock input
  input  logic               reset, // Sync reset input
  output logic [p_nbits-1:0] q,     // Data output
  input  logic [p_nbits-1:0] d,     // Data input
  input  logic               en     // Enable input
);

  always_ff @( posedge clk )
    if ( reset || en )
      q <= reset ? p_reset_value : d;

endmodule

`endif /* REGS_V */

