library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity splitter is
port(clock: in std_logic;
	  reset: in std_logic;
	  instruction: in std_logic_vector(163 downto 0);
	  --155-148: 8bits, 147-144: opcode, 143-0: RA, R7,R6,R5,R4,R3,R2,R1,R0
	  Iout1,Iout2,Iout3,Iout4,Iout5,Iout6,Iout7,Iout0: out std_logic_vector(43 downto 0);
	  N: out integer);
end entity splitter;

architecture split of splitter is 

begin

splitting: process(instruction, clock)

variable n: integer := 0;
begin
if(clock'event and clock ='1') then
	if(instruction(147 downto 146) = "11") then
		if(instruction(148) = '1') then
			Iout0(43 downto 42) <= "01";
			Iout0(41 downto 40) <= Instruction(145 downto 144);
			Iout0(39 downto 24) <= Instruction(15 downto 0);
			Iout0(23 downto 23) <= instruction(156 downto 156);
			Iout0(22 downto 7) <= Instruction(143 downto 128);
			Iout0(6 downto 6) <= "1";
			Iout0(5 downto 0) <= "000000";
		else 
			Iout0 <= (others => 'Z');
		end if;
		
		if(instruction(149) = '1') then
			Iout1(43 downto 42) <= "01";
			Iout1(41 downto 40) <= Instruction(145 downto 144);
			Iout1(39 downto 24) <= Instruction(31 downto 16);
			Iout1(23 downto 23) <= instruction(157 downto 157);
			Iout1(22 downto 7) <= Instruction(143 downto 128);
			Iout1(6 downto 6) <= "1";
			Iout1(5 downto 0) <= "000001";
		else 
			Iout1 <= (others => 'Z');
		end if;
		
		if(instruction(150) = '1') then
			Iout2(43 downto 42) <= "01";
			Iout2(41 downto 40) <= Instruction(145 downto 144);
			Iout2(39 downto 24) <= Instruction(47 downto 32);
			Iout2(23 downto 23) <= instruction(158 downto 158) ;
			Iout2(22 downto 7) <= Instruction(143 downto 128);
			Iout2(6 downto 6) <= "1";
			Iout2(5 downto 0) <= "000010";
		else 
			Iout2 <= (others => 'Z');
		end if;
		
		if(instruction(151) = '1') then
			Iout3(43 downto 42) <= "01";
			Iout3(41 downto 40) <= Instruction(145 downto 144);
			Iout3(39 downto 24) <= Instruction(63 downto 48);
			Iout3(23 downto 23) <= instruction(159 downto 159);
			Iout3(22 downto 7) <= Instruction(143 downto 128);
			Iout3(6 downto 6) <= "1";
			Iout3(5 downto 0) <= "000011";
		else 
			Iout3 <= (others => 'Z');
		end if;
		
		if(instruction(152) = '1') then
			Iout4(43 downto 42) <= "01";
			Iout4(41 downto 40) <= Instruction(145 downto 144);
			Iout4(39 downto 24) <= Instruction(79 downto 64);
			Iout4(23 downto 23) <= instruction(160 downto 160);
			Iout4(22 downto 7) <= Instruction(143 downto 128);
			Iout4(6 downto 6) <= "1";
			Iout4(5 downto 0) <= "000100";
		else 
			Iout4 <= (others => 'Z');
		end if;
		
		if(instruction(153) = '1') then
			Iout5(43 downto 42) <= "01";
			Iout5(41 downto 40) <= Instruction(145 downto 144);
			Iout5(39 downto 24) <= Instruction(95 downto 80);
			Iout5(23 downto 23) <= instruction(161 downto 161);
			Iout5(22 downto 7) <= Instruction(143 downto 128);
			Iout5(6 downto 6) <= "1";
			Iout5(5 downto 0) <= "000101";
		else 
			Iout5 <= (others => 'Z');
		end if;
		
		if(instruction(154) = '1') then
			Iout6(43 downto 42) <= "01";
			Iout6(41 downto 40) <= Instruction(145 downto 144);
			Iout6(39 downto 24) <= Instruction(111 downto 96);
			Iout6(23 downto 23) <= instruction(162 downto 162);
			Iout6(22 downto 7) <= Instruction(143 downto 128);
			Iout6(6 downto 6) <= "1";
			Iout6(5 downto 0) <= "000110";
		else 
			Iout6 <= (others => 'Z');
		end if;
		
		if(instruction(155) = '1') then
			Iout7(43 downto 42) <= "01";
			Iout7(41 downto 40) <= Instruction(145 downto 144);
			Iout7(39 downto 24) <= Instruction(127 downto 112);
			Iout7(23 downto 23) <= instruction(163 downto 163);
			Iout7(22 downto 7) <= Instruction(143 downto 128);
			Iout7(6 downto 6) <= "1";
			Iout7(5 downto 0) <= "000111";
		else
			Iout7 <= (others => 'Z');
		end if;
		
		for i in 0 to 7 loop
			if(instruction(148 + i) = '1') then
				n := n+1;
			end if;
		end loop;
		
		N := n;
		
		
	end if;
end if;
end process;	
end architecture split;