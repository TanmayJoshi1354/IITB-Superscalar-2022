--------------------------------------------------------------------------
--IITB-Superscalar
--Author: Tanmay Joshi
--Module: Sign extendor
--Date: 5/12/22
--------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SE is
port( SE_in: in std_logic_vector(5 downto 0);
		SE_out: out std_logic_vector(15 downto 0));
end entity SE;

architecture extend of SE is
signal mid: std_logic_vector(15 downto 0);
begin
mid(5 downto 0) <= SE_in;
mid(15 downto 6) <= (others=>'0');
SE_out <= mid;
end architecture extend;