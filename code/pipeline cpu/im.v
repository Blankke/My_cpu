
// instruction memory
module im1(input  [8:2]  addr,
            output [31:0] dout );

  reg  [31:0] ROM[127:0];


  assign dout = ROM[addr]; // word aligned
endmodule  
