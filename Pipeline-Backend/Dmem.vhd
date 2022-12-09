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
		Write_Enable1 : in std_logic;
		Write_Address1 : in std_logic_vector(15 downto 0);
		Read_Address1 : in std_logic_vector(15 downto 0);
		Write_Data_In1 : in std_logic_vector(15 downto 0);
		Read_Data_Out1 : out std_logic_vector(15 downto 0);
		Write_Enable2 : in std_logic;
		Write_Address2 : in std_logic_vector(15 downto 0);
		Read_Address2 : in std_logic_vector(15 downto 0);
		Write_Data_In2 : in std_logic_vector(15 downto 0);
		Read_Data_Out2 : out std_logic_vector(15 downto 0));
end entity Dmem;

architecture memory_arch of Dmem is

	type memory_body is array(65535 downto 0) of std_logic_vector(15 downto 0);
	 
	signal memory_signal : memory_body;

	begin
		
	memory_edit: process(clock)
	begin	
		if(clock'event and clock = '1') then
			if(Write_Enable1 = '1') then
				memory_signal(to_integer(unsigned(Write_Address1))) <= Write_Data_in1;
			end if;
			if(Write_Enable2 = '1') then
				memory_signal(to_integer(unsigned(Write_Address2))) <= Write_Data_in2;
			end if;
		end if;
	end process;
	Read_Data_Out1 <= memory_signal(to_integer(unsigned(Read_Address1)));
	Read_Data_Out2 <= memory_signal(to_integer(unsigned(Read_Address2)));
end architecture memory_arch;	
		
				
		