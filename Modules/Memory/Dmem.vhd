--------------------------------------------------------------------------
--IITB-Superscalar
--Author: Tanmay Joshi
--Module: Data memory
--Date: 5/12/22
--------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Dmem is
port (clock : in std_logic;
		Write_Enable : in std_logic;
		Read_Enable : in std_logic;
		Write_Address : in std_logic_vector(15 downto 0);
		Read_Address : in std_logic_vector(15 downto 0);
		Write_Data_In : in std_logic_vector(15 downto 0);
		Read_Data_Out : out std_logic_vector(15 downto 0));
end entity Dmem;

architecture memory_arch of Dmem is

	type memory_body is array(65535 downto 0) of std_logic_vector(15 downto 0);
	 
	signal memory_signal : memory_body;

	begin
		
	memory_edit: process(clock)
	begin	
		if(clock'event and clock = '1') then
			if(Write_Enable = '1') then
				memory_signal(to_integer(unsigned(Write_Address))) <= Write_Data_in;
			end if;
			if(Read_Enable = '1') then
				Read_Data_Out <= memory_signal(to_integer(unsigned(Read_Address)));
			else
				Read_Data_Out <= "ZZZZZZZZZZZZZZZZ";
			end if;
		end if;
	end process;
end architecture memory_arch;	
		
				
		