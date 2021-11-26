LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

-- Top-level entity for the Duke 550 processor system
-- Author unknown, for Duke ECE550
-- Updated Fall 2016 by Tyler Bletsch

ENTITY skeleton IS
	PORT (inclock, resetn, ps2_clock, ps2_data	: IN STD_LOGIC;
			VGA_R, VGA_G, VGA_B: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC: OUT STD_LOGIC
			);
END skeleton;

ARCHITECTURE Structure OF skeleton IS
	SIGNAL VGA_CLK, VGA_CTRL_CLK, AUD_CTRL_CLK, DLY_RST: STD_LOGIC;
	SIGNAL block_type : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL block_idx : STD_LOGIC_VECTOR(18 DOWNTO 0);
	SIGNAL vga_wren, block_wren : STD_LOGIC;
	SIGNAL ps2_acknowledge	: STD_LOGIC;
	SIGNAL ps2_ascii	: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL clock	: STD_LOGIC;
	SIGNAL random_data : STD_LOGIC_VECTOR(31 DOWNTO 0) ;
	--SIGNAL flag	: STD_LOGIC;
	
	COMPONENT vga_controller IS
		PORT (	iRST_n : IN STD_LOGIC;
                      iVGA_CLK : IN STD_LOGIC;
                      oBLANK_n : OUT STD_LOGIC;				 
                      oHS : OUT STD_LOGIC;
                      oVS : OUT STD_LOGIC;							 
                      b_data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
                      g_data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
                      r_data	: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
							 block_type : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
							 block_idx : IN STD_LOGIC_VECTOR(18 DOWNTO 0);
							 vga_wren : IN STD_LOGIC;
							 write_clk : IN STD_LOGIC;
							 block_wren : IN STD_LOGIC);			
	END COMPONENT;
	COMPONENT ps2 IS
		PORT (	clock, reset, acknowledge, ps2_clock, ps2_data	: IN STD_LOGIC;
				output	: OUT STD_LOGIC_VECTOR(8 DOWNTO 0) );
	END COMPONENT;
	COMPONENT processor IS
		PORT (	clock, reset	: IN STD_LOGIC;
				keyboard_in	: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
				keyboard_ack: OUT STD_LOGIC; --delete score_write	
				--score_data	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
				block_type : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
				block_idx : OUT STD_LOGIC_VECTOR(18 DOWNTO 0);
				vga_wren : OUT STD_LOGIC;
				block_wren : OUT STD_LOGIC;
				random_data: IN STD_LOGIC_VECTOR(31 DOWNTO 0));
	END COMPONENT;
	COMPONENT vga_audio_pll IS 
		PORT ( areset: IN STD_LOGIC;
		inclk0 : IN STD_LOGIC;
		c0,	c1,	c2: OUT STD_LOGIC);
	END COMPONENT;
	COMPONENT Reset_Delay IS
		PORT (	iCLK	: IN STD_LOGIC;
				oRESET	: OUT STD_LOGIC);
	END COMPONENT;
	COMPONENT pll IS
		PORT (	inclk0	: IN STD_LOGIC;
				c0	: OUT STD_LOGIC);
	END COMPONENT;
	COMPONENT random_generator IS
		PORT (	clk : IN STD_LOGIC;
					data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
	END COMPONENT;
	SIGNAL reset : STD_LOGIC;
BEGIN
	--clock divider
	div:	pll PORT MAP (inclock, clock);
	--clock <= inclock;

	-- your processor
	reset <= NOT resetn;
	myprocessor: processor PORT MAP (clock, reset, ps2_ascii, ps2_acknowledge, block_type, block_idx, vga_wren, block_wren, random_data);

	-- keyboard controller
	myps2:	ps2 PORT MAP (clock, reset, ps2_acknowledge, ps2_clock, ps2_data, ps2_ascii(8 DOWNTO 0));
	ps2_ascii(31 DOWNTO 9) <= (OTHERS => '0');
	
	--vga part
	myreset: Reset_Delay PORT MAP (inclock, DLY_RST); --default??what used for ??
	mypll: vga_audio_pll PORT MAP( NOT DLY_RST, inclock, VGA_CTRL_CLK, AUD_CTRL_CLK, VGA_CLK);
	myvga: vga_controller PORT MAP (DLY_RST,
								 VGA_CLK,
								 VGA_BLANK,
								 VGA_HS,
								 VGA_VS,
								 VGA_B(7 DOWNTO 0),
								 VGA_G(7 DOWNTO 0),
								 VGA_R(7 DOWNTO 0),
								 block_type,
								 block_idx,
								 vga_wren,
								 NOT clock,
								 block_wren);
								 
	
		-- random number generator?? how can achive??
	myrandom_generator: random_generator PORT MAP (inclock, random_data);
END Structure;