library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller is
	port(
		I1_opcode_decode: in std_logic_vector(3 downto 0);
		I2_opcode_decode: in std_logic_vector(3 downto 0);
		I1_opcode_alu: in std_logic_vector(3 downto 0);
		I2_opcode_alu: in std_logic_vector(3 downto 0);
		match_branch: in std_logic;
		
		rst, wr_PC, wr_fetch, wr_dispatch, wr_rs, wr_ls_reg, wr_rob, clr_rs_br, clr_rob_br, clr_dispatch, clr_fetch, clr_ls_reg: out std_logic;
	);
end controller;

architecture c1 of controller is
begin
process(I1_opcode_decode, I2_opcode_decode, I1_opcode_alu, I2_opcode_alu, match_branch)
begin
	if(match_branch='0') then
		wr_fetch<='0';
		wr_dispatch<='0';
		wr_rs<='0';
		wr_ls_reg<='0';
		wr_rob<='0';
		clr_rs_br<='1';
		clr_rob_br<='1';
		clr_dispatch<='1';
		clr_fetch<='1';
		clr_ls_reg<='1';
	end if;
	if(I1_opcode_decode="1001" or I2_opcode_decode="1001") then
		wr_PC<='0';
		wr_fetch<='0';
	end if;
	if(I1_opcode_decode="1011" or I1_opcode_decode="1010" or I2_opcode_decode="1011" or I2_opcode_decode="1010") then
		wr_fetch<='0';
		wr_dispatch<='0';
		wr_rs<='0';
	end if;
end process;
end c1;