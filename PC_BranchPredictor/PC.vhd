library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity program_counter is
	port (
		clk, rst, pc_en, b_pred: in std_logic;
		instr: in std_logic_vector(15 downto 0);
		pc_in: in std_logic_vector(15 downto 0);
		addr_in: in std_logic_vector(15 downto 0);
		pc_out: out std_logic_vector(15 downto 0)
	);
end program_counter;

architecture behav of program_counter is
begin
	process (clk,rst,pc_en,b_pred,pc_in,instr)
	begin
		if clk'event and clk = '1' then 
		   if rst = '1' then
				pc_out <= (others => '0');
			elsif pc_en = '1' then
				if b_pred= '1' then
					pc_out <= addr_in;
				elsif (instr(15 downto 12) = "1001" or instr(15 downto 12) = "1011") then
					pc_out <= std_logic_vector(unsigned(pc_in)+unsigned(instr(8 downto 0)));
				else
					pc_out <= std_logic_vector(unsigned(pc_in)+ 2);
				end if;
		    else
				pc_out <= pc_in;
			end if;
		end if;
	end process;
end behav;