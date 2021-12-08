module	delay_latch(iCLK,oRESET);
input		iCLK;
output reg	oRESET;
reg	[19:0]	Cont;

always@(posedge iCLK)
begin
	if(Cont!=20'hFFFFF)
	begin
		Cont	<=	Cont+20'd1; 
		oRESET	<=	1'b0;
	end
	else
	oRESET	<=	1'b1;
end

endmodule
