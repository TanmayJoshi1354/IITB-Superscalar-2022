library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity AGMA_reg is
	port(
		clk: in std_logic;
		clr: in std_logic;
		wr: in std_logic;
		inst_num_in: in std_logic_vector(6 downto 0);
		mem_addr_in: in std_logic_vector(15 downto 0);
		inst_opcode_in: in std_logic_vector(3 downto 0);
		data_in: in std_logic_vector(15 downto 0);
		
		inst_num_out: out std_logic_vector(6 downto 0);
		mem_addr_out: out std_logic_vector(15 downto 0);
		inst_opcode_out: out std_logic_vector(3 downto 0);
		data_out: out std_logic_vector(15 downto 0)
	);
end AGMA_reg;

architecture r1 of AGMA_reg is
begin
process(clk, clr)
begin
	if(clr='1') then
		inst_num_out<=(others=>'0');
		mem_addr_out<=(others=>'0');
		inst_opcode_out<="0000";
		data_out<=(others=>'0');
	elsif rising_edge(clk) then
		if(wr='1') then
			inst_num_out<=inst_num_in;
			mem_addr_out<=mem_addr_in;
			inst_opcode_out<=Inst_opcode_in;
			data_out<=data_in;
		end if;
	end if;
end process;
end r1;