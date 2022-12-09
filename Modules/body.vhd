library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity superscalar is
port(clock: in std_logic;
	  reset: in std_logic;
	  RF_out_address: in std_logic_vector(5 downto 0);
	  RF_out_data: out std_logic_vector(15 downto 0));
end entity superscalar;

-- Initialize PC

architecture func of superscalar is
--COMPONENT DECLARATIONS
		component Imem is
		port (clock : in std_logic;
				Write_Enable : in std_logic;
				Read_Enable : in std_logic;
				Write_Address : in std_logic_vector(15 downto 0);
				Read_Address : in std_logic_vector(15 downto 0);
				Write_Data_In : in std_logic_vector(15 downto 0);
				Read_Data_Out_1 : out std_logic_vector(15 downto 0);
				Read_Data_Out_2 : out std_logic_vector(15 downto 0));
		end component Imem;
		
		component Dmem is
		port (clock : in std_logic;
				Write_Enable : in std_logic;
				Read_Enable : in std_logic;
				Write_Address : in std_logic_vector(15 downto 0);
				Read_Address : in std_logic_vector(15 downto 0);
				Write_Data_In : in std_logic_vector(15 downto 0);
				Read_Data_Out : out std_logic_vector(15 downto 0));
		end component Dmem;
		
		component Instruction_Buffer is
		port(I1_in, I2_in: in std_logic_vector(15 downto 0);
			  Read_EN: in std_logic;
			  I1_out, I2_out: out std_logic_vector(15 downto 0);
			  Write_EN: in std_logic;
			  Clock: in std_logic);
		end component Instruction_Buffer;
		
		component SE is
		port( SE_in: in std_logic_vector(5 downto 0);
				SE_out: out std_logic_vector(15 downto 0));
		end component SE;
		
		component SE9 is
		port( SE_in: in std_logic_vector(8 downto 0);
				SE_out: out std_logic_vector(15 downto 0));
		end component SE9;
		
		component shifter is
		port(D_in: in std_logic_vector(15 downto 0);
			  D_out: out std_logic_vector(15 downto 0));
		end component shifter;
		
		component Decoder is 
		port(I1in, I2in: in std_logic_vector(15 downto 0);
			  Clock: in std_logic;
			  I1_decoded_out, I2_decoded_out: out std_logic_vector(46 downto 0);
			  Opr1_I1, Opr1_I2, Opr2_I1, Opr2_I2: in std_logic_vector(15 downto 0);
			  Dest_I1, Dest_I2: in std_logic_vector(5 downto 0);
			  I1V1,I1V2,I2V1,I2V2: in std_logic);
		end component Decoder;
		
		component renamer is
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
		   A_V,B_V,E_V,F_V: out std_logic
		);
		
	end component renamer;
		--port(A_addr, B_addr, C_addr, D_addr, E_addr, F_addr: in std_logic_vector(2 downto 0);
		--	  A_data_out, B_data_out, E_data_out, F_data_out: out std_logic_vector(15 downto 0);
		--	  C_data_in, D_data_in: in std_logic_vector(15 downto 0);
		--	  clock: in std_logic;
		--	  DestReg1, DestReg2: in std_logic_vector(2 downto 0);
		--	  RenamedReg1, RenamedReg2: out std_logic_vector(5 downto 0);
		--	  A_V, B_V, E_V, F_V: std_logic);
		--end component PRF;
		
		component Two_One_mux is
		port(In1, In2: in std_logic_vector(15 downto 0);
			  Output: out std_logic_vector(15 downto 0));
		end component Two_One_mux;
		
		component Branch_Pred is
		port(Branch_addr: in std_logic_vector(15 downto 0);
		Branch_pred: std_logic;
		clock: std_logic);
		end component Branch_pred;
		-------------------------------------------
		--define
		-------------------------------------------
		
		component Reg is
		Port ( CLK : in STD_LOGIC;
				 CLR : in STD_LOGIC;
				 D_in : in STD_LOGIC_VECTOR (15 downto 0);
				 D_out1 : out STD_LOGIC_VECTOR (15 downto 0));
		end component Reg;
		
		---------------------------------------------------------------------
		-- ADD COMPONENTS HERE AS REQUIRED
		-----------------------------------------------------------------
		-- ADD SIGNALS HERE AS REQUIRED
		-------------------------------------------------------------------

		signal Imem_I1, Imem_I2: std_logic_vector(15 downto 0);
		signal muxout: std_logic_vector(15 downto 0);
		signal muxin_pc, muxin_BHT: std_logic_vector(15 downto 0);
		--signal clock: std_logic;
		signal Imem_WE, Imem_RE: std_logic;
		signal Imem_Write_address, Imem_write_data_in: std_logic_vector(15 downto 0);
		signal Ibuff_RE, Ibuff_WE: std_logic;
		signal Ibuff_out1, Ibuff_out2: std_logic_vector(15 downto 0);
		signal opcode1, opcode2: std_logic_vector(3 downto 0);
		signal dest1, dest2, I1opreg1, I1opreg2, I2opreg1, I2opreg2: std_logic_vector(2 downto 0);
		signal I1RR, I2RR: std_logic_vector(5 downto 0);
		signal I1opr1V, I1opr2V, I2opr1V, I2opr2V: std_logic;
		signal A_addr, B_addr, C_addr, D_addr, E_addr, F_addr, DestReg1, Destreg2: std_logic_vector(2 downto 0);
		signal A_data_out, B_data_out, C_data_in, D_data_in, E_data_out, F_data_out: std_logic_vector(15 downto 0);
		signal A_V, B_V, E_V, F_V: std_logic;
		signal RenamedReg1, RenamedReg2 : std_logic_vector(5 downto 0);
		signal I1opr1, I1opr2, I2opr1, I2opr2: std_logic_vector(15 downto 0);
		signal shifterin, shifterout: std_logic_vector(15 downto 0);
		signal SE6in, SE6in2: std_logic_vector(5 downto 0);
		signal SE6out, SE6out2: std_logic_vector(15 downto 0);
		signal SE9in, SE9in2: std_logic_vector(8 downto 0);
		signal SE9out, SE9out2: std_logic_vector(15 downto 0);
		signal DECODED_I1, DECODED_I2: std_logic_vector(46 downto 0);
		signal opc1, opc2: std_logic_vector(3 downto 0);
		signal renamedDestReg1, renamedDestReg2: std_logic_vector(5 downto 0);
		signal LMSM: std_logic;
		signal I1_dest, I2_dest, I1_src1, I1_src2, I2_src1, I2_src2: std_logic_vector(2 downto 0);
		signal clr_prf, wr1, wr2, wr_stack1, wr_stack2,I1_wr_dest, I2_wr_dest: std_logic;
		signal completed_rr1, completed_rr2, Addr_in1, Addr_in2, I1_dest_rr, I2_dest_rr: std_logic_vector(5 downto 0);
		signal I_opcode: std_logic_vector(3 downto 0);
		signal D_in1, D_in2, I1_opr1_out, I1_opr2_out, I2_opr1_out, I2_opr2_out, I_opr1_out,I_opr8_out, I_opr2_out, I_opr3_out, I_opr4_out, I_opr5_out, I_opr6_out, I_opr7_out: std_logic_vector(15 downto 0);
		
		
		
		
		
		begin
		
		Imemory : Imem port map(clock, Imem_WE, Imem_RE, Imem_Write_address, Imem_write_data_in, muxout, Imem_I1, Imem_I2);

	
		Ibuffer: Instruction_Buffer port map(Imem_I1, Imem_I2,Ibuff_RE, Ibuff_out1, Ibuff_out2, Ibuff_WE, clock);
	
	
		REGFILE: renamer port map(Reset, Clock, LMSM, destreg1,I1_wr_dest,destreg2,I2_wr_dest,wr_stack1,completed_rr1,wr_stack2,completed_rr2,I_opcode,A_addr, B_addr, E_addr, F_addr,CLR_PRF, D_in1, Addr_in1,wr1,D_in2,Addr_in2,wr2,A_data_out, B_data_out, E_data_out, F_data_out,RenamedReg1, RenamedREg2,I_opr1_out,I_opr2_out,I_opr3_out,I_opr4_out,I_opr5_out,I_opr6_out,I_opr7_out,I_opr8_out,A_V,B_V,E_V,F_V);
	

		LEFTSHIFTER: shifter port map(shifterin, shifterout);
		
		
		SE6: SE port map(SE6in, SE6out);
		
		
		INST_DECODER: decoder port map(Ibuff_out1, Ibuff_out2, clock, DECODED_I1, DECODED_I2, I1opr1, I1opr2, I2opr1, I2opr2, RenamedReg1, RenamedReg2, I1opr1V, I1opr2V, I2opr1V, I2opr2V);
		
		
		FETCH_OPs: process(Ibuff_out1)
		begin
				
				opc1 <= Ibuff_out1(15 downto 12);
				
				case opc1 is
						
						when "0001" =>
							
							if( Ibuff_out1(1 downto 0) /= "11") then
								I1opreg1 <= Ibuff_out1(11 downto 9);
								I1opreg2 <= Ibuff_out1(8 downto 6);
								destreg1 <= Ibuff_out1(5 downto 3);
								A_addr <= I1opreg1;
								B_addr <= I1opreg2;
								I1opr1 <= A_data_out;
								I1opr2 <= B_data_out;
								I1opr1V <= A_V;
								I1opr2V <= B_V;
								
							else 
								I1opreg1 <= Ibuff_out1(11 downto 9);
								I1opreg2 <= Ibuff_out1(8 downto 6);
								destreg1 <= Ibuff_out1(5 downto 3);
								A_addr <= I1opreg1;
								B_addr <= I1opreg2;
								I1opr1 <= A_data_out;
								shifterin <= B_data_out;
								I1opr2 <= shifterout;
								I1opr1V <= A_V;
								I1opr2V <= B_V;
								
							end if;	
								
						when "0010" =>
							
							I1opreg1 <= Ibuff_out1(11 downto 9);
							I1opreg2 <= Ibuff_out1(8 downto 6);
							destreg1 <= Ibuff_out1(5 downto 3);
							A_addr <= I1opreg1;
							B_addr <= I1opreg2;
							I1opr1 <= A_data_out;
							I1opr2 <= B_data_out;
							I1opr1V <= A_V;
							I1opr2V <= B_V;
							
						when "0000" =>
							
							SE6in <= Ibuff_out1(5 downto 0);
							I1opr1 <= SE6out;
							A_addr <= Ibuff_out1(11 downto 9);
							I1opr2 <= A_data_out;
							destreg1 <= Ibuff_out1(8 downto 6);
							I1opr2V <= A_V;
							I1opr1V <= '1';
							
						when "0100" =>
						
							destreg1 <= Ibuff_out1(11 downto 9);
							SE9in <= Ibuff_out1(8 downto 0);
							I1opr1 <= SE9out;
							I1opr2 <= (others=> 'Z');
							I1opr1V <= '1';
							I1opr2V <=  '1';
							
						when "0111" =>
							destreg1 <= Ibuff_out1(11 downto 9);
							A_addr <= Ibuff_out1(8 downto 6);
							SE6in <= Ibuff_out1(5 downto 0);
							I1opr1 <= SE6out;
							I1opr2 <= (others => 'Z');
							I1opr1V <= '1';
							I1opr2V <= '1';
							
						when "0101" =>
						
							destreg1 <= Ibuff_out1(8 downto 6);
							SE6in <= Ibuff_out1(5 downto 0);
							I1opr2 <= SE6out; -- dest imm is that thing you add to the destination
							A_addr <= Ibuff_out1(11 downto 9);
							I1opr1 <= A_data_out;
							I1opr1V <= A_V;
							I1opr2V <= '0';
							
							
						when 	"1000" =>
							
							A_addr <= Ibuff_out1(11 downto 9);
							B_addr <= Ibuff_out1(8 downto 6);
							
							renamedDestReg1 <= Ibuff_out1(5 downto 0);
							I1opr1 <= A_data_out;
							I1opr2 <= B_data_out;
							I1opr1V <= A_V;
							I1opr2V <= B_V;
							
						when "1001" =>
						
							destreg1 <= Ibuff_out1(11 downto 9);
							SE9in <= Ibuff_out1(8 downto 0);
							I1opr1 <= SE9out;
	--						A_addr <= PC;
							I1opr2 <= (others => 'Z');
							I1opr1V <= '1';
							I1opr2V <= '0';
							
						when "1010" =>
							
							A_addr <= Ibuff_out1(11 downto 9);
							B_addr <= Ibuff_out1(8 downto 6);
							destreg1 <= (others => 'Z');
							I1opr1 <= A_data_out;
							I1opr2 <= B_data_out;
							I1opr1V <= A_V;
							I1opr2V <= B_V;
							
							
						when "1011" =>
							
							A_addr <= Ibuff_out1(11 downto 9);
							SE9in <= Ibuff_out1(8 downto 0);
							I1opr1 <= SE9out;
							I1opr2 <= A_data_out;
							I1opr1V <= '1';
							I1opr2V <= A_V;
							
					when others =>
							
							I1opr1 <= (others => 'Z');
							I1opr2  <= (others => 'Z');
							destreg1  <= (others => 'Z');
							I1opr1V <= 'Z';
							I1opr2V <= 'Z';
				end case;	
							
							
				opc2 <= Ibuff_out2(15 downto 12);
				
				case opc2 is
						
						when "0001" =>
							
							if( Ibuff_out2(1 downto 0) /= "11") then
								I2opreg1 <= Ibuff_out2(11 downto 9);
								I2opreg2 <= Ibuff_out2(8 downto 6);
								destreg2 <= Ibuff_out2(5 downto 3);
								E_addr <= I2opreg1;
								F_addr <= I2opreg2;
								I2opr1 <= E_data_out;
								I2opr2 <= F_data_out;
								I2opr1V <= E_V;
								I2opr2V <= F_V;
								
							else 
								I2opreg1 <= Ibuff_out2(11 downto 9);
								I2opreg2 <= Ibuff_out2(8 downto 6);
								destreg2 <= Ibuff_out2(5 downto 3);
								E_addr <= I2opreg1;
								F_addr <= I2opreg2;
								I2opr1 <= E_data_out;
								shifterin <= F_data_out;
								I2opr2 <= shifterout;
								I2opr1V <= E_V;
								I2opr2V <= F_V;
								
							end if;	
								
						when "0010" =>
							
							I2opreg1 <= Ibuff_out2(11 downto 9);
							I2opreg2 <= Ibuff_out2(8 downto 6);
							destreg2 <= Ibuff_out2(5 downto 3);
							E_addr <= I2opreg1;
							F_addr <= I2opreg2;
							I2opr1 <= E_data_out;
							I2opr2 <= F_data_out;
							I2opr1V <= E_V;
							I2opr2V <= F_V;
							
						when "0000" =>
							
							SE6in <= Ibuff_out2(5 downto 0);
							I2opr1 <= SE6out;
							E_addr <= Ibuff_out2(11 downto 9);
							I2opr2 <= E_data_out;
							destreg2 <= Ibuff_out2(8 downto 6);
							I2opr2V <= E_V;
							I2opr1V <= '1';
							
						when "0100" =>
						
							destreg2 <= Ibuff_out2(11 downto 9);
							SE9in <= Ibuff_out2(8 downto 0);
							I2opr1 <= SE9out;
							I2opr2 <= (others=> 'Z');
							I2opr1V <= '1';
							I2opr2V <=  '1';
							
						when "0111" =>
							destreg2 <= Ibuff_out2(11 downto 9);
							E_addr <= Ibuff_out2(8 downto 6);
							RenamedDestReg2 <= Ibuff_out2(5 downto 0);
							I2opr1 <= SE9out;
							I2opr2 <= (others => 'Z');
							I2opr1V <= '1';
							I2opr2V <= '1';
							
						when "0101" =>
						
							destreg2 <= Ibuff_out2(8 downto 6);
							SE6in <= Ibuff_out2(5 downto 0);
							I2opr2 <= SE6out; -- dest imm is that thing you add to the destination
							E_addr <= Ibuff_out2(11 downto 9);
							I2opr1 <= E_data_out;
							I2opr1V <= E_V;
							I2opr2V <= '0';
							
							
						when 	"1000" =>
							
							E_addr <= Ibuff_out2(11 downto 9);
							F_addr <= Ibuff_out2(8 downto 6);
							RenamedDestReg2 <= Ibuff_out2(5 downto 0);
							
							I2opr1 <= E_data_out;
							I2opr2 <= F_data_out;
							I2opr1V <= E_V;
							I2opr2V <= F_V;
							
						when "1001" =>
						
							destreg2 <= Ibuff_out2(11 downto 9);
							SE9in <= Ibuff_out2(8 downto 0);
							I2opr1 <= SE9out;
--							E_addr <= PC;
							I2opr2 <= (others => 'Z');
							I2opr1V <= '1';
							I2opr2V <= '0';
							
						when "1010" =>
							
							E_addr <= Ibuff_out1(11 downto 9);
							F_addr <= Ibuff_out1(8 downto 6);
							destreg2 <= (others => 'Z');
							I2opr1 <= E_data_out;
							I2opr2 <= F_data_out;
							I2opr1V <= E_V;
							I2opr2V <= F_V;
							
							
						when "1011" =>
							
							E_addr <= Ibuff_out2(11 downto 9);
							SE9in <= Ibuff_out2(8 downto 0);
							I2opr1 <= SE9out;
							I2opr2 <= E_data_out;
							I2opr1V <= '1';
							I2opr2V <= E_V;
							
						when others =>
							
							I2opr1 <= (others => 'Z');
							I2opr2  <= (others => 'Z');
							destreg2  <= (others => 'Z');
							I2opr1V <= 'Z';
							I2opr2V <= 'Z';
				end case;	
		end process;
end architecture;		
--------------------------------------------------------------------------------
-----------LM and SM left--------------------------------------------------
------------------------------------------------------------------------------