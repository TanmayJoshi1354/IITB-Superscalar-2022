library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity BranchPredictor is
  port (
  	clk		: in std_logic;	-- clock
  	rst		: in std_logic;	-- reset				
	instr	: in std_logic_vector(15 downto 0); 		-- instr for predicting
	Address	: in std_logic_vector(15 downto 0); 		-- Program Counter
	PC		: in std_logic_vector(15 downto 0); 		-- Program Counter
	Pred_Res	: out std_logic;		-- Branch to be taken or not to be taken
	Actual_Res	: in std_logic; -- Actual Outcome of branch
	Update_Bit :in std_logic -- set to 1 while updating BHT
    );
end BranchPredictor;

architecture Predict of BranchPredictor is

Type Table is array (31 downto 0) of std_logic_vector(17 downto 0);	-- History bits & PC
signal BHT : Table; 
signal occupied : std_logic_vector(31 downto 0);
Type LRU_counter is array (31 downto 0) of integer range 0 to 16;	-- For LRU

signal write_table : std_logic_vector(17 downto 0);
signal write_BHT_en : std_logic;
signal write_loc : integer range 0 to 15;
begin

	Predictor : process(clk, rst, instr, PC, Address, Update_Bit)
	variable check_bit: std_logic := '0';
	variable LRU_count : LRU_counter;
	variable least_rec,free_loc : integer range 0 to 31;
	variable addr_temp: std_logic_vector(15 downto 0);
	begin
	if clk'event and clk = '0' then
		if rst = '1' then
			Pred_Res <= '0';
			occupied <= (others => '0');
			LRU_count  := (others => 0);
		elsif instr(15 downto 12) = "1000" then
			if Update_Bit= '0' then
				addr_temp := PC;
			else 
				addr_temp := Address;
			end if;
			L1: for i in 0 to 31 loop
				if ( BHT(i)(15 downto 0) = addr_temp ) and ( occupied(i) = '1' ) then
					Pred_Res <=  BHT(i)(17);
					LRU_count(i) := 0;
					write_BHT_en <= '0';
					check_bit :='1';
					exit L1;
				end if;
			end loop L1;
			if check_bit = '0' then	
				write_BHT_en <= '1';
				if occupied /= "11111111111111111111111111111111" then
					free_loc := 0;
					L2: for i in 0 to 31 loop
						if occupied(i) = '0' then
							free_loc := i;
							exit L2;
						end if;
					end loop L2;
					occupied(free_loc) <= '1';
					LRU_count (free_loc) := 0;
					write_table <= "01" & addr_temp;
					Pred_Res <=  '1'; -- Default result is taken
					write_loc <= free_loc;
					
				else
					least_rec := 0;
					L3: for i in 0 to 31 loop
						if occupied(i) = '1' then
							LRU_count(i) := LRU_count(i)-1;
							if (LRU_count(i)> LRU_count(least_rec)) then
								least_rec := i;
							end if;
						end if;
					end loop L3;
					
					occupied(least_rec) <= '1';
					LRU_count (least_rec) := 1;
					write_table <= "01" & addr_temp;
					Pred_Res <=  '1';
					write_loc <= least_rec;
										
				end if;
				
			end if;							
		else
			Pred_Res <=  '0';
			write_BHT_en <= '0';
		end if;
	end if;
	end process Predictor;
	
	Updater : process(clk, rst, Address, Actual_Res, Update_Bit)
	variable update_loc : integer range 0 to 31;
	begin
		if clk'event and clk = '1' then
			if rst = '1' then
				BHT <= ( others => "00" & x"0000");
			elsif Update_Bit= '1' then
				if write_BHT_en = '1' then
					BHT(write_loc) <= write_table;
				end if;				
				update_loc := 0;
				L4: for i in 1 to 31 loop
					if ( Address = BHT(i)(15 downto 0) ) and ( occupied(i) = '1' ) then
						update_loc := i;
						exit L4;
					end if;
				end loop L4;
						
				if (not (update_loc = write_loc and write_BHT_en = '1')) then	
					if BHT(update_loc)(17 downto 16) = "00" then
						if Actual_Res = '1' then
							BHT(update_loc)(17 downto 16) <= "01";
						else
							BHT(update_loc)(17 downto 16) <= "00";
						end if;
					elsif BHT(update_loc)(17 downto 16) = "01" then
						if Actual_Res = '1' then
							BHT(update_loc)(17 downto 16) <= "11";
						else
							BHT(update_loc)(17 downto 16) <= "00";
						end if;
					elsif BHT(update_loc)(17 downto 16) = "10" then
						if Actual_Res = '1' then
							BHT(update_loc)(17 downto 16) <= "11";
						else
							BHT(update_loc)(17 downto 16) <= "00";
						end if;
					else
						if Actual_Res = '1' then
							BHT(update_loc)(17 downto 16) <= "11";
						else
							BHT(update_loc)(17 downto 16) <= "10";
							
						end if;
					end if;
				end if;
			end if;
		end if;
	end process Updater;
end architecture Predict;
