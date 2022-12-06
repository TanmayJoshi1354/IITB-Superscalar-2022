--------------------------------------------------------------------------
--IITB-Superscalar
--Author: Tanmay Joshi
--Module: Shifter
--Date: 6/12/22
--------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shifter is
port(D_in: in std_logic_vector(15 downto 0);
	  D_out: out std_logic_vector(15 downto 0));
end entity shifter;

architecture LeftShift of shifter is
signal mid: std_logic_vector(15 downto 0);
begin

mid(15 downto 1) <= D_in(14 downto 0);
mid(0) <= D_in(15);
D_out<= mid;

end architecture Leftshift;