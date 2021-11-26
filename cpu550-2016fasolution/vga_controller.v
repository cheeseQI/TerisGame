module vga_controller(iRST_n,
                      iVGA_CLK,
                      oBLANK_n,
                      oHS,
                      oVS,
                      b_data,
                      g_data,
                      r_data,
							 block_type,
							 block_idx,
							 vga_wren,
							 write_clk, //just inverse clock of the processor!why it works??
							 block_wren);
input iRST_n;
input iVGA_CLK;
input block_wren;
input [1:0] block_type; //block valid bit, should be set in MIPS; 00->none, 01->has, 11->stuck(only check for first bit to scan!(1->valid))
input [7:0] block_idx;//充当一个idx of block(10*20)
input write_clk;
input vga_wren;
output reg oBLANK_n;
output reg oHS;
output reg oVS;
output [7:0] b_data;
output [7:0] g_data;  
output [7:0] r_data;                        
////////////////////
reg [7:0] block_write_idx; 	//set block property(0-none, 1-has)
reg [7:0] block_read_idx;  //read block 
reg [199:0] block_data; //20 * 10  blocks           
reg [18:0] ADDR; //scan 640*480=307 200
reg [23:0] bgr_data;
wire [7:0] index;
wire [23:0] bgr_data_raw;
wire cBLANK_n,cHS,cVS,rst;
wire block_wrin;
wire VGA_CLK_n;
////
assign rst = ~iRST_n;
video_sync_generator LTM_ins (.vga_clk(iVGA_CLK), //what is sync_generator????????
                              .reset(rst),
                              .blank_n(cBLANK_n),
                              .HS(cHS),
                              .VS(cVS));

//Addresss generator; use for scanning process
always@(posedge iVGA_CLK,negedge iRST_n)
begin
  if (!iRST_n)
     ADDR=19'd0;
  else if (cHS==1'b0 && cVS==1'b0)
     ADDR=19'd0;
  else if (cBLANK_n==1'b1) begin
     ADDR=ADDR+19'd1;
  end
end


always@(posedge VGA_CLK_n) //Update block data according to vga clock
begin //there are 200 blocks, so block_data[]
  block_data[block_write_idx] = block_wrin;   //for(){ block_data[block_index] = block_wrin; block_index ++; block_wrin = new_block_wrin}
  if (block_write_idx == 8'd199) 
	  block_write_idx = 8'd0;
  else
     block_write_idx = block_write_idx + 8'd1;
end

/**
*Block.mif support both read & write at different clock base!
*1.write 1/0 into specify block at block address(block_write_idx)
*2.read data at block address(block_read_idx), and get it out(block_wrin) for vga scanning  
*/
blocks blocks_update (
	.data (block_type[0]), 		//1 then exist, 0 then none, write it into .mif block
	.rdaddress (block_read_idx), 
	.rdclock (VGA_CLK_n),   //read clock every scan
	.wraddress (block_write_idx), //in block of workSpace, specify which point will be written
	.wrclock (write_clk),  //write clock every processor clock
	.wren (block_wren),
	.q (block_wrin)
);


assign VGA_CLK_n = ~iVGA_CLK;
/**
*vga_img.mif
*1.only for background! it will mapp to color!
*
*/
background background_update (
	.address (ADDR),
	.clock (VGA_CLK_n),
	.q (index)
	);


integer scanx, scany, blockX, blockY;// in_blockX, in_blockY; //I delete the value of relative position in one block, it is unneccessary!
localparam upboader = 40; //according to refereced setting, should be changed in the future!!!!!!
localparam downboader = 440;
localparam leftboader = 100;
localparam rightboader = 300;
/*
localparam scoreUp = 90;
localparam scoreDown = 120;
localparam scoreLeft = 460;
localparam scoreRight = 562;
*/
reg [7:0] input_index;
//wire [20:0] score;
//wire [31:0] oscore;
//////switch-input logic
always@(posedge iVGA_CLK)
begin
	scanx = ADDR % 19'd640;
	scany = ADDR / 19'd640;
	if (scanx >= leftboader && scanx < rightboader && scany >= upboader && scany < downboader) 
	begin //in 200 blocks workspace!
		//each block is 20*20 pixel
		blockX = (scanx - leftboader) / 20 + 2; //where does this +2 came from??
		blockY = (scany - upboader) / 20;
		//in_blockX = (scanx - leftboader) % 20; 
		//in_blockY = (scany - upboader) % 20;
		/**** if we have scanned to a pixel located in a specific block, color it!*****/
		/** we have blocks: 10 colums 20 rows, so each line has 10 blocks; in each block, there are 20 pixels in each line*****/
		input_index = block_data[blockX+ blockY*10] ? 8'h101 : index; //if the value of block (block_type[0]) is valid(1), give it index(101) to fffff white color table																														//else give it index of background points to
	end
end



//////Color table output
color_index	color_index_update(
	.address ( input_index ),
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
//////Delay the iHD, iVD,iDEN for one clock scanycle;
always@(negedge iVGA_CLK)
begin
  oHS<=cHS;
  oVS<=cVS;
  oBLANK_n<=cBLANK_n;
end
endmodule
