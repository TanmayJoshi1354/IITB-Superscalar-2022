library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
end entity testbench;

architecture testing of testbench is

component Imem is
port (clock : in std_logic;
		Write_Enable : in std_logic;
		Read_Enable : in std_logic;
		Write_Address : in std_logic_vector(15 downto 0);
		Read_Address : in std_logic_vector(15 downto 0);
		Write_Data_In : in std_logic_vector(15 downto 0);
		Read_Data_Out_1 : out std_logic_vector(15 downto 0);
		Read_Data_Out_2 : out std_logic_vector(15 downto 0));
end component IMem;

signal clock,Write_Enable,Read_Enable : std_logic;
signal Write_Address, Read_Address, Write_Data_In, Read_Data_Out_1,Read_Data_out_2 : std_logic_vector(15 downto 0);

begin

DUT: Imem port map( clock => clock , Write_Enable => Write_Enable, read_enable => read_enable, read_address => read_address, 
write_address => write_address, write_Data_in => write_data_in , read_data_out_1 => read_data_out_1, read_data_out_2 => read_data_out_2);

clock_process: process
begin
    clock <= '0';
	 wait for 5 ns;
	 clock <= '1';
	 wait for 5 ns;
end process clock_process;

test_process: process
begin
	 write_enable <= '0';
	 read_enable <= '0';
	 wait for 50 ns;
	 wait for 50 ns;
	 write_enable <= '1';
	 write_address <= "0000000000000000";
	 write_data_in <= "1111111111111111";
	 wait for 50 ns;
	 write_address <= "0000000000000001";
	 write_data_in <= "1010101010101010";
	 wait for 50 ns;
	 write_enable <= '0';
	 read_enable <='1';
	 read_address <="0000000000000000";
	 wait for 100 ns;
end process test_process;
end architecture testing;	 
	 