library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;

entity rr_stack is
	port(
		reset: in std_logic;
		I1_dest: in std_logic(2 downto 0);
		I1_wr_dest: in std_logic;
		I2_dest: in std_logic(2 downto 0);
		I2_wr_dest: in std_logic;
		wr_stack: in std_logic;
		completed_rr: in std_logic(5 downto 0);
		
		I1_dest_rr: out std_logic_vector(5 downto 0);
		I2_dest_rr: out std_logic_vector(5 downto 0)
		);
end rr_stack;

architecture stack_arch of rr_stack is
type stack_array is array(63 downto 0) of std_logic_vector(5 downto 0);
signal stack: stack_array:=(others=>(others=>'0'));
signal ptr: integer:=55;

begin
process(reset, I1_wr_dest, I2_wr_dest)
begin
	if(reset='1') then
		init: for k in 0 to 55 loop
			stack(k)<=std_logic_vector(to_unsigned(k+8,6));
		end loop init;
		I1_dest_rr<=(others=>'0');
		I2_dest_rr<=(others=>'0');
	elsif(I1_wr_dest='1' and I2_wr_dest='1') then
		I1_dest_rr<=stack(0);
		I2_dest_rr<=stack(1);
		update2: for k in 0 to 61 loop
			stack(k)<=stack(k+2);
		end loop update2;
		ptr:=ptr-2;
	elsif(I1_wr_dest='1') then
		I1_dest_rr<=stack(0);
		update1: for k in 0 to 62 loop
			stack(k)<=stack(k+1);
		end loop update1;
		ptr:=ptr-1;
	elsif(I2_wr_dest='1') then
		I2_dest_rr<=stack(0);
		update3: for k in 0 to 62 loop
			stack(k)<=stack(k+1);
		end loop update3;
		ptr:=ptr-1;
	end if;
	
	if(wr_stack='1') then
		stack(ptr+1)<=completed_rr;
		ptr:=ptr+1;
	end if;
end process;
end stack_arch;