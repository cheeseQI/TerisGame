module random_generator(
  input  clk,
  output reg [31:0] data
);

reg [31:0] internaldata;
wire feedback = internaldata[4] ^ internaldata[1];

always @(posedge clk)
	data <= internaldata % 32'd5;

initial begin
	internaldata <= {27'h0000000, 4'hf};
end

always @(posedge clk)
	internaldata <= {27'b0, internaldata[3:0], feedback} ;
	
endmodule