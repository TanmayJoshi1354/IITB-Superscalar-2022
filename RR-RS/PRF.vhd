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
		
		D_in1: in std_logic_vector(15 downto 0);
		Addr_in1: in std_logic_vector(5 downto 0);
		wr1: in std_logic;
		D_in2: in std_logic_vector(15 downto 0);
		Addr_in2: in std_logic_vector(5 downto 0);
		wr2: in std_logic;
		
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
		I2_opr2_v: out std_logic;
		
		lmsm: in std_logic;
		I_opcode: in std_logic_vector(3 downto 0);
		I_addr: in std_logic_vector(47 downto 0);
		v: out std_logic_vector(7 downto 0);
		I_opr: out std_logic_vector(127 downto 0)
		);
end prf;

architecture prf_arch of prf is
	type reg_bank_type is array(63 downto 0) of std_logic_vector(15 downto 0);
	signal valid: std_logic_vector(63 downto 0):=(others=>'0');
	signal reg_bank: reg_bank_type := (others=>"0000000000000000");
begin
	--Write Back
	process(wr1,wr2, clk)
	begin
		if rising_edge(clk) then
			if(wr1='1') then
				reg_bank(to_integer(unsigned(Addr_in1)))<=D_in1;
				valid(to_integer(unsigned(Addr_in1)))<='1';
			end if;
			if(wr2='1') then
				reg_bank(to_integer(unsigned(Addr_in2)))<=D_in2;
				valid(to_integer(unsigned(Addr_in2)))<='1';
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
	
	I_opr(15 downto 0)<=reg_bank(to_integer(unsigned(I_addr(5 downto 0))));
	v(0)<=valid(to_integer(unsigned(I_addr(5 downto 0))));
	I_opr(31 downto 16)<=reg_bank(to_integer(unsigned(I_addr(11 downto 6))));
	v(1)<=valid(to_integer(unsigned(I_addr(11 downto 6))));
	I_opr(47 downto 32)<=reg_bank(to_integer(unsigned(I_addr(17 downto 12))));
	v(2)<=valid(to_integer(unsigned(I_addr(17 downto 12))));
	I_opr(63 downto 48)<=reg_bank(to_integer(unsigned(I_addr(23 downto 18))));
	v(3)<=valid(to_integer(unsigned(I_addr(23 downto 18))));
	I_opr(79 downto 64)<=reg_bank(to_integer(unsigned(I_addr(29 downto 24))));
	v(4)<=valid(to_integer(unsigned(I_addr(29 downto 24))));
	I_opr(95 downto 80)<=reg_bank(to_integer(unsigned(I_addr(35 downto 30))));
	v(5)<=valid(to_integer(unsigned(I_addr(35 downto 30))));
	I_opr(111 downto 96)<=reg_bank(to_integer(unsigned(I_addr(41 downto 36))));
	v(6)<=valid(to_integer(unsigned(I_addr(41 downto 36))));
	I_opr(127 downto 112)<=reg_bank(to_integer(unsigned(I_addr(47 downto 42))));
	v(7)<=valid(to_integer(unsigned(I_addr(47 downto 42))));
	
	--Update valid bit
	process(I1_wr_dest, I2_wr_dest)
	begin
		if(I1_wr_dest='1') then
			valid(to_integer(unsigned(I1_dest_rr)))<='0';
		end if;
		if(I2_wr_dest='1') then
			valid(to_integer(unsigned(I2_dest_rr)))<='0';
		end if;
		if(lmsm='1' and I_opcode="1100") then
			valid(to_integer(unsigned(I_addr(5 downto 0))))<='0';
			valid(to_integer(unsigned(I_addr(11 downto 6))))<='0';
			valid(to_integer(unsigned(I_addr(17 downto 12))))<='0';
			valid(to_integer(unsigned(I_addr(23 downto 18))))<='0';
			valid(to_integer(unsigned(I_addr(29 downto 24))))<='0';
			valid(to_integer(unsigned(I_addr(35 downto 30))))<='0';
			valid(to_integer(unsigned(I_addr(41 downto 36))))<='0';
			valid(to_integer(unsigned(I_addr(47 downto 42))))<='0';
		end if;
	end process;
end prf_arch;