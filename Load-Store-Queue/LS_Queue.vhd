library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LS_Queue is 
		port(
			clk, reset: in std_logic; --In
			
			--Write new entry
			wr1: in std_logic; --controller
			I1_num_in: in std_logic_vector(6 downto 0); --Dispatch buffer
			l1_flag: in std_logic; --Dispatch buffer
			wr2: in std_logic; --controller
			I2_num_in: in std_logic_vector(6 downto 0); --Dispatch buffer
			l2_flag: in std_logic; --Dispatch buffer
			
			--Update valid bit
			I3_num_in: in std_logic_vector(6 downto 0); --LS_Pipeline
			I3_addr: in std_logic_vector(15 downto 0); --LS_pipeline
			l3_flag: in std_logic; --LS_Pipeline
			I3_store_val: in std_logic_vector(15 downto 0); --LS_pipeline
			I4_num_in: in std_logic_vector(6 downto 0); --LS_Pipeline
			I4_addr: in std_logic_vector(15 downto 0); --LS_pipeline
			l4_flag: in std_logic; --LS_Pipeline
			I4_store_val: in std_logic_vector(15 downto 0); --LS_pipeline
			
			sel1: out std_logic_vector(1 downto 0); --LS_pipeline
			sel2: out std_logic_vector(1 downto 0); --LS_pipeline
			load_val1: out std_logic_vector(15 downto 0); --LS_pipeline
			load_val2: out std_logic_vector(15 downto 0) --LS_pipeline
			-- if the entry is available in the store queue, use that value in the load instr
			);
		end LS_Queue;
			
		architecture LSQ of LS_Queue is
				type column7 is array (0 to 127) of std_logic_vector(6 downto 0); --the length of both queues is 128
				type column16 is array (0 to 127) of std_logic_vector(15 downto 0);
				type column1 is array (0 to 127) of std_logic;
				type columnInt is array(0 to 127) of integer;
				
				signal LQ_addr: column16 := (others=>(others=>'0'));
				signal LQ_Inum, SQ_Inum: column7:=(others=>(others=>'0'));
				signal LQ_head, LQ_tail:columnInt := (others=>0);				
				shared variable head_ptrS, tail_ptrS: integer range 0 to 127; --defining head and tail pointers of the store queue with loopback
				shared variable head_ptrL, tail_ptrL: integer range 0 to 127; --defining head and tail pointers of the load queue with loopback				
				signal SQ_addr, SQ_value: column16 := (others=>(others=>'0'));
				signal SQ_comp, SQ_valid: column1 := (others=>'0');
				
				begin
				
				--process for writing into the store queue after dispatch
				process(clk, reset, wr1, wr2, l1_flag, l2_flag)
					begin
					if rising_edge(clk) then 
						if reset='1' then
							sel1<="00";
							sel2<="00";
							load_val1<=(others=>'0');
							load_val2<=(others=>'0');
							LQ_addr<=(others=>(others=>'0'));
							SQ_addr<=(others=>(others=>'0'));
							SQ_value<=(others=>(others=>'0'));
							LQ_Inum<=(others=>(others=>'0'));
							SQ_Inum<=(others=>(others=>'0'));
							head_ptrS:=0;
							head_ptrL:=0;
							tail_ptrS:=0;
							tail_ptrL:=0;
							SQ_comp<=(others=>'0');
							SQ_valid<=(others=>'0');
						end if;
						if (l1_flag = '0' and wr1='1') then
							SQ_Inum(tail_ptrS) <= I1_num_in;
							SQ_comp(tail_ptrS) <= '0';
							tail_ptrS:= tail_ptrS + 1;
							end if;
						if (l2_flag = '0' and wr2='1') then
							SQ_Inum(tail_ptrS) <= I2_num_in;
							SQ_comp(tail_ptrS) <= '0';
							tail_ptrS:= tail_ptrS + 1;
							end if;
						if (l1_flag = '1' and wr1='1') then
							LQ_Inum(tail_ptrL) <= I1_num_in;
							LQ_head(tail_ptrL) <= head_ptrS;
							LQ_tail(tail_ptrL) <= tail_ptrS;
							tail_ptrL := tail_ptrL + 1;
							end if;
						if (l2_flag = '1' and wr2='1') then
							LQ_Inum(tail_ptrL) <= I2_num_in;
							LQ_head(tail_ptrL) <= head_ptrS;
							LQ_tail(tail_ptrL) <= tail_ptrS;
							tail_ptrL := tail_ptrL + 1;
							end if;	
						if l3_flag = '0' then
							L1: for i in 0 to 127 loop
								if SQ_Inum(i) = I3_num_in then
									SQ_addr(i) <= I3_addr;
									SQ_value(i) <= I3_store_val;
									SQ_valid(i) <= '1';
									exit when i=tail_ptrS;
								end if;
							end loop L1;
						end if;
						if l4_flag='0' then
							L4: for i in 0 to 127 loop
								if SQ_Inum(i) = I4_num_in then
									SQ_addr(i) <= I4_addr;
									SQ_value(i) <= I4_store_val;
									SQ_valid(i) <= '1';
									exit when i=tail_ptrS;
								end if;
							end loop L4;
						end if; 
						if l3_flag = '1' then
							L2: for i in 0 to 127 loop
								if LQ_addr(i) = I3_addr then
									L3: for j in 0 to 127 loop
										if SQ_addr(j) = I3_addr and SQ_valid(j)='1' then
											load_val1 <= SQ_value(j);
										   sel1<="01";
											exit;
										elsif SQ_addr(j)=I3_addr and SQ_valid(j)='0' then
											sel1<="00";
											exit;
										else
											sel1<="10";
										end if;
										exit when j=LQ_tail(i);
									end loop L3;
								end if;
								exit when i=tail_ptrL;
							end loop L2;
						end if;
						if l4_flag = '1' then
							L5: for i in 0 to 127 loop
								if LQ_addr(i) = I4_addr then
									L6: for j in 0 to 127 loop
										if SQ_addr(j) = I4_addr and SQ_valid(j)='1' then
											load_val2 <= SQ_value(j);
										   sel2<="01";
											exit;
										elsif SQ_addr(j)=I4_addr and SQ_valid(j)='0' then
											sel2<="00";
											exit;
										else
											sel2<="10";
										end if;
										exit when j=LQ_tail(i);
									end loop L6;
								end if;
								exit when i=tail_ptrL;
							end loop L5;
						end if;
					end if;
				end process;
				end architecture LSQ;