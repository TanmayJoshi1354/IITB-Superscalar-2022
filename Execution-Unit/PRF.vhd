library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;

entity prf is
    port(
	   Add1: in std_logic_vector(2 downto 0);
		Add2: in std_logic_vector(2 downto 0);
		Add3: in std_logic_vector(2 downto 0);
		D3: in std_logic_vector(15 downto 0);
		wr: in std_logic;
		clk: in std_logic;
		clr_rf: in std_logic;
		
		D1: out std_logic_vector(15 downto 0);
		D2: out std_logic_vector(15 downto 0)
		);
end prf;

architecture prf_arch of prf is
	type reg_bank_type is array(63 downto 0) of std_logic_vector(15 downto 0);
	signal busy: std_logic_vector(63 downto 0);
	signal valid: std_logic_vector(63 downto 0);
	signal reg_bank: reg_bank_type := (others=>"0000000000000000");
begin
	process(Add1, Add2, Add3, D3, wr, clk, wr_r7)
	begin
		if rising_edge(clk) then
			if wr='1' then
				reg_bank(to_integer(unsigned(Add3)))<=D3;
			end if;
			if clr_rf='1' then
				reg_bank<=(others=>"0000000000000000");
			end if;
		end if;
	end process;
	D1<=reg_bank(to_integer(unsigned(Add1)));
	D2<=reg_bank(to_integer(unsigned(Add2)));
end prf_arch;