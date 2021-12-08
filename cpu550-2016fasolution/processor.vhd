-- The core of the Duke 550 processor
-- Author unknown, for Duke ECE550
-- Updated Fall 2016 by Tyler Bletsch

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY processor IS
    PORT (	clock, reset	: IN STD_LOGIC;
			keyboard_in	: IN STD_LOGIC_VECTOR(31 downto 0);
			keyboard_ack, score_write	: OUT STD_LOGIC;
			score_data	: OUT STD_LOGIC_VECTOR(31 downto 0);
			vga_data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); --255 pixel, only for workspace of one block
			vga_addr : OUT STD_LOGIC_VECTOR(18 DOWNTO 0); --(2^19 - 1)=524287 suitable for pixels address; 640*480=307200, for the position that need be changed!
			vga_en : OUT STD_LOGIC; --when do we need to write data into vga ; when sw new value we write it
			block_wren : OUT STD_LOGIC;--when sw is triggered, enable
			random_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0));
END processor;

ARCHITECTURE Structure OF processor IS
	COMPONENT imem IS
		PORT (	address	: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
				clken	: IN STD_LOGIC ;
				clock	: IN STD_LOGIC ;
				q	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0) );
	END COMPONENT;
	COMPONENT dmem IS
		PORT (	address	: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
				clock	: IN STD_LOGIC ;
				data	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
				wren	: IN STD_LOGIC ;
				q	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0) );
	END COMPONENT;
	COMPONENT regfile IS
		PORT (	clock, wren, clear	: IN STD_LOGIC;
				regD, regA, regB	: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
				valD	: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
				valA, valB	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0) );
	END COMPONENT;
	COMPONENT alu IS
		PORT (	A, B	: IN STD_LOGIC_VECTOR(31 DOWNTO 0);	-- 32bit inputs
				op	: IN STD_LOGIC_VECTOR(2 DOWNTO 0);	-- 3bit ALU opcode
				R	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);	-- 32bit output
				isEqual : OUT STD_LOGIC; -- true if A=B
				isLessThan	: OUT STD_LOGIC ); -- true if A<B
	END COMPONENT;
	COMPONENT reg IS
		GENERIC ( n : integer := 32 );
		PORT (	D	: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
				clock, clear, enable	: IN STD_LOGIC;
				Q	: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0) );
	END COMPONENT;
	COMPONENT control IS
		PORT (	op	: IN STD_LOGIC_VECTOR(4 DOWNTO 0);	-- instruction opcode
				reg_wren	: OUT STD_LOGIC;	-- register file write enable
				immed_notRT	: OUT STD_LOGIC;	-- mux select immediate instead of $rt
				rs_zero, rt_zero	: OUT STD_LOGIC;	-- force $rs or $rt to zero
				rd_to_rt	: OUT STD_LOGIC;	-- redirect $rd write register to $rt read register
				ALUopcode	: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);	-- ALU opcode to ALU
				dmem_wren	: OUT STD_LOGIC;	-- data memory write enable
				mem_notALU	: OUT STD_LOGIC;	-- register write data from memory instead of ALU
				branch_equals, branch_greater	: OUT STD_LOGIC;	-- branches
				jump	: OUT STD_LOGIC;	-- jump or jump-and-link
				link	: OUT STD_LOGIC;	-- jump-and-link store PC to $r31
				jump_reg	: OUT STD_LOGIC;	-- return PC from register
				keyboard	: OUT STD_LOGIC;	-- input
				score	: OUT STD_LOGIC);	-- output
	END COMPONENT;
	COMPONENT mux
		GENERIC(n: integer:=16);
		PORT (	A, B	: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
				s	: IN STD_LOGIC;	-- select (NOT A / B)
				F	: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0) );
	END COMPONENT;
	COMPONENT adder_rc
		GENERIC(n: integer:=4);
		PORT (	
			A, B : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
			cin  : IN STD_LOGIC;
			cout : OUT STD_LOGIC;
			sum  : OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0);
			signed_overflow : OUT STD_LOGIC	);
	END COMPONENT;
	
	SIGNAL PC_current, PC_next, PC_PlusoneJump, PC_RegBranch, PC_imem	: STD_LOGIC_VECTOR(11 DOWNTO 0);
	SIGNAL PC_plusone, PC_branch	: STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL insn	: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ctrl_ALUopcode	: STD_LOGIC_VECTOR(2 DOWNTO 0);	-- control ALU opcode
	SIGNAL ctrl_reg_wren, ctrl_immed_notRT, ctrl_rs_zero, ctrl_rt_zero, ctrl_rd_to_rt, mem_wren, ctrl_dmem_notALU, ctrl_branch_equals, ctrl_branch_greater, ctrl_jump, ctrl_link, ctrl_jump_reg, ctrl_keyboard, ctrl_score	: STD_LOGIC;	-- control signals
	SIGNAL ctrl_readRegA, ctrl_readRegB_ZeroRd, ctrl_readRegB, ctrl_writeReg_ZeroLink, ctrl_writeReg	: STD_LOGIC_VECTOR(4 DOWNTO 0);	-- register numbers
	SIGNAL data_readRegA, data_readRegB, data_readRegB_Immed	: STD_LOGIC_VECTOR(31 DOWNTO 0);	-- register read data
	SIGNAL data_writeReg, data_KeyboardLink, data_AluKeyboardLink	: STD_LOGIC_VECTOR(31 DOWNTO 0);	-- register write data
	SIGNAL isEqual, isGreaterThan, branch	: STD_LOGIC;	-- for branch-on-equals and branch-on-greater-than
	SIGNAL data_ALUoutput, data_DMEMoutput	: STD_LOGIC_VECTOR(31 DOWNTO 0);	-- ALU data
	SIGNAL data_trueDMEMoutput : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL msimDummy1, msimDummy2, msimDummy6, msimDummy9, msimDummyClk: STD_LOGIC;
	SIGNAL msimDummy4, msimDummy7, msimDummy8: STD_LOGIC_VECTOR (15 downto 0);
	SIGNAL msimDummy3, msimDummy5: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL msimDummyControl : STD_LOGIC_VECTOR(4 downto 0);
	SIGNAL ctrl_dmem_wren : STD_LOGIC;
	
