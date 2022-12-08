library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity superscalar is
port(clock: in std_logic;
	  reset: in std_logic;
	  RF_out_address: in std_logic(5 downto 0);
	  RF_out_data: out std_logic(15 downto 0));
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
			  Dest_I1, Dest_I2: in std_logic_vector(5 downto 0)
			  I1V1,I1V2,I2V1,I2V2: in std_logic);
		end component Decoder;
		
		component PRF is
		port(A_addr, B_addr, C_addr, D_addr, E_addr, F_addr: in std_logic_vector(2 downto 0);
			  A_data_out, B_data_out: out std_logic_vector(15 downto 0);
			  C_data_in, D_data_in: in std_logic_vector(15 downto 0);
			  clock: in std_logic;
			  DestReg1, DestReg2: in std_logic_vector(2 downto 0);
			  RenamedReg1, RenamedReg2: out std_logic_vector(5 downto 0);
			  A_V, B_V: std_logic);
		end component PRF;
		
		component Two_One_mux is
		port(In1, In2: in std_logic_vector(15 downto 0);
			  Output: out std_logic_vector(15 downto 0));
		end component Two_One_mux;
		
		component Branch_Pred is
		port(Branch_addr: in std_logic_vector(15 downto 0);
		Branch_pred: std_logic;
		clock: std_logic);
		-------------------------------------------
		--define
		-------------------------------------------
		
		component Reg is
		Port ( CLK : in STD_LOGIC;
				 CLR : in STD_LOGIC;
				 D_in : in STD_LOGIC_VECTOR (15 downto 0);
				 D_out1 : out STD_LOGIC_VECTOR (15 downto 0));
		end entity Reg;
		
		---------------------------------------------------------------------
		-- ADD COMPONENTS HERE AS REQUIRED
		-----------------------------------------------------------------
		-- ADD SIGNALS HERE AS REQUIRED
		-------------------------------------------------------------------

		signal Imem_I1, Imem_I2: std_logic_vector(15 downto 0);
		signal muxout: std_logic_vector(15 downto 0);
		signal muxin_pc, muxin_BHT: std_logic_vector(15 downto 0);
		signal clock: std_logic;
		signal Imem_WE, Imem_RE: std_logic;
		signal Imem_Write_address, Imem_write_data_in: std_logic_vector(15 downto 0);
		signal Ibuff_RE, Ibuff_WE: std_logic;
		signal Ibuff_out1, Ibuff_out2: std_logic_vector(15 downto 0);
		signal opcode1, opcode2: std_logic_vector(3 downto 0);
		signal dest1, dest2, I1opreg1, I1opreg2, I2opreg1, I2opreg2: std_logic(2 downto 0);
		signal I1RR, I2RR: std_logic_vector(5 downto 0);
		signal I1opr1V, I1opr2V, I2opr1V, I2opr2V: std_logic;
		signal A_addr, B_addr, C_addr, D_addr, DestReg1, Destreg2: std_logic_vector(2 downto 0);
		signal A_data_out, B_data_out, C_data_in, D_data_in: std_logic_vector(15 downto 0);
		signal clock, A_V, B_V: std_logic;
		signal RenamedReg1, RenamedReg2 : std_logic_vector(5 downto 0);
		signal I1opr1, I1opr2, I2opr1, I2opr2: std_logic_vector(15 downto 0);
		signal shifterin, shifterout: std_logic_vector(15 downto 0);
		signal SE6in, SE6in2: std_logic_vector(5 downto 0);
		signal SE6out, SE6out2: std_logic_vector(15 downto 0);
		signal SE9in, SE9in2: std_logic_vector(8 downto 0);
		signal SE9out, SE9out2: std_logic_vector(15 downto 0);
		signal DECODED_I1, DECODED_I2: std_logic_vecctor(46 downto 0);
		signal I1opr1V, I1opr2V, I2opr1V, I2opr2V;
		
		begin
		
		Imemory : Imem port map(clock, Imem_WE, Imem_RE, Imem_Write_address, Imem_write_data, muxout, Imem_I1, Imem_I2);

	
		Ibuffer: Instruction_Buffer port map(Imem_I1, Imem_I2,Ibuff_RE, Ibuff_out1, Ibuff_out2, Ibuff_WE, clock);
	
	
		REGFILE: PRF port map(A_addr, B_addr, C_addr, D_addr, A_data_out, B_data_out, C_data_in, D_data_in, clock, destreg1, destreg2,RenamedReg1, RenamedREg2, A_V, B_V);
	

		SHIFTER: shifter port map(shifterin, shifterout);
		
		
		SE6: SE port map(SE6in, SE6out);
		
		
		DECODER: decoder port map(Ibuff_out1, Ibuff_out2, clock, DECODED_I1, DECODED_I2, I1opr1, I1opr2, O2opr1, I2opr2, RenamedReg1, RenamedReg2, I1opr1V, I1opr2V, I2opr1V, I2opr2V);
		
		
		FETCH_OPs: process(Ibuff_out1)
		begin
				
				opc1 <= Ibuff_out1(15 downto 12);
				
				case opc1 is
						
						when "0001" =>
							
							if( Ibuff_out1(1 downto 0) != "11") then
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
								I1opr1_V <= A_V;
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
							I1opr1_V <= A_V;
							I1opr2V <= B_V;
							
						when "0000" =>
							
							SE6in <= Ibuff_out1(5 downto 0);
							I1opr1 <= SE6out;
							A_addr <= Ibuff(11 downto 9);
							I1opr2 <= A_data_out;
							destreg1 <= Ibuff_out1(8 downto 6);
							I1opr2_V <= A_V;
							I1opr1_V <= '1';
							
						when "0100" =>
						
							destreg1 <= Ibuff_out1(11 downto 9);
							SE9in <= Ibuff_out1(8 downto 0);
							I1opr1 <= SE9out;
							
						when "0111" =>
							destreg1 <= Ibuff_out1(11 downto 9);
							A_addr <= Ibuff_out1(8 downto 6);
							SE6in <= Ibuff_out1(5 downto 0);
							I1opr1 <= SE9out;
							
						when "0101" =>
						
							destreg1 <= Ibuff_out1(8 downto 6);
							SE6in <= Ibuff_out1(5 downto 0);
							destIm <= <= SE6out; -- dest imm is that thing you add to the destination
							A_addr <= Ibuff_out1(11 downto 9);
						
						when 	"1000" =>
							
							A_addr <= Ibuff_out1(11 downto 9);
							B_addr <= Ibuff_out1(8 downto 6);
							SE6in <= Ibuff_out1(5 downto 0);
							destIm <= <= SE6out;
							destreg1 <= PC;
						
						when "1001" =>
						
							destreg1 <= Ibuff_out1(11 downto 9);
							SE9in <= Ibuff_out1(8 downto 0);
							I1opr1 <= SE9out;
							A_addr <= PC;
							
						when "1010"
							
							destreg1 <= Ibuff_out1(11 downto 9);
							A_addr <= PC;
							B_addr <= Ibuff_out1(8 downto 6);
							
						when "1011" 
							
							A_addr <= Ibuff_out1(11 downto 9);
							SE9in <= Ibuff_out1(8 downto 0);
							I1opr1 <= SE9out;
							
				opc2 <= Ibuff_out2(15 downto 12);
				
				case opc2 is
						
						when "0001" =>
							
							if( Ibuff_out2(1 downto 0) != "11") then
								I2opreg <= Ibuff_out2(11 downto 9);
								I2opreg2 <= Ibuff_out2(8 downto 6);
								destreg2 <= Ibuff_out2(5 downto 3);
								E_addr <= I1opreg1;
								F_addr <= I1opreg2;
								I2opr1 <= A_data_out;
								I2opr2 <= B_data_out;
								I2opr1V <= A_V;
								I2opr2V <= B_V;
								
							else 
								I2opreg1 <= Ibuff_out2(11 downto 9);
								I2opreg2 <= Ibuff_out2(8 downto 6);
								destreg2 <= Ibuff_out2(5 downto 3);
								E_addr <= I1opreg1;
								F_addr <= I1opreg2;
								I2opr1 <= A_data_out;
								shifterin <= B_data_out;
								I2opr2 <= shifterout;
								I2opr1_V <= A_V;
								I2opr2V <= B_V;
								
							end if;	
								
						when "0010" =>
							
							I2opreg1 <= Ibuff_out2(11 downto 9);
							I2opreg2 <= Ibuff_out2(8 downto 6);
							destreg2 <= Ibuff_out2(5 downto 3);
							E_addr <= I1opreg1;
							F_addr <= I1opreg2;
							I2opr1 <= A_data_out;
							I2opr2 <= B_data_out;
							I2opr1_V <= A_V;
							I2opr2V <= B_V;
							
						when "0000" =>
							
							SE6in2 <= Ibuff_out2(5 downto 0);
							I2opr1 <= SE6out2;
							E_addr <= Ibuff(11 downto 9);
							I2opr2 <= A_data_out;
							destreg2 <= Ibuff_out2(8 downto 6);
							I2opr2_V <= A_V;
							I2opr1_V <= '1';
							
						when "0100" =>
						
							destreg2 <= Ibuff_out2(11 downto 9);
							SE9in2 <= Ibuff_out2(8 downto 0);
							I2opr1 <= SE9out2;
							
						when "0111" =>
							destreg2 <= Ibuff_out2(11 downto 9);
							E_addr <= Ibuff_out2(8 downto 6);
							SE6in2 <= Ibuff_out2(5 downto 0);
							I2opr1 <= SE9out2;
							
						when "0101" =>
						
							destreg2 <= Ibuff_out2(8 downto 6);
							SE6in2 <= Ibuff_out2(5 downto 0);
							destIm2 <= <= SE6out2; -- dest imm is that thing you add to the destination
							E_addr <= Ibuff_out2(11 downto 9);
						
						when 	"1000" =>
							
							E_addr <= Ibuff_out2(11 downto 9);
							F_addr <= Ibuff_out2(8 downto 6);
							SE6in2 <= Ibuff_out2(5 downto 0);
							destIm2 <= <= SE6out2;
							destreg2 <= PC;
						
						when "1001" =>
						
							destreg2 <= Ibuff_out2(11 downto 9);
							SE9in2 <= Ibuff_out2(8 downto 0);
							I2opr1 <= SE9out2;
							E_addr <= PC;
							
						when "1010"
							
							destreg2 <= Ibuff_out2(11 downto 9);
							E_addr <= PC;
							F_addr <= Ibuff_out2(8 downto 6);
							
						when "1011" 
							
							E_addr <= Ibuff_out2(11 downto 9);
							SE9in2 <= Ibuff_out2(8 downto 0);
							I2opr1 <= SE9out2;						
							
					
							
						
						
--------------------------------------------------------------------------------
-----------LM and SM left--------------------------------------------------
------------------------------------------------------------------------------
