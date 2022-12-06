--------------------------------------------------------------------------
--IITB-Superscalar
--Author: Tanmay Joshi
--Module: Instruction buffer
--Date: 5/12/22
--------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Instruction_Buffer is
port(I1_in, I2_in: in std_logic_vector(15 downto 0);
	  Read_EN: in std_logic;
	  I1_out, I2_out: out std_logic_vector(15 downto 0);
	  Write_EN: in std_logic;
	  Clock: in std_logic);
end entity Instruction_Buffer;

architecture buffer1 of Instruction_Buffer is

signal Instructions: std_logic_vector(31 downto 0);

begin

buffer_process: process(clock)	
begin  
if(clock'event and clock = '1') then
	if(Read_EN = '1') then
		Instructions(15 downto 0) <= I1_in;
		Instructions(31 downto 16) <= I2_in;
	end if;
	if(Write_EN = '1') then
		I1_out <= Instructions(15 downto 0);
		I2_out <= Instructions(31 downto 16);
	end if;
end if;
end process Buffer_process;
end architecture buffer1;	