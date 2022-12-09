library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity AL is 
port(instruction: in std_logic_vector(40 downto 0);
	  Inum: in std_logic_vector(6 downto 0);
	  Inumrob: out std_logic_vector(6 downto 0);
	  clock: in std_logic;
	  result: out std_logic_vector(15 downto 0);
	  Carry,Zero: out std_logic;
	  forjlr: out std_logic_VECTOr(15 downto 0));
end entity AL;

architecture lolgic of AL is
component shifter is
port(D_in: in std_logic_vector(15 downto 0);
	  D_out: out std_logic_vector(15 downto 0));
end component shifter;

signal opcode : std_logic_vector(3 downto 0);
signal CZL: std_logic_vector(2 downto 0);
signal C, Z: std_logic;
signal opr1, opr2: std_logic_vector(15 downto 0);
signal shiftin, shiftout: std_logic_vector(15 downto 0);
signal rescarr: std_logic_vector(16 downto 0);
begin

Leftshifter: shifter port map(shiftin, shiftout);

process_AL: process(clock, instruction)
begin

opcode <= instruction(40 downto 37);
C <= instruction(4);
Z <= instruction(3);
CZL <= instruction(2 downto 0);
if(clock'event and clock = '1') then
	if(opcode = "0001") then
		opr1 <= instruction(36 downto 21);
		opr2 <= instruction(20 downto 5);	
		if(CZL = "000") then	
			rescarr <= std_logic_vector(resize((unsigned(opr1) + unsigned(opr2)),17));
			result <= rescarr(15 downto 0);
			Carry <= rescarr(16);
			if(rescarr(15 downto 0)= "0000000000000000") then
				Zero <= '1';
			else
				zero <= '0';
			end if;
		elsif(CZL = "100") then
			if(C = '1') then
				rescarr <= std_logic_vector(resize((unsigned(opr1) + unsigned(opr2)),17));
				result <= rescarr(15 downto 0);
				Carry <= rescarr(16);
				if(rescarr(15 downto 0)= "0000000000000000") then
					Zero <= '1';
				else
					zero <= '0';
				end if;
			else
				result <=(others=>'Z');
				carry <= C;
				Zero <= Z;
			end if;
		elsif(CZL = "010") then
			if(Z = '1') then
				rescarr <= std_logic_vector(resize((unsigned(opr1) + unsigned(opr2)),17));
				result <= rescarr(15 downto 0);
				Carry <= rescarr(16);
				if(rescarr(15 downto 0)= "0000000000000000") then
					Zero <= '1';
				else
					zero <= '0';
				end if;
			else
				result <=(others=>'Z');
				carry <= C;
				Zero <= Z;
			end if;
		elsif(CZL = "001") then
			shiftin <= opr2;
			rescarr <= std_logic_vector(resize((unsigned(opr1) + unsigned(shiftout)),17));
			result <= rescarr(15 downto 0);
			carry <= rescarr(16);
			if(rescarr(15 downto 0)= "0000000000000000") then
				Zero <= '1';
			else
				zero <= '0';
			end if;
		else
			result <=(others => 'Z');
			carry <= C;
			Zero <=Z;
		end if;
	elsif(opcode = "0000") then
		opr1 <= instruction(36 downto 21);
		opr2 <= instruction(20 downto 5);	
		rescarr <= std_logic_vector(resize((unsigned(opr1) + unsigned(opr2)),17));
		result <= rescarr(15 downto 0);
		Carry <= rescarr(16);
		if(rescarr(15 downto 0)= "0000000000000000") then
			Zero <= '1';
		else
			zero <= '0';
		end if;
	elsif(opcode = "0010") then
		opr1 <= instruction(36 downto 21);
		opr2 <= instruction(20 downto 5);	
		if(CZL = "000") then	
			rescarr(15 downto 0) <= NOT(opr1 AND opr2);
			Carry <= C;
			result <= rescarr(15 downto 0);
			if(rescarr(15 downto 0)= "0000000000000000") then
				Zero <= '1';
			else
				zero <= '0';
			end if;
		elsif(CZL = "100") then
			if(C = '1') then
				rescarr(15 downto 0)<= NOT(opr1 AND opr2);
				carry <=C;
				result <= rescarr(15 downto 0);
				if(rescarr(15 downto 0)= "0000000000000000") then
					Zero <= '1';
				else
					zero <= '0';
				end if;
			else
				result <=(others=>'Z');
				Carry <= C;
				Zero <= Z;
			end if;
		elsif(CZL = "010") then
			if(Z = '1') then
				rescarr(15 downto 0) <= NOT(opr1 AND opr2);
			   Carry <= C;
				result <= rescarr(15 downto 0);
				if(rescarr(15 downto 0)= "0000000000000000") then
					Zero <= '1';
				else
					zero <= '0';
				end if;
			else
				result <=(others=>'Z');
				Carry <= C;
				Zero <=Z;
			end if;
		else
			result <=(others => 'Z');
			Carry <= C;
			Zero <=Z;
		end if;
	elsif (opcode = "1000") then
		opr1 <= instruction(36 downto 21);
		opr2 <= instruction(20 downto 5);
		Carry <= C;
		Zero <= Z;
		if(opr1 = opr2) then
			result <= (others=>'1');-------------------IF TAKEN RESULT = "1111111111111111"
		else
			result <= (others=>'0');-------------------IF NOT TAKEN RESULT = "0000000000000000"
		end if;
	elsif (opcode = "1001") then
		--JALR
		--OPR1 = PC + 1 of JALR; OPR 2 irrelevant (taken 0000..0000)
		result <= instruction(36 downto 21);
		Carry <= C;
		Zero <= Z;
	elsif (opcode = "1010") then
		--JLR
		--OPR1 = PC + 1 of JLR; OPR2 reg b content;
		opr1 <= instruction(36 downto 21);
		opr2 <= instruction(20 downto 5);
		forjlr <= opr2;
		result <= opr1;
	elsif( opcode = "1011") then
		--JRI
		--OPR1 = Ra content; OPR2 = imm
		opr1 <= instruction(36 downto 21);
		opr2 <= instruction(20 downto 5);	
		rescarr <= std_logic_vector(resize((unsigned(opr1) + unsigned(opr2)),17));
		result <= rescarr(15 downto 0);
		Carry <=C;
		Zero <= Z;
	end if;	
	if(opcode = "1010") then
		forjlr <= instruction(20 downto 5);
	else
		forjlr <= (others =>'Z');
	end if;
	Inumrob <= Inum;
end if;
end process;
end architecture lolgic;

