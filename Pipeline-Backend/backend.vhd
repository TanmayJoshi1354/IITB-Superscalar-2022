library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity backend is
	port(
		clk: in std_logic;
		rst: in std_logic;
		wr1: in std_logic;
		wr2: in std_logic;
		I1_opr1_in:in std_logic_vector(15 downto 0);
		I1_opr2_in:in std_logic_vector(15 downto 0);
		I1_v1_in: in std_logic_vector(0 downto 0);
		I1_v2_in: in std_logic_vector(0 downto 0);
		I1_dest_reg_in: in std_logic_vector(5 downto 0);
		I1_opcode_in: in std_logic_vector(3 downto 0);
		I1_dec_in: in std_logic_vector(2 downto 0);
		I1_PC_in: in std_logic_vector(15 downto 0);
		I1_inst_num_in: in std_logic_vector(6 downto 0);
		I2_opr1_in:in std_logic_vector(15 downto 0);
		I2_opr2_in:in std_logic_vector(15 downto 0);
		I2_v1_in: in std_logic_vector(0 downto 0);
		I2_v2_in: in std_logic_vector(0 downto 0);
		I2_dest_reg_in: in std_logic_vector(5 downto 0);
		I2_opcode_in: in std_logic_vector(3 downto 0);
		I2_dec_in: in std_logic_vector(2 downto 0);
		I2_PC_in: in std_logic_vector(15 downto 0);
		I2_inst_num_in: in std_logic_vector(6 downto 0);
		
		lmsm: in std_logic;
		Iout1,Iout2,Iout3,Iout4,Iout5,Iout6,Iout7,Iout0: in std_logic_vector(43 downto 0);
		N: in integer;
		
		DBWrite_en1, DBWrite_en2, DBWrite_en3, DBWrite_en4, en_write: in std_logic;
		
		
	);
end backend;

