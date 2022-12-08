library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dispatcher is
port( instruction1, instruction2: in std_logic_vector(46 downto 0);
		outstruction1, outstruction2: out std_logic_vector(53 downto 0);
		clock: in std_logic);
end entity dispatcher;

architecture dispatch of dispatcher is
shared variable counter : integer range 0 to 99 :=0;
signal I1N, I2N: std_logic_vector(6 downto 0);
begin
process_disp: process(instruction1, instruction2,clock)
begin
if(clock'event and clock = '1') then
outstruction1(53 downto 47) <= std_logic_vector(to_unsigned(counter,7));
counter := counter +1;
outstruction1(46 downto 0) <= instruction1;
outstruction2(53 downto 47) <= std_logic_vector(to_unsigned(counter,7));
counter := counter +1;
outstruction2(46 downto 0) <= instruction2;
end if;
end process;
end architecture dispatch;