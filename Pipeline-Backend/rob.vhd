library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RoB is
    port(
		 rst, clk, DBWrite_en1, DBWrite_en2, DBWrite_en3, DBWrite_en4, en_write: in std_logic;--remove write enable if not needed
		 d_in1, d_in2: in std_logic_vector(53 downto 0);
		 d_DB1, d_DB2, d_DB3, d_DB4: in std_logic_vector(15 downto 0);--for the result coming in from the three pipelines
		 mem_addr3, mem_addr4: in std_logic_vector(15 downto 0);
		 inum1, inum2, inum3, inum4: in std_logic_vector(6 downto 0);
		 dout1, dout2: out std_logic_vector(15 downto 0); --remove if not needed
		 mem1, mem2: out std_logic_vector(15 downto 0);
		 dest1, dest2: out std_logic_vector(5 downto 0);
		 wr1_prf, wr2_prf: out std_logic;
		 wr1_mem, wr2_mem: out std_logic;
		 
		 rob_full, rob_empty: out std_logic;
		 rob_index: out integer	--indicates which rob entry is free
	 );
end RoB;
	 
 architecture buff of RoB is
		type column1 is array (0 to 99) of std_logic;--length of reorder buffer is 100
		type column4 is array (0 to 99) of std_logic_vector(3 downto 0);
		type column16 is array (0 to 99) of std_logic_vector(15 downto 0);
		type column7 is array(0 to 99) of std_logic_vector(6 downto 0);
		signal inst_num: column7;
		signal c_flag: column1 :='0';--c_flag: execution is complete or not
		signal dest_addr, result: column16 := (others=>'0');
		signal opcode: column4 := (others=>'0');
		variable head_ptr, tail_ptr: integer range 0 to 99; --defining head and tail pointers with loopback

		begin
				--process for writing
				process(rst, clk, d_in1, d_in2, c_flag, head_ptr, tail_ptr) 
					begin
				  
				if clk'event and clk = '1' then 
						if(rst='1') then
							head_ptr := 0;--head and tail pointers are initially 0
							tail_ptr := 0;
							rob_full <= '0';
							rob_empty <= '1';
							rob_index := tail_ptr;
						else
							rob_empty <= '0';
							inst_num(rob_index)<=d_in1(53 downto 47);
							opcode(rob_index) <= d_in1(46 downto 43);
							dest_addr(rob_index) <= d_in1(8 downto 3); --increase on increasing the number of registers
							c_flag(rob_index)<='0';
							
							inst_num(rob_index+1)<=d_in1(53 downto 47);
							opcode(rob_index+1) <= d_in1(46 downto 43);
							dest_addr(rob_index+1) <= d_in1(8 downto 3);
							c_flag(rob_index+1)<='0';
							
							tail_ptr := tail_ptr + 2;
							rob_index := tail_ptr;
						
						if(head_ptr = tail_ptr +2) then 
								rob_full <= '1';
						end if;
					-- do the result onwards
					  end if;
						
						L1: for i in 0 to 99 loop
							if(inst_num(i)=inum1 and DBWrite_en1='1') then
								c_flag(i)<='1';
								result(i)<=d_DB1;
							end if;
							if(inst_num(i)=inum2 and DBWrite_en2='1') then
								c_flag(i)<='1';
								result(i)<=d_DB1;
							end if;
							if(inst_num(i)=inum3 and DBWrite_en3='1') then
								c_flag(i)<='1';
								result(i)<=d_DB1;
								dest_addr(i)<=mem_addr3;
							end if;
							if(inst_num(i)=inum4 and DBWrite_en4='1') then
								c_flag(i)<='1';
								result(i)<=d_DB1;
								dest_addr(i)<=mem_addr4;
							end if;
						end loop L1;
						
						wr1_prf<='0';
						wr2_prf<='0';
						wr1_mem<='0';
						wr2_mem<='0';
						
						if(c_flag(head_ptr)='1') then
							dout1<=result(head_ptr);
							if(opcode(head_ptr)="0101") then
								mem1<=dest_addr(head_ptr);
								wr1_mem<='1';
								wr1_prf<='0';
							else
								dest1<=dest_addr(head_ptr);
								wr1_mem<='0';
								wr1_prf<='1';
							end if;
							head_ptr:=head_ptr+1;
						end if;
						
						if(c_flag(head_ptr)='1') then
							dout2<=result(head_ptr);
							if(opcode(head_ptr)="0101") then
								mem2<=dest_addr(head_ptr);
								wr2_mem<='1';
								wr2_prf<='0';
							else
								dest2<=dest_addr(head_ptr);
								wr2_mem<='0';
								wr2_prf<='1';
							end if;
							head_ptr:=head_ptr+1;
						end if;
						
				end if;
end process;
end buff;	