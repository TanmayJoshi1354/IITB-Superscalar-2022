library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity backend is
	port(
		clk: in std_logic;
		rst: in std_logic;
		wr1_rs: in std_logic;
		wr2_rs: in std_logic;
		clr_ls: in std_logic;
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
		
		wr1_lsq, wr2_lsq: in std_logic;
		I1_num_in: in std_logic_vector(6 downto 0); --Dispatch buffer
		l1_flag: in std_logic; --Dispatch buffer
		I2_num_in: in std_logic_vector(6 downto 0); --Dispatch buffer
		l2_flag: in std_logic; --Dispatch buffer
		
		d_in1, d_in2: in std_logic_vector(53 downto 0);
		dout1, dout2: out std_logic_vector(15 downto 0);
		dest1, dest2: out std_logic_vector(5 downto 0);
		wr1_prf, wr2_prf: out std_logic;
		rob_full: out integer;
		
		forjlr_alu1: out std_logic_vector(15 downto 0);
		forjlr_alu2: out std_logic_vector(15 downto 0)
	);
end backend;

architecture b1 of backend is
	
	component rs is
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
			d_DB1, d_DB2, d_DB3, d_DB4: in std_logic_vector(15 downto 0);--for the result coming in from the four pipelines
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
			inst_num_in: in std_logic_vector(6 downto 0);
			inst_opcode_in: in std_logic_vector(3 downto 0);
			opr1: in std_logic_vector(15 downto 0);
			opr2: in std_logic_vector(15 downto 0);
			mem_data_in: in std_logic_vector(15 downto 0);
			sq_data_in: in std_logic_vector(15 downto 0);
			s_m2: in std_logic_vector(1 downto 0);
			
			inst_num_out: out std_logic_vector(6 downto 0);
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
	
	signal inst_cz,I1_num, I2_num, I3_num, I4_num,I1_numrob, I2_numrob, I3_numrob, I4_numrob: std_logic_vector(6 downto 0);
	signal cin,zin: std_logic;
	signal wb_d1, wb_d2, I1_opr1_alu, I1_opr2_alu, I2_opr1_alu, I2_opr2_alu, I3_opr1_ls, I3_opr2_ls, I4_opr1_ls, I4_opr2_ls: std_logic_vector(15 downto 0);
	signal wb_addr1, wb_addr2, I3_dest, I4_dest: std_logic_vector(5 downto 0);
	signal wb_wr1, wb_wr2, wr_ls_reg1,wr_ls_reg2: std_logic;
	signal I1_opcode,I2_opcode,I3_opcode,I4_opcode, I3_opcode_out, I4_opcode_out: std_logic_vector(3 downto 0);
	signal I1_dr,I2_dr,I3_dr,I4_dr: std_logic_vector(2 downto 0);
	signal I1_dec, I2_dec, I3_dec, I4_dec: std_logic_vector(2 downto 0);
	signal I1_c,I1_z,I2_c,I2_z: std_logic;
	signal res_alu1, res_alu2: std_logic_vector(15 downto 0);
	signal c_alu1, c_alu2, z_alu1, z_alu2: std_logic;
	signal clr_lsp: std_logic;
	signal sel_ls1,sel_ls2: std_logic_vector(1 downto 0);
	signal mem_data_ls1, mem_data_ls2, sq_data_ls1, sq_data_ls2: std_logic_vector(15 downto 0);
	signal memrob_ls1, datarob_ls1,memrob_ls2, datarob_ls2: std_logic_vector(15 downto 0);
	signal l3_flag, l4_flag: std_logic;
	
	signal drob1, drob2: std_logic_vector(15 downto 0);
	signal mem1, mem2: std_logic_vector(15 downto 0);
	signal wr1_mem, wr2_mem: std_logic;
			 
	signal rob_empty: std_logic;
	signal rob_index: integer;
	
