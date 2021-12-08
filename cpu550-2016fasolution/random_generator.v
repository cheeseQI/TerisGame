//This module takes a clock as input and output the random number

module random_generator(input clk, output reg[31:0] data);
	reg [4:0] b = 5'b01010;
	//LFSR feedback bit
	wire feedback;
	assign feedback = b[0] ^ b[1];
	// Add active low reset to sensitivity list
	always@(posedge clk) begin
			
			b[0] =b[1];
			b[1] =b[2];
			b[2] =b[3];
			b[3] =b[4];
			b[4] =feedback;
			
		   data = {27'b0, b[4:0]};
			data = data % 5'b00101;
 end
	
 endmodule