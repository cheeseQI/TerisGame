module scoreDelay(score_in, score_out, reset, wren, clk);

output reg [31:0] score_out;
input [31:0] score_in;
input reset, clk, wren;

initial 
begin
	score_out <= 31'd0;
end

always @(posedge clk) begin
	if (~reset) begin
		score_out <= 31'd0;
	end else if (wren) begin
		score_out <= score_in;
	end
end

endmodule