BEGIN
	msimDummy1 <= ctrl_rd_to_rt OR ctrl_rt_zero;
	msimDummy2 <= ctrl_link OR NOT ctrl_reg_wren;
	msimDummy3 <= insn(16)&insn(16)&insn(16)&insn(16)&insn(16)&insn(16)&insn(16)&insn(16)&insn(16)&insn(16)&insn(16)&insn(16)&insn(16)&insn(16)&insn(16)&insn(16 DOWNTO 0);
	msimDummy4 <= "0000"&PC_current;
	msimDummy5 <= "00000000000000000000"&PC_plusone(11 DOWNTO 0);
	msimDummy6 <= ctrl_link OR ctrl_keyboard;
	msimDummy7 <= "0000"&PC_plusone(11 DOWNTO 0);
	msimDummy8 <= "0000"&insn(11 DOWNTO 0);
	msimDummy9 <= ctrl_jump_reg OR branch;
	msimDummyClk <= NOT clock;
	msimDummyControl <= insn(31 downto 27);
	
	-- FETCH Stage
	fetch1: mux GENERIC MAP (n=>12) PORT MAP (A=>PC_next, B=>"000000000000", s=>reset, F=>PC_imem);	-- ensure that PC_next=0 instead of 1 on reset
	fetch2: reg GENERIC MAP (n=>12) PORT MAP (D=>PC_imem, clock=>clock, clear=>reset, enable=>'1', Q=>PC_current);	-- PC latch
	fetch3: imem PORT MAP (address=>PC_imem, clken=>'1', clock=>clock, q=>insn);	-- instruction memory
	fetch4: adder_rc GENERIC MAP (n=>16) PORT MAP (A=>msimDummy4, B=>"0000000000000001", cin=>'0', sum=>PC_plusone);	-- PC+1
	
	
	-- DECODE Stage
	decode1: control PORT MAP (msimDummyControl, ctrl_reg_wren, ctrl_immed_notRT, ctrl_rs_zero, ctrl_rt_zero, ctrl_rd_to_rt, ctrl_ALUopcode, mem_wren, ctrl_dmem_notALU, ctrl_branch_equals, ctrl_branch_greater, ctrl_jump, ctrl_link, ctrl_jump_reg, ctrl_keyboard, ctrl_score);	-- decode instruction into control signals
	decode2: mux GENERIC MAP (n => 5) PORT MAP (A=>insn(21 DOWNTO 17), B=>"00000", s=>ctrl_rs_zero, F=>ctrl_readRegA);	-- select 0 if regA not used
	decode3: mux GENERIC MAP (n => 5) PORT MAP (A=>"00000", B=>insn(26 DOWNTO 22), s=>ctrl_rd_to_rt, F=>ctrl_readRegB_ZeroRd);	-- select 0 if RegB not used, select RT if special insn
	decode4: mux GENERIC MAP (n => 5) PORT MAP (A=>insn(16 DOWNTO 12), B=>ctrl_readRegB_ZeroRd, s=>msimDummy1, F=>ctrl_readRegB);
	decode5: mux GENERIC MAP (n => 5) PORT MAP (A=>"00000", B=>"11111", s=>ctrl_link, F=>ctrl_writeReg_ZeroLink);	-- select 0 if writeReg not used, select 31 if jump-and-link insn
	decode6: mux GENERIC MAP (n => 5) PORT MAP (A=>insn(26 DOWNTO 22), B=>ctrl_writeReg_ZeroLink, s=>msimDummy2, F=>ctrl_writeReg);
	decode7: regfile PORT MAP (clock=>clock, wren=>ctrl_reg_wren, clear=>reset, regD=>ctrl_writeReg, regA=>ctrl_readRegA, regB=>ctrl_readRegB, valD=>data_writeReg, valA=>data_readRegA, valB=>data_readRegB);	-- register file
	
	-- EXECUTE Stage
	execute01: mux GENERIC MAP (n => 32) PORT MAP (A=>data_readRegB, B=>msimDummy3, s=>ctrl_immed_notRT, F=>data_readRegB_Immed);	-- select between readRegB and immediate for ALU operandB
	execute02: alu PORT MAP (A=>data_readRegA, B=>data_readRegB_Immed, op=>ctrl_ALUopcode, R=>data_ALUoutput, isEqual=>isEqual, isLessThan=>isGreaterThan);	-- Arithmetic Logic Unit (ALU)
	-- ^ note on greater-than/less-than: we provide the bgt operands in opposite order ($rs,$rd), so we're actually checking for LESS THAN
	execute03: score_data <= data_readRegB; score_write <= ctrl_score;	-- LCD output
	execute04: mux GENERIC MAP (n => 32) PORT MAP (A=>keyboard_in, B=>msimDummy5, s=>ctrl_link, F=>data_KeyboardLink);	-- keyboard input or link r31=PC_plusone
	execute05: keyboard_ack <= ctrl_keyboard;	-- keyboard input
	execute06: mux GENERIC MAP (n => 32) PORT MAP (A=>data_ALUoutput, B=>data_KeyboardLink, s=>msimDummy6, F=>data_AluKeyboardLink);	-- select between ALU output data or keyboard/link data for data_writeReg
	execute07: mux GENERIC MAP (n => 12) PORT MAP (A=>PC_plusone(11 DOWNTO 0), B=>insn(11 DOWNTO 0), s=>ctrl_jump, F=>PC_PlusoneJump);	-- jump
	execute08: adder_rc GENERIC MAP (n=>16) PORT MAP (A=>msimDummy7, B=>msimDummy8, cin=>'0', sum=>PC_branch);	-- calculate branch target
	execute09: branch <= (ctrl_branch_equals AND isEqual) OR (ctrl_branch_greater AND isGreaterThan);
	execute10: mux GENERIC MAP (n => 12) PORT MAP (A=>data_readRegB(11 DOWNTO 0), B=>PC_branch(11 DOWNTO 0), s=>branch, F=>PC_RegBranch);	-- branch or return
	execute11: mux GENERIC MAP (n => 12) PORT MAP (A=>PC_PlusoneJump, B=>PC_RegBranch, s=>msimDummy9, F=>PC_next);	-- determine PC_next
	
	-- MEMORY Stage /**changed the memory stage using for stay data! */
	memory1: dmem PORT MAP (address=>data_ALUoutput(11 DOWNTO 0), clock=>msimDummyClk, data=>data_readRegB, wren=>ctrl_dmem_wren, q=>data_trueDMEMoutput);	-- data memory
	vga_data <= data_readRegB(7 DOWNTO 0);
	vga_addr <= data_ALUoutput(18 DOWNTO 0);
	vga_en <= mem_wren AND data_ALUoutput(25); --this port is abandonned , since vga addr is updated auto
	block_wren <= mem_wren AND data_ALUoutput(22);
	ctrl_dmem_wren <= mem_wren AND (NOT data_ALUoutput(25)) AND (NOT data_ALUoutput(22));
	
	-- random data
	random: mux GENERIC MAP (n => 32) PORT MAP (A=>data_trueDMEMoutput, B=>random_data, s=>data_ALUoutput(20), F=>data_DMEMoutput);--if alu[20]==1 then generate new block;else do true mem
	
	-- WRITEBACK Stage
	writeback1: mux GENERIC MAP (n => 32) PORT MAP (A=>data_AluKeyboardLink, B=>data_DMEMoutput, s=>ctrl_dmem_notALU, F=>data_writeReg);	-- select between DMEMoutput or ALUoutput/keyboard/link for data_writeReg
END Structure;