begin
	reservation_stn: rs port map (clk=>clk,rst=>rst,wr1=>wr1_rs,wr2=>wr2_rs,I1_opr1_in=>I1_opr1_in,I1_opr2_in=>I1_opr2_in,
											I1_v1_in=>I1_v1_in,I1_v2_in=>I1_v2_in,I1_dest_reg_in=>I1_dest_reg_in,
											I1_opcode_in=>I1_opcode_in,I1_dec_in=>I1_dec_in,I1_PC_in=>I1_PC_in,
											I1_inst_num_in=>I1_inst_num_in,I2_opr1_in=>I2_opr1_in,I2_opr2_in=>I2_opr2_in,
											I2_v1_in=>I2_v1_in,I2_v2_in=>I2_v2_in,I2_dest_reg_in=>I2_dest_reg_in,
											I2_opcode_in=>I2_opcode_in,I2_dec_in=>I2_dec_in,I2_PC_in=>I2_PC_in,
											I2_inst_num_in=>I2_inst_num_in,inst_cz=>inst_cz,cin=>cin,zin=>zin,lmsm=>lmsm,
											Iout1=>Iout1,Iout2=>Iout2,Iout3=>Iout3,Iout4=>Iout4,Iout5=>Iout5,Iout6=>Iout6,
											Iout7=>Iout7,Iout0=>Iout0,N=>N,wb_din1=>wb_d1,wb_Addrin1=>wb_addr1,wb_wr1=>wb_wr1,
											wb_din2=>wb_d2,wb_Addrin2=>wb_addr2,wb_wr2=>wb_wr2,I1_opr1_out=>I1_opr1_alu,
											I1_opr2_out=>I1_opr2_alu,I2_opr1_out=>I2_opr1_alu,I2_opr2_out=>I2_opr2_alu,
											I1_dest_reg_out=>I1_dr,I1_opcode_out=>I1_opcode,I1_dec_out=>I1_dec,I1_c=>I1_c,
											I1_z=>I1_z,I2_dest_reg_out=>I2_dr,I2_opcode_out=>I2_opcode,I2_dec_out=>I2_dec,
											I2_c=>I2_c,I2_z=>I2_z,I3_opr1_out=>I3_opr1_ls,I3_opr2_out=>I3_opr2_ls,
											I3_dest_reg_out=>I3_dr,I3_opcode_out=>I3_opcode,I3_dec_out=>I3_dec,
											I3_dest=>I3_dest,I4_opr1_out=>I4_opr1_ls,I4_opr2_out=>I4_opr2_ls,
											I4_dest_reg_out=>I4_dr,I4_opcode_out=>I4_opcode,I4_dec_out=>I4_dec,
											I4_dest=>I4_dest,inst_num1=>I1_num,inst_num2=>I2_num,inst_num3=>I3_num,
											inst_num4=>I4_num);
											
	ALB_Pipeline1: AL port map(instruction=>(I1_opcode & I1_opr1_alu & I1_opr2_alu & I1_c & I1_z & I1_dec),
										Inum=>I1_num,Inumrob=>I1_numrob,clock=>clk,result=>res_alu1,Carry=>c_alu1,
										Zero=>z_alu1,forjlr=>forjlr_alu1);
										
	ALB_Pipeline2: AL port map(instruction=>(I2_opcode & I2_opr1_alu & I2_opr2_alu & I2_c & I2_z & I2_dec),
										Inum=>I2_num,Inumrob=>I2_numrob,clock=>clk,result=>res_alu2,Carry=>c_alu2,
										Zero=>z_alu2,forjlr=>forjlr_alu2);
										
	LS_Pipeline1: ls_pipeline port map(clk=>clk,clr=>clr_lsp,wr_reg=>wr_ls_reg1,inst_num_in=>I3_num,
												  inst_opcode_in=>I3_opcode,opr1=>I3_opr1_ls,opr2=>I3_opr2_ls,
												  mem_data_in=>mem_data_ls1,sq_data_in=>sq_data_ls1,s_m2=>sel_ls1,
												  inst_num_out=>I3_numrob,inst_opcode_out=>I3_opcode_out,
												  mem_addr_out=>memrob_ls1,data_out=>datarob_ls1);
	
	LS_Pipeline2: ls_pipeline port map(clk=>clk,clr=>clr_lsp,wr_reg=>wr_ls_reg2,inst_num_in=>I4_num,
												  inst_opcode_in=>I4_opcode,opr1=>I4_opr1_ls,opr2=>I4_opr2_ls,
												  mem_data_in=>mem_data_ls2,sq_data_in=>sq_data_ls2,s_m2=>sel_ls2,
												  inst_num_out=>I4_numrob,inst_opcode_out=>I4_opcode_out,
												  mem_addr_out=>memrob_ls2,data_out=>datarob_ls2);
	
	LSQ: LS_Queue port map(clk=>clk,reset=>rst,wr1=>wr1_lsq, wr2=>wr2_lsq, I1_num_in=>I1_num_in, l1_flag=>l1_flag,
								  I2_num_in=>I2_num_in,l2_flag=>l2_flag,I3_num_in=>I3_num,I3_addr=>memrob_ls1,l3_flag=>l3_flag,
								  I3_store_val=>datarob_ls1,I4_num_in=>I4_num,I4_addr=>memrob_ls2,l4_flag=>l4_flag,
								  I4_store_val=>datarob_ls2,sel1=>sel_ls1,sel2=>sel_ls2,load_val1=>sq_data_ls1,
								  load_val2=>sq_data_ls2);
	
	ROB: RoB port map(rst=>rst,clk=>clk,DBWrite_en1=>DBWrite_en1,DBWrite_en2=>DBWrite_en2,
							DBWrite_en3=>DBWrite_en3, DBWrite_en4=>DBWrite_en1,en_write=>DBWrite_en1,d_in1=>d_in1,
							d_in2=>d_in2,d_DB1=>res_alu1,d_DB2=>res_alu2,d_DB3=>datarob_ls1,d_DB4=>datarob_ls2,
							mem_addr3=>memrob_ls1,mem_addr4=>memrob_ls2,inum1=>I1_numrob,inum2=>I2_numrob,
							inum3=>I3_numrob,inum4=>I4_numrob,dout1=>drob1,dout2=>drob2,mem1=>mem1,mem2=>mem2,
							dest1=>dest1,dest2=>dest2,wr1_prf=>wr1_prf,wr2_prf=>wr2_prf,wr1_mem=>wr1_mem,wr2_mem=>wr2_mem,
							rob_full=>rob_full,rob_empty=>rob_empty,rob_index=>rob_index);
	
	Data_Mem: DMem port map(clock=>clk,Write_Enable1=>wr1_mem,Write_Address1=>mem1,Read_Address1=>memrob_ls1,
									Write_Data_In1=>drob1,Read_Data_Out1=>mem_data_ls1,Write_Enable2=>wr2_mem,
									Write_Address2=>mem2,Read_Address2=>memrob_ls2,Write_Data_In2=>drob2,
									Read_Data_Out2=>mem_data_ls2);

	
	process(rst, clr_ls,sel_ls1,sel_ls2,I3_opcode,I4_opcode)
	begin
		if(rst='1' or clr_ls='1') then
			clr_lsp<='1';
		else
			clr_lsp<='0';
		end if;
		if(sel_ls1="00") then
			wr_ls_reg1<='0';
		end if;
		if(sel_ls2="00") then
			wr_ls_reg2<='0';
		end if;
		if(I3_opcode="0100" or I3_opcode="0111") then
			l3_flag<='1';
		end if;
		if(I4_opcode="0100" or I4_opcode="0111") then
			l4_flag<='1';
		end if;
	end process;
											
end b1;