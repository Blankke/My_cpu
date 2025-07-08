
// instruction memory
module im1(input  [11:2]  addr,
            output [31:0] dout );

  reg  [31:0] ROM[1023:0];


  assign dout = ROM[addr]; // word aligned
endmodule  
