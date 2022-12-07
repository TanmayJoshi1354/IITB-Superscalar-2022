library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder is
	port(
		a: in std_logic_vector(15 downto 0);
		b: in std_logic_vector(15 downto 0);
		
		op: out std_logic_vector(15 downto 0)
	);
end adder;

architecture a1 of adder is

begin
	op<=std_logic_vector(unsigned(a)+unsigned(b))(15 downto 0);
end a1;