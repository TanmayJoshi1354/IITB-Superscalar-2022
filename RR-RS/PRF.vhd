library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;

entity prf is
    port(
		clk: in std_logic;
		clr_prf: in std_logic;
	   I1_Add1: in std_logic_vector(5 downto 0);
		I1_Add2: in std_logic_vector(5 downto 0);
		I2_Add1: in std_logic_vector(5 downto 0);
		I2_Add2: in std_logic_vector(5 downto 0);
		D_in: in std_logic_vector(15 downto 0);
		Addr_in: in std_logic_vector(5 downto 0);
		wr: in std_logic;
		
		I1_wr_dest: in std_logic;
		I1_dest_rr: in std_logic_vector(5 downto 0);
		I2_wr_dest: in std_logic;
		I2_dest_rr: in std_logic_vector(5 downto 0);		
		
		I1_opr1: out std_logic_vector(15 downto 0);
		I1_opr1_v: out std_logic;
		I1_opr2: out std_logic_vector(15 downto 0);
		I1_opr2_v: out std_logic;
		I2_opr1: out std_logic_vector(15 downto 0);
		I2_opr1_v: out std_logic;
		I2_opr2: out std_logic_vector(15 downto 0);
		I2_opr2_v: out std_logic
		);
end prf;

architecture prf_arch of prf is
	type reg_bank_type is array(63 downto 0) of std_logic_vector(15 downto 0);
	signal valid: std_logic_vector(63 downto 0):=(others=>'0');
	signal reg_bank: reg_bank_type := (others=>"0000000000000000");
begin
	--Write Back
	process(wr, clk)
	begin
		if rising_edge(clk) then
			if(wr='1') then
				reg_bank(to_integer(unsigned(Addr_in)))<=D_in;
				valid(to_integer(unsigned(Addr_in)))<='1';
			end if;
		end if;
	end process;
	
	--Read operand renamed regsiter
	I1_opr1<=reg_bank(to_integer(unsigned(I1_Add1)));
	I1_opr1_v<=valid(to_integer(unsigned(I1_Add1)));
	I1_opr2<=reg_bank(to_integer(unsigned(I1_Add2)));
	I1_opr2_v<=valid(to_integer(unsigned(I1_Add2)));
	
	I2_opr1<=reg_bank(to_integer(unsigned(I2_Add1)));
	I2_opr1_v<=valid(to_integer(unsigned(I2_Add1)));
	I2_opr2<=reg_bank(to_integer(unsigned(I2_Add2)));
	I2_opr2_v<=valid(to_integer(unsigned(I2_Add2)));
	
	--Update valid bit
	process(I1_wr_dest, I2_wr_dest)
	begin
		if(I1_wr_dest='1') then
			valid(to_integer(unsigned(I1_dest_rr)))<='0';
		end if;
		if(I2_wr_dest='1') then
			valid(to_integer(unsigned(I2_dest_rr)))<='0';
		end if;
	end process;
end prf_arch;