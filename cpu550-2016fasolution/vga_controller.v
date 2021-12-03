module vga_controller(iRST_n,
                      iVGA_CLK,
                      oBLANK_n,
                      oHS,
                      oVS,
                      b_data,
                      g_data,
                      r_data,
							 move_ctrl
							 );

	
input iRST_n;
input iVGA_CLK;
/************/
input [3:0] move_ctrl;  // move control
/***********/
output reg oBLANK_n;
output reg oHS;
output reg oVS;
output [7:0] b_data;
output [7:0] g_data;  
output [7:0] r_data;                        
///////// ////                     
reg [18:0] ADDR;
reg [23:0] bgr_data;
wire VGA_CLK_n;
wire [7:0] index;
wire [23:0] bgr_data_raw;
wire cBLANK_n,cHS,cVS,rst;

// x_axis & y_axis are the x,y coordinate of left-top point of the square
reg [9:0] x_axis;
reg [9:0] y_axis;

// control delay
wire delay_cnt;

// real address
reg [18:0] true_addr;

// transfrom ADDR to x and y in axis
reg [9:0] ADDR_x;
reg [9:0] ADDR_y;

////
assign rst = ~iRST_n;
video_sync_generator LTM_ins (.vga_clk(iVGA_CLK),
                              .reset(rst),
                              .blank_n(cBLANK_n),
                              .HS(cHS),
                              .VS(cVS));
////
////Addresss generator
always@(posedge iVGA_CLK,negedge iRST_n)
begin
  if (!iRST_n)
     ADDR<=19'd0;
  else if (cHS==1'b0 && cVS==1'b0)
     ADDR<=19'd0;
  else if (cBLANK_n==1'b1)
  begin
     ADDR<=ADDR+1;
	  ADDR_y = ADDR / 640;
	  ADDR_x = ADDR % 640;
	  if (ADDR_x >= x_axis && ADDR_x <= x_axis+20 && ADDR_y >= y_axis && ADDR_y <= y_axis+100) begin
		true_addr <= 19'b000_0000_0000_0000_0010;
	  end
	  else begin
		if (ADDR_y < 240) begin
			true_addr <= 19'b000_0000_0000_0000_0000;
		end
		else begin
		true_addr <= 19'b000_0000_0000_0000_0001;
		end
	  end
  end
end

vga_counter c1(iVGA_CLK, delay_cnt);
//////////////////////////
//////INDEX addr.
assign VGA_CLK_n = ~iVGA_CLK;
img_data	img_data_inst (
	.address ( true_addr ),
	.clock ( VGA_CLK_n ),
	.q ( index )
	);
	
/////////////////////////
/////switch input for the block 

always@(posedge delay_cnt)
begin
	//The automatic falling for the block
	if(y_axis + 20 < 479) begin
		y_axis <= y_axis + 4;
	end
	
	//Moving the block right and left
	 case(move_ctrl)
		4'b0111:
		if(y_axis > 0) begin
			y_axis <= y_axis - 4;
		end
		4'b1011:
		if(y_axis+20 < 480) begin
			y_axis <= y_axis + 4;
		end
		4'b1101:
		if(x_axis > 0 ) begin
			x_axis <= x_axis - 4;
		end
		4'b1110:
		if(x_axis+20 < 640) begin
			x_axis <= x_axis + 4;
		end
		default:;
	endcase
end

//////Color table output
img_index	img_index_inst (
	.address ( index ),
	.clock ( iVGA_CLK ),
	.q ( bgr_data_raw)
	);	
//////
//////latch valid data at falling edge;
always@(posedge VGA_CLK_n) bgr_data <= bgr_data_raw;
assign b_data = bgr_data[23:16];
assign g_data = bgr_data[15:8];
assign r_data = bgr_data[7:0]; 
///////////////////
//////Delay the iHD, iVD,iDEN for one clock cycle;
always@(negedge iVGA_CLK)
begin
  oHS<=cHS;
  oVS<=cVS;
  oBLANK_n<=cBLANK_n;
end

endmodule
 	















