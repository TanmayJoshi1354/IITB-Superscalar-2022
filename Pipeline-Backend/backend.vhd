library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity backend is
	port(
		
	);
end backend;

architecture b1 of backend is
	
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
			I_opr8_out: out std_logic_vector(15 downto 0)
		);
	end component;
	
	entity rs is
		port(
			clk: in std_logic;
			rst: in std_logic;
			clr: in std_logic;
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
			
			inst_cz: in std_logic_vector(6 downto 0);
			cin: in std_logic;
			zin: in std_logic;
			cz_dep: in std_logic_vector(1 downto 0);
			
			--LMSM
			lmsm: in std_logic;
			Iout1,Iout2,Iout3,Iout4,Iout5,Iout6,Iout7,Iout0: in std_logic_vector(43 downto 0);
			N: in integer;
			
			--Writeback
			wb_din1: in std_logic_vector(15 downto 0);
			wb_Addrin1: in std_logic_vector(5 downto 0);
			wb_wr1: in std_logic;
			wb_din2: in std_logic_vector(15 downto 0);
			wb_Addrin2: in std_logic_vector(5 downto 0);
			wb_wr2: in std_logic;
			
			I1_opr1_out:out std_logic_vector(15 downto 0);
			I1_opr2_out:out std_logic_vector(15 downto 0);
			I1_dest_reg_out: out std_logic_vector(2 downto 0);
			I1_opcode_out: out std_logic_vector(3 downto 0);
			I1_dec_out: out std_logic_vector(2 downto 0);
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
	
	entity RoB is
		port(
			rst, clk, DBWrite_en1, DBWrite_en2, DBWrite_en3, en_write: in std_logic;--remove write enable if not needed
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