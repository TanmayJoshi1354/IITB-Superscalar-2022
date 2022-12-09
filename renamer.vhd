library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;

entity renamer is
	port(
		reset: in std_logic;
		clk: in std_logic;
		lmsm: in std_logic;
		I1_dest: in std_logic_vector(2 downto 0);
		I1_wr_dest: in std_logic;
		I2_dest: in std_logic_vector(2 downto 0);
		I2_wr_dest: in std_logic;
		wr_stack1: in std_logic;
		completed_rr1: in std_logic_vector(5 downto 0);
		wr_stack2: in std_logic;
		completed_rr2: in std_logic_vector(5 downto 0);
		I_opcode: in std_logic_vector(3 downto 0);
		
		I1_src1:in std_logic_vector(2 downto 0);
		I1_src2:in std_logic_vector(2 downto 0);
		I2_src1:in std_logic_vector(2 downto 0);
		I2_src2:in std_logic_vector(2 downto 0);
		
		clr_prf: in std_logic;
		
		D_in1: in std_logic_vector(15 downto 0);
		Addr_in1: in std_logic_vector(5 downto 0);
		wr1: in std_logic;
		D_in2: in std_logic_vector(15 downto 0);
		Addr_in2: in std_logic_vector(5 downto 0);
		wr2: in std_logic;	
	
		I1_opr1_out: out std_logic_vector(15 downto 0);
		I1_opr2_out: out std_logic_vector(15 downto 0);
		I2_opr1_out: out std_logic_vector(15 downto 0);
		I2_opr2_out: out std_logic_vector(15 downto 0);
		I1_dest_rr: out std_logic_vector(5 downto 0);
		I2_dest_rr: out std_logic_vector(5 downto 0);
			
		I_opr1_out: out std_logic_vector(15 downto 0);
		I_opr2_out: out std_logic_vector(15 downto 0);
		I_opr3_out: out std_logic_vector(15 downto 0);
		I_opr4_out: out std_logic_vector(15 downto 0);
		I_opr5_out: out std_logic_vector(15 downto 0);
		I_opr6_out: out std_logic_vector(15 downto 0);
		I_opr7_out: out std_logic_vector(15 downto 0);
		I_opr8_out: out std_logic_vector(15 downto 0);
		A_V,B_V,E_V,F_V: out std_logic);
	
end renamer;

architecture renamer1 of renamer is
	
	component rr_stack is
		port(
			reset: in std_logic;
			I1_dest: in std_logic_vector(2 downto 0);
			I1_wr_dest: in std_logic;
			I2_dest: in std_logic_vector(2 downto 0);
			I2_wr_dest: in std_logic;
			wr_stack1: in std_logic;
			completed_rr1: in std_logic_vector(5 downto 0);
			wr_stack2: in std_logic;
			completed_rr2: in std_logic_vector(5 downto 0);
			
			lmsm: in std_logic;
			I_opcode: in std_logic_vector(3 downto 0);
			
			I1_dest_rr: out std_logic_vector(5 downto 0);
			I2_dest_rr: out std_logic_vector(5 downto 0);
			I_dest_rr1: out std_logic_vector(5 downto 0);
			I_dest_rr2: out std_logic_vector(5 downto 0);
			I_dest_rr3: out std_logic_vector(5 downto 0);
			I_dest_rr4: out std_logic_vector(5 downto 0);
			I_dest_rr5: out std_logic_vector(5 downto 0);
			I_dest_rr6: out std_logic_vector(5 downto 0);
			I_dest_rr7: out std_logic_vector(5 downto 0);
			I_dest_rr8: out std_logic_vector(5 downto 0)
			);
	end component;
	
	component rat is
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
			
			I1_opr1:out std_logic_vector(15 downto 0);
			I1_opr2:out std_logic_vector(15 downto 0);
			I2_opr1:out std_logic_vector(15 downto 0);
			I2_opr2:out std_logic_vector(15 downto 0);
			
			I_opr1: out std_logic_vector(15 downto 0);
			I_opr2: out std_logic_vector(15 downto 0);
			I_opr3: out std_logic_vector(15 downto 0);
			I_opr4: out std_logic_vector(15 downto 0);
			I_opr5: out std_logic_vector(15 downto 0);
			I_opr6: out std_logic_vector(15 downto 0);
			I_opr7: out std_logic_vector(15 downto 0);
			I_opr8: out std_logic_vector(15 downto 0)
			);
	end component;
	
	component prf is
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
	end component;
	
	signal I1_dest_rr_temp, I2_dest_rr_temp, I_opr1_rr, I_opr2_rr, I_opr3_rr, I_opr4_rr, I_opr5_rr, I_opr6_rr, I_opr7_rr, I_opr8_rr: std_logic_vector(5 downto 0);
	signal I1_opr1_rat, I1_opr2_rat, I2_opr1_rat, I2_opr2_rat, I1_opr1_prf, I1_opr2_prf, I2_opr1_prf, I2_opr2_prf: std_logic_vector(15 downto 0);
	signal I1_opr1_v, I1_opr2_v, I2_opr1_v, I2_opr2_v: std_logic;
	signal valid_lmsm: std_logic_vector(7 downto 0);
	signal I_opr: std_logic_vector(127 downto 0);
	signal I_opr1_rat, I_opr2_rat, I_opr3_rat, I_opr4_rat, I_opr5_rat, I_opr6_rat, I_opr7_rat, I_opr8_rat: std_logic_vector(15 downto 0);
	