architecture b1 of backend is
	
	entity rs is
		port(
			clk: in std_logic;
			rst: in std_logic;
			wr1: in std_logic;
			wr2: in std_logic;
			I1_opr1_in:in std_logic_vector(15 downto 0);
			I1_opr2_in:in std_logic_vector(15 downto 0);
			I1_v1_in: in std_logic_vector(0 downto 0);
			I1_v2_in: in std_logic_vector(0 downto 0);
			I1_dest_reg_in: in std_logic_vector(5 downto 0);
			I1_opcode_in: in std_logic_vector(3 downto 0);
			I1_dec_in: in std_logic_vector(2 downto 0);
			I1_PC_in: in std_logic_vector(15 downto 0);
			I1_inst_num_in: in std_logic_vector(6 downto 0);
			I2_opr1_in:in std_logic_vector(15 downto 0);
			I2_opr2_in:in std_logic_vector(15 downto 0);
			I2_v1_in: in std_logic_vector(0 downto 0);
			I2_v2_in: in std_logic_vector(0 downto 0);
			I2_dest_reg_in: in std_logic_vector(5 downto 0);
			I2_opcode_in: in std_logic_vector(3 downto 0);
			I2_dec_in: in std_logic_vector(2 downto 0);
			I2_PC_in: in std_logic_vector(15 downto 0);
			I2_inst_num_in: in std_logic_vector(6 downto 0);
			
			inst_cz: in std_logic_vector(6 downto 0); --alu pipeline
			cin: in std_logic; --alu pipeline
			zin: in std_logic; --alu pipeline
			
			--LMSM
			lmsm: in std_logic;
			Iout1,Iout2,Iout3,Iout4,Iout5,Iout6,Iout7,Iout0: in std_logic_vector(43 downto 0);
			N: in integer;
			
			--Writeback
			wb_din1: in std_logic_vector(15 downto 0); --ROB
			wb_Addrin1: in std_logic_vector(5 downto 0); --ROB
			wb_wr1: in std_logic; --ROB
			wb_din2: in std_logic_vector(15 downto 0); --ROB
			wb_Addrin2: in std_logic_vector(5 downto 0); --ROB
			wb_wr2: in std_logic; --ROB
			
			I1_opr1_out:out std_logic_vector(15 downto 0); --ALUp
			I1_opr2_out:out std_logic_vector(15 downto 0); --ALUp
			I1_dest_reg_out: out std_logic_vector(2 downto 0); --ALUp
			I1_opcode_out: out std_logic_vector(3 downto 0); --ALUp
			I1_dec_out: out std_logic_vector(2 downto 0); --ALUp
			I1_c: out std_logic;
			I1_z: out std_logic;
			
			I2_opr1_out:out std_logic_vector(15 downto 0);
			I2_opr2_out:out std_logic_vector(15 downto 0);
			I2_dest_reg_out: out std_logic_vector(2 downto 0);
			I2_opcode_out: out std_logic_vector(3 downto 0);
			I2_dec_out: out std_logic_vector(2 downto 0);
			I2_c: out std_logic;
			I2_z: out std_logic;
			
			I3_opr1_out:out std_logic_vector(15 downto 0);
			I3_opr2_out:out std_logic_vector(15 downto 0);
			I3_dest_reg_out: out std_logic_vector(2 downto 0);
			I3_opcode_out: out std_logic_vector(3 downto 0);
			I3_dec_out: out std_logic_vector(2 downto 0);
			I3_dest: out std_logic_vector(5 downto 0);
			
			I4_opr1_out:out std_logic_vector(15 downto 0);
			I4_opr2_out:out std_logic_vector(15 downto 0);
			I4_dest_reg_out: out std_logic_vector(2 downto 0);
			I4_opcode_out: out std_logic_vector(3 downto 0);
			I4_dec_out: out std_logic_vector(2 downto 0);
			I4_dest: out std_logic_vector(5 downto 0);
			
			inst_num1: out std_logic_vector(6 downto 0);
			inst_num2: out std_logic_vector(6 downto 0);
			inst_num3: out std_logic_vector(6 downto 0);
			inst_num4: out std_logic_vector(6 downto 0)
		);
	end component;
	
	component RoB is
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
	end component;
	
	component AL is 
		port(instruction: in std_logic_vector(40 downto 0);
			  Inum: in std_logic_vector(6 downto 0);
			  Inumrob: out std_logic_vector(6 downto 0);
			  clock: in std_logic;
			  result: out std_logic_vector(15 downto 0);
			  Carry,Zero: out std_logic;
			  forjlr: out std_logic_VECTOr(15 downto 0));
	end component;
	
	component ls_pipeline is
		port(
			clk: in std_logic;
			clr: in std_logic;
			wr_reg: in std_logic;
			inst_num_in: in integer;
			inst_opcode_in: in std_logic_vector(3 downto 0);
			opr1: in std_logic_vector(15 downto 0);
			opr2: in std_logic_vector(15 downto 0);
			mem_data_in: in std_logic_vector(15 downto 0);
			sq_data_in: in std_logic_vector(15 downto 0);
			s_m2: in std_logic_vector(1 downto 0);
			
			inst_num_out: out integer;
			inst_opcode_out: out std_logic_vector(3 downto 0);
			mem_addr_out: out std_logic_vector(15 downto 0);
			data_out: out std_logic_vector(15 downto 0)
		);
	end component;
	
	component LS_Queue is 
		port(
			clk, reset: in std_logic; --In
			
			--Write new entry
			wr1: in std_logic; --controller
			I1_num_in: in integer; --Dispatch buffer
			l1_flag: in std_logic; --Dispatch buffer
			wr2: in std_logic; --controller
			I2_num_in: in integer; --Dispatch buffer
			l2_flag: in std_logic; --Dispatch buffer
			
			--Update valid bit
			I3_num_in: in integer; --LS_Pipeline
			I3_addr: in std_logic_vector(15 downto 0); --LS_pipeline
			l3_flag: in std_logic; --LS_Pipeline
			I3_store_val: in std_logic_vector(15 downto 0); --LS_pipeline
			I4_num_in: in integer; --LS_Pipeline
			I4_addr: in std_logic_vector(15 downto 0); --LS_pipeline
			l4_flag: in std_logic; --LS_Pipeline
			I4_store_val: in std_logic_vector(15 downto 0); --LS_pipeline
			
			sel: out std_logic_vector(1 downto 0); --LS_pipeline
			load_val: out std_logic_vector(15 downto 0) --LS_pipeline
			-- if the entry is available in the store queue, use that value in the load instr
		);
	end component;
	
	component Dmem is
		port (clock : in std_logic;
				Write_Enable1 : in std_logic;
				Write_Address1 : in std_logic_vector(15 downto 0);
				Read_Address1 : in std_logic_vector(15 downto 0);
				Write_Data_In1 : in std_logic_vector(15 downto 0);
				Read_Data_Out1 : out std_logic_vector(15 downto 0);
				Write_Enable2 : in std_logic;
				Write_Address2 : in std_logic_vector(15 downto 0);
				Read_Address2 : in std_logic_vector(15 downto 0);
				Write_Data_In2 : in std_logic_vector(15 downto 0);
				Read_Data_Out2 : out std_logic_vector(15 downto 0));
	end component;
	
	signal inst_cz: std_logic_vector(6 downto 0);
	signal cin,zin: in std_logic;
	
