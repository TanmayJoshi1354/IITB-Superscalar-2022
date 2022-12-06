--------------------------------------------------------------------------
--IITB-Superscalar
--Author: Tanmay Joshi
--Module: Decoder
--Date: 5/12/22
--------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Decoder is 
port(I1in, I2in: in std_logic_vector(15 downto 0);
	  Clock: in std_logic;
	  I1_decoded_out, I2_decoded_out: out std_logic_vector(46 downto 0);
	  Opr1_I1, Opr1_I2, Opr2_I1, Opr2_I2: in std_logic_vector(15 downto 0);
	  Dest_I1, Dest_I2: in std_logic_vector(5 downto 0)
	  I1V1,I1V2,I2V1,I2V2: in std_logic;
	  );
end entity Decoder;

architecture decode of Decoder is

component SE is
port(SE_in: std_logic_vector(5 downto 0);
	  SE_out: std_logic_vector(15 downto 0));
end component SE;

begin

I1_decoded_out(46 downto 43) <= I1in(15 downto 11);
I1_decoded_out(42 downto 27) <= Opr1_I1;
I1_decoded_out(26 downto 11) <= Opr2_I1;
I1_decoded_out(10 downto 10) <= I1V1;
I1_decoded_out(9 downto 9) <= I1V2;  
I1_decoded_out(8 downto 3) <= Dest_I1;
I1_decoded_out(2 downto 2) <= I1in(1 downto 1);
I1_decoded_out(1 downto 1) <= I1in(0 downto 0);
I1_decoded_out(0 downto 0) <= I1in(1 downto 1) && I1in(0 downto 0);

I2_decoded_out(46 downto 43) <= I2in(15 downto 11);
I2_decoded_out(42 downto 27) <= Opr1_I2;
I2_decoded_out(26 downto 11) <= Opr2_I2;
I2_decoded_out(10 downto 10) <= I2V1;
I2_decoded_out(9 downto 9) <= I2V2;  
I2_decoded_out(8 downto 3) <= Dest_I2;
I2_decoded_out(2 downto 2) <= I2in(1 downto 1);
I2_decoded_out(1 downto 1) <= I2in(0 downto 0);
I2_decoded_out(0 downto 0) <= I2in(1 downto 1) && I2in(0 downto 0);

end architecture decode;