begin
	rat1:rat port map(reset=>reset, I1_src1=>I1_src1, I1_src2=>I1_src2, I1_dest=>I1_dest, I1_dest_rr=>I1_dest_rr_temp,
				I1_wr_dest=>I1_wr_dest, I2_src1=>I2_src1, I2_src2=>I2_src2, I2_dest=>I2_dest,
				I2_dest_rr=>I2_dest_rr_temp, I2_wr_dest=>I2_wr_dest, lmsm=>lmsm, I_opcode=>I_opcode,
				I_opr1_in=>I_opr1_rr, I_opr2_in=>I_opr2_rr, I_opr3_in=>I_opr3_rr, I_opr4_in=>I_opr4_rr,
				I_opr5_in=>I_opr5_rr, I_opr6_in=>I_opr6_rr, I_opr7_in=>I_opr7_rr, I_opr8_in=>I_opr8_rr, 
				I1_opr1=>I1_opr1_rat, I1_opr2=>I1_opr2_rat, I2_opr1=>I2_opr1_rat, I2_opr2=>I2_opr2_rat, 
				I_opr1=>I_opr1_rat, I_opr2=>I_opr2_rat, I_opr3=>I_opr3_rat, I_opr4=>I_opr4_rat, I_opr5=>I_opr5_rat, 
				I_opr6=>I_opr6_rat, I_opr7=>I_opr7_rat, I_opr8=>I_opr8_rat);
	
	rrstack1: rr_stack port map(reset=>reset, I1_dest=>I1_dest, I1_wr_dest=>I1_wr_dest, I2_dest=>I2_dest, 
										I2_wr_dest=>I2_wr_dest, wr_stack1=>wr_stack1, completed_rr1=>completed_rr1,
										wr_stack2=>wr_stack2, completed_rr2=>completed_rr2, lmsm=>lmsm, I_opcode=>I_opcode,
										I1_dest_rr=>I1_dest_rr_temp, I2_dest_rr=>I2_dest_rr_temp, I_dest_rr1=>I_opr1_rr, 
										I_dest_rr2=>I_opr2_rr, I_dest_rr3=>I_opr3_rr, I_dest_rr4=>I_opr4_rr, 
										I_dest_rr5=>I_opr5_rr, I_dest_rr6=>I_opr6_rr, I_dest_rr7=>I_opr7_rr, 
										I_dest_rr8=>I_opr8_rr);
	
	prf1: prf port map(clk=>clk, clr_prf=>reset, I1_Add1=>I1_opr1_rat, I1_Add2=>I1_opr2_rat,
							 I2_Add1=>I2_opr1_rat, I2_Add2=>I2_opr2_rat, D_in1=>D_in1, Addr_in1=>Addr_in1, wr1=>wr1,
							 D_in2=>D_in2, Addr_in2=>Addr_in2, wr2=>wr2, I1_wr_dest=>I1_wr_dest, I1_dest_rr=>I1_dest_rr_temp,
							 I2_wr_dest=>I2_wr_dest, I2_dest_rr=>I2_dest_rr_temp, I1_opr1=>I1_opr1_prf, I1_opr2=>I1_opr2_prf, 
							 I2_opr1=>I2_opr1_prf, I2_opr2=>I2_opr2_prf, I1_opr1_v=>I1_opr1_v, I1_opr2_v=>I1_opr2_v, 
							 I2_opr1_v=>I2_opr1_v, I2_opr2_v=>I2_opr2_v, lmsm=>lmsm, I_opcode=>I_opcode,
							 I_addr=>(I_opr1_rr & I_opr2_rr & I_opr3_rr & I_opr4_rr & I_opr5_rr & I_opr6_rr & I_opr7_rr & I_opr8_rr),
							 v=>valid_lmsm, I_opr=>I_opr);
	
	I1_dest_rr<=I1_dest_rr_temp;
	I2_dest_rr<=I2_dest_rr_temp;
	
	process(lmsm,valid_lmsm,I1_opr1_v, I1_opr2_v, I2_opr1_v, I2_opr2_v, I_opcode)
	begin
		if(lmsm='0') then
			if(I1_opr1_v='1') then
				I1_opr1_out<=I1_opr1_prf;
			else
				I1_opr1_out<=I1_opr1_rat;
			end if;
			if(I1_opr2_v='1') then
				I1_opr2_out<=I1_opr2_prf;
			else
				I1_opr2_out<=I1_opr2_rat;
			end if;
			if(I2_opr1_v='1') then
				I2_opr1_out<=I2_opr1_prf;
			else
				I2_opr1_out<=I2_opr1_rat;
			end if;
			if(I2_opr1_v='1') then
				I2_opr2_out<=I2_opr2_prf;
			else
				I2_opr2_out<=I2_opr2_rat;
			end if;
		else
			if(I_opcode="1101") then
				if(valid_lmsm(0)='1') then
					I_opr1_out<=I_opr(15 downto 0);
				else
					I_opr1_out<=I_opr1_rr;
				end if;
				if(valid_lmsm(1)='1') then
					I_opr2_out<=I_opr(31 downto 16);
				else
					I_opr2_out<=I_opr2_rr;
				end if;
				if(valid_lmsm(2)='1') then
					I_opr3_out<=I_opr(47 downto 32);
				else
					I_opr3_out<=I_opr3_rr;
				end if;
				if(valid_lmsm(3)='1') then
					I_opr4_out<=I_opr(63 downto 48);
				else
					I_opr4_out<=I_opr4_rr;
				end if;
				if(valid_lmsm(4)='1') then
					I_opr5_out<=I_opr(79 downto 64);
				else
					I_opr5_out<=I_opr5_rr;
				end if;
				if(valid_lmsm(5)='1') then
					I_opr6_out<=I_opr(95 downto 80);
				else
					I_opr6_out<=I_opr6_rr;
				end if;
				if(valid_lmsm(6)='1') then
					I_opr7_out<=I_opr(111 downto 96);
				else
					I_opr7_out<=I_opr7_rr;
				end if;
				if(valid_lmsm(7)='1') then
					I_opr8_out<=I_opr(127 downto 112);
				else
					I_opr8_out<=I_opr8_rr;
				end if;
			elsif(I_opcode="1100") then
				I_opr1_out<=I_opr1_rr;
				I_opr2_out<=I_opr2_rr;
				I_opr3_out<=I_opr3_rr;
				I_opr4_out<=I_opr4_rr;
				I_opr5_out<=I_opr5_rr;
				I_opr6_out<=I_opr6_rr;
				I_opr7_out<=I_opr7_rr;
				I_opr8_out<=I_opr8_rr;
			end if;
		end if;
	end process;
end renamer1;
	