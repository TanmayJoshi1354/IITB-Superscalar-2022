library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;

entity rat is
	port(
		reset: in std_logic;
		I1_src1:in std_logic_vector(2 downto 0);
		I1_src2:in std_logic_vector(2 downto 0);
		I1_dest: in std_logic_vector(2 downto 0);
		I1_dest_rr: in std_logic_vector(5 downto 0);
		I1_wr_dest: in std_logic;
		I2_src1:in std_logic_vector(2 downto 0);
		I2_src2:in std_logic_vector(2 downto 0);
		I2_dest: in std_logic_vector(2 downto 0);
		I2_dest_rr: in std_logic_vector(5 downto 0);
		I2_wr_dest: in std_logic;
		
		lmsm: in std_logic;
		I_opcode: in std_logic_vector(3 downto 0);
		I_opr1_in: in std_logic_vector(5 downto 0);
		I_opr2_in: in std_logic_vector(5 downto 0);
		I_opr3_in: in std_logic_vector(5 downto 0);
		I_opr4_in: in std_logic_vector(5 downto 0);
		I_opr5_in: in std_logic_vector(5 downto 0);
		I_opr6_in: in std_logic_vector(5 downto 0);
		I_opr7_in: in std_logic_vector(5 downto 0);
		I_opr8_in: in std_logic_vector(5 downto 0);
		
		I1_opr1:out std_logic_vector(5 downto 0);
		I1_opr2:out std_logic_vector(5 downto 0);
		I2_opr1:out std_logic_vector(5 downto 0);
		I2_opr2:out std_logic_vector(5 downto 0);
		
		I_opr1: out std_logic_vector(15 downto 0);
		I_opr2: out std_logic_vector(15 downto 0);
		I_opr3: out std_logic_vector(15 downto 0);
		I_opr4: out std_logic_vector(15 downto 0);
		I_opr5: out std_logic_vector(15 downto 0);
		I_opr6: out std_logic_vector(15 downto 0);
		I_opr7: out std_logic_vector(15 downto 0);
		I_opr8: out std_logic_vector(15 downto 0)
		);
end rat;

architecture rat_arch of rat is
	type entry_type is array(7 downto 0) of std_logic_vector(5 downto 0);
	signal table: entry_type;
	
begin
process(reset,I1_wr_dest, I2_wr_dest)
begin
	if(reset='1') then
		init: for k in 0 to 7 loop
			table(k)<=std_logic_vector(to_unsigned(k,6));
		end loop init;
	end if;
	if(lmsm='0') then
		I1_opr1<=table(to_integer(unsigned(I1_src1)));
		I1_opr2<=table(to_integer(unsigned(I1_src2)));
		if(I1_wr_dest='1') then
			table(to_integer(unsigned(I1_dest)))<=I1_dest_rr;
		end if;
		
		I2_opr1<=table(to_integer(unsigned(I2_src1)));
		I2_opr2<=table(to_integer(unsigned(I2_src2)));
		if(I2_wr_dest='1') then
			table(to_integer(unsigned(I2_dest)))<=I2_dest_rr;
		end if;
	else
		if(I_opcode="1100") then
			table(0)<=I_opr1_in;
			table(1)<=I_opr2_in;
			table(2)<=I_opr3_in;
			table(3)<=I_opr4_in;
			table(4)<=I_opr5_in;
			table(5)<=I_opr6_in;
			table(6)<=I_opr7_in;
			table(7)<=I_opr8_in;
		end if;
		I_opr1<=table(0);
		I_opr2<=table(1);
		I_opr3<=table(2);
		I_opr4<=table(3);
		I_opr5<=table(4);
		I_opr6<=table(5);
		I_opr7<=table(6);
		I_opr8<=table(7);
	end if;
end process;
end rat_arch;