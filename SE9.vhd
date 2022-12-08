--------------------------------------------------------------------------
--IITB-Superscalar
--Author: Annie D'souza
--Module: Sign extendor - 9 bits to 16 bits
--Date: 8/12/22
--------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SE9 is
port( SE_in: in std_logic_vector(8 downto 0);
		SE_out: out std_logic_vector(15 downto 0));
end entity SE9;

architecture extend of SE9 is
signal mid: std_logic_vector(15 downto 0);
begin
mid(8 downto 0) <= SE_in;
mid(15 downto 9) <= (others=>'0');
SE_out <= mid;
end architecture extend;