begin
	reservation_stn: rs port map (clk=>clk,rst=>rst,wr1=>wr1,wr2=>wr2,I1_opr1_in=>I1_opr1_in,I1_opr2_in=>I1_opr2_in,
											I1_v1_in=>I1_v1_in,I1_v2_in=>I1_v2_in,I1_dest_reg_in=>I1_dest_reg_in,
											I1_opcode_in=>I1_opcode_in,I1_dec_in=>I1_dec_in,I1_PC_in=>I1_PC_in,
											I1_inst_num_in=>I1_inst_num_in,I2_opr1_in=>I2_opr1_in,I2_opr2_in=>I2_opr2_in,
											I2_v1_in=>I2_v1_in,I2_v2_in=>I2_v2_in,I2_dest_reg_in=>I2_dest_reg_in,
											I2_opcode_in=>I2_opcode_in,I2_dec_in=>I2_dec_in,I2_PC_in=>I2_PC_in,
											I2_inst_num_in=>I2_inst_num_in,inst_cz=>inst_cz,cin=>cin,zin=>zin,lmsm=>lmsm,
											
			
			inst_cz: in std_logic_vector(6 downto 0); --alu pipeline
			cin: in std_logic; --alu pipeline
			zin: in std_logic; --alu pipeline
			
			--LMSM
			lmsm: in std_logic;
			Iout1,Iout2,Iout3,Iout4,Iout5,Iout6,Iout7,Iout0: in std_logic_vector(43 downto 0);
			N: in integer;
			
			--Writeback
			wb_din1: in std_logic_vector(15 downto 0); --ROB
			wb_Addrin1: in std_logic_vector(5 downto 0); --ROB
			wb_wr1: in std_logic; --ROB
			wb_din2: in std_logic_vector(15 downto 0); --ROB
			wb_Addrin2: in std_logic_vector(5 downto 0); --ROB
			wb_wr2: in std_logic; --ROB
			
			I1_opr1_out:out std_logic_vector(15 downto 0); --ALUp
			I1_opr2_out:out std_logic_vector(15 downto 0); --ALUp
			I1_dest_reg_out: out std_logic_vector(2 downto 0); --ALUp
			I1_opcode_out: out std_logic_vector(3 downto 0); --ALUp
			I1_dec_out: out std_logic_vector(2 downto 0); --ALUp
			I1_c: out std_logic;
			I1_z: out std_logic;
			
			I2_opr1_out:out std_logic_vector(15 downto 0);
			I2_opr2_out:out std_logic_vector(15 downto 0);
			I2_dest_reg_out: out std_logic_vector(2 downto 0);
			I2_opcode_out: out std_logic_vector(3 downto 0);
			I2_dec_out: out std_logic_vector(2 downto 0);
			I2_c: out std_logic;
			I2_z: out std_logic;
			
			I3_opr1_out:out std_logic_vector(15 downto 0);
			I3_opr2_out:out std_logic_vector(15 downto 0);
			I3_dest_reg_out: out std_logic_vector(2 downto 0);
			I3_opcode_out: out std_logic_vector(3 downto 0);
			I3_dec_out: out std_logic_vector(2 downto 0);
			I3_dest: out std_logic_vector(5 downto 0);
			
			I4_opr1_out:out std_logic_vector(15 downto 0);
			I4_opr2_out:out std_logic_vector(15 downto 0);
			I4_dest_reg_out: out std_logic_vector(2 downto 0);
			I4_opcode_out: out std_logic_vector(3 downto 0);
			I4_dec_out: out std_logic_vector(2 downto 0);
			I4_dest: out std_logic_vector(5 downto 0);
			
			inst_num1: out std_logic_vector(6 downto 0);
			inst_num2: out std_logic_vector(6 downto 0);
			inst_num3: out std_logic_vector(6 downto 0);
			inst_num4: out std_logic_vector(6 downto 0))
