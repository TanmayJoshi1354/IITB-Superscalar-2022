library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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
		I2_opr1_in:in std_logic_vector(15 downto 0);
		I2_opr2_in:in std_logic_vector(15 downto 0);
		I2_v1_in: in std_logic_vector(0 downto 0);
		I2_v2_in: in std_logic_vector(0 downto 0);
		I2_dest_reg_in: in std_logic_vector(5 downto 0);
		I2_opcode_in: in std_logic_vector(3 downto 0);
		I2_dec_in: in std_logic_vector(2 downto 0);
		
		inst_cz: in integer;
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
		
		inst_num1: out integer;
		inst_num2: out integer;
		inst_num3: out integer;
		inst_num4: out integer
	);
end rs;

architecture rs1 of rs is
type rs_index is array(99 downto 0) of std_logic_vector(44 downto 0);
---Mapping of each entry: Opcode, OPR1, V1, OPR2, V2, Renamed Register index, V
type inst_index is array(0 to 99) of integer;
type dec_index is array(0 to 99) of std_logic_vector(2 downto 0);
signal res_stn: rs_index;
signal inst: inst_index:=(others=>0);
signal v: std_logic_vector(99 downto 0);
shared variable i: integer:=0;
signal busy: std_logic_vector(99 downto 0):=(others=>'0');
signal entry: std_logic_vector(44 downto 0);
signal c: std_logic_vector(99 downto 0):=(others=>'0');
signal z: std_logic_vector(99 downto 0):=(others=>'0');
signal czv: std_logic_vector(99 downto 0):=(others=>'0');
signal dec: dec_index:=(others=>"000");
signal temp: integer;
signal lmsm_tempcheck: std_logic_vector(43 downto 0):=(others=>'Z');
signal opcode: std_logic_vector(3 downto 0);

begin
process(clk, rst, wr1, wr2, clr, busy, cz_dep, c, z, entry, res_stn, inst, v, dec, wb_wr1, wb_din1, wb-Addrin1, wb_wr2, wb_din2, wb_Addrin2)
variable k1,k2,k3,k4: integer;
begin
	if rising_edge(clk) then
		if(rst='1') then
			res_stn<=(others=>(others=>'0'));
			inst<=(others=>0);
			i:=0;
		elsif(lmsm='0') then
			if(clr='1') then
				res_stn<=(others=>(others=>'0'));
				inst<=(others=>0);
			elsif(wr1='1' or wr2='1') then
				if(wr1='1') then
					insert_entry1: for k in 0 to 99 loop
						if(busy(k)='0') then
							inst(k)<=i;
							res_stn(k)<=(I1_opcode_in & I1_opr1_in & I1_v1_in & I1_opr2_in & I1_v2_in & I1_dest_reg_in & I1_v1_in and I1_v2_in);
							dec(k)<=I1_dec_in;
							i:=i+1;
							busy(k)<='1';							
							exit;
						end if;
					end loop insert_entry1;
				end if;
				if(wr2='1') then
					insert_entry2: for k in 0 to 99 loop
						if(busy(k)='0') then
							inst(k)<=i;
							res_stn(k)<=(I2_opcode_in & I2_opr1_in & I2_v1_in & I2_opr2_in & I2_v2_in & I2_dest_reg_in & I2_v1_in and I2_v2_in);
							dec(k)<=I2_dec_in;
							i:=i+1;
							busy(k)<='1';							
							exit;
						end if;
					end loop insert_entry2;
				end if;
			end if;
		elsif(lmsm='1') then
			if(Iout0/=lmsm_tempcheck) then
				insert_entry3: for k in 0 to 99 loop
						if(busy(k)='0') then
							inst(k)<=i;
							res_stn(k)<=(Iout0 & Iout0(23 downto 23) and Iout0(6 downto 6));
							i:=i+1;
							busy(k)<='1';							
							exit;
						end if;
				end loop insert_entry3;
			end if;
			if(Iout1/=lmsm_tempcheck) then
				insert_entry4: for k in 0 to 99 loop
						if(busy(k)='0') then
							inst(k)<=i;
							res_stn(k)<=(Iout1 & Iout1(23 downto 23) and Iout1(6 downto 6));
							i:=i+1;
							busy(k)<='1';							
							exit;
						end if;
				end loop insert_entry4;
			end if;
			if(Iout2/=lmsm_tempcheck) then
				insert_entry5: for k in 0 to 99 loop
						if(busy(k)='0') then
							inst(k)<=i;
							res_stn(k)<=(Iout2 & Iout2(23 downto 23) and Iout2(6 downto 6));
							i:=i+1;
							busy(k)<='1';							exit;
						end if;
				end loop insert_entry5;
			end if;
			if(Iout3/=lmsm_tempcheck) then
				insert_entry6: for k in 0 to 99 loop
						if(busy(k)='0') then
							inst(k)<=i;
							res_stn(k)<=(Iout3 & Iout3(23 downto 23) and Iout3(6 downto 6));
							i:=i+1;
							busy(k)<='1';							exit;
						end if;
				end loop insert_entry6;
			end if;
			if(Iout4/=lmsm_tempcheck) then
				insert_entry7: for k in 0 to 99 loop
						if(busy(k)='0') then
							inst(k)<=i;
							res_stn(k)<=(Iout4 & Iout4(23 downto 23) and Iout4(6 downto 6));
							i:=i+1;
							busy(k)<='1';							exit;
						end if;
				end loop insert_entry7;
			end if;
			if(Iout5/=lmsm_tempcheck) then
				insert_entry8: for k in 0 to 99 loop
						if(busy(k)='0') then
							inst(k)<=i;
							res_stn(k)<=(Iout5 & Iout5(23 downto 23) and Iout5(6 downto 6));
							i:=i+1;
							busy(k)<='1';							exit;
						end if;
				end loop insert_entry8;
			end if;
			if(Iout6/=lmsm_tempcheck) then
				insert_entry9: for k in 0 to 99 loop
						if(busy(k)='0') then
							inst(k)<=i;
							res_stn(k)<=(Iout6 & Iout6(23 downto 23) and Iout6(6 downto 6));
							i:=i+1;
							busy(k)<='1';							exit;
						end if;
				end loop insert_entry9;
			end if;
			if(Iout7/=lmsm_tempcheck) then
				insert_entry10: for k in 0 to 99 loop
						if(busy(k)='0') then
							inst(k)<=i;
							res_stn(k)<=(Iout7 & Iout7(23 downto 23) and Iout7(6 downto 6));
							i:=i+1;
							busy(k)<='1';							exit;
						end if;
				end loop insert_entry10;
			end if;
		end if;	
		
	valid: for k in 0 to 99 loop
		entry<=res_stn(k);
		if(cz_dep="01" or cz_dep="10") then
			entry(0)<=entry(7) and entry(24) and c(k) and z(k);
		else
			entry(0)<=entry(7) and entry(24);
		end if;
		v(k)<=entry(0);
		res_stn(k)<=entry;
	end loop valid;
	
	k1:=100;
	k2:=100;
	k3:=100;
	k4:=100;
	check: for k in 0 to 99 loop
		opcode<=res_stn(k)(44 downto 41);
		if(opcode(3 downto 2)="00" or opcode(3 downto 2)="10") then
			if(busy(k)='1' and v(k)='1' and k1=100) then
				k1:=k;
			elsif(busy(k)='1' and v(k)='1' and k2=100) then
				k2:=k;
			end if;
		else
			if(busy(k)='1' and v(k)='1' and k3=100) then
				k3:=k;
			elsif(busy(k)='1' and v(k)='1' and k4=100) then
				k4:=k;
			end if;
			end if;
	end loop check;
	
	
	if(k1<100 and k1>=0) then
		I1_opr1_out<=res_stn(k1)(40 downto 25);
		I1_opr2_out<=res_stn(k1)(23 downto 8);
		I1_opcode_out<=res_stn(k1)(44 downto 41);
		I1_dec_out<=dec(k1);
		inst_num1<=inst(k1);
		I1_c<=c(k1);
		I1_z<=z(k1);
		busy(k1)<='0';
	end if;
	
	if(k2<100 and k2>=0) then
		I2_opr1_out<=res_stn(k2)(40 downto 25);
		I2_opr2_out<=res_stn(k2)(23 downto 8);
		I2_opcode_out<=res_stn(k2)(44 downto 41);
		I2_dec_out<=dec(k2);
		I2_c<=c(k1);
		I2_z<=z(k1);
		inst_num2<=inst(k2);
		busy(k2)<='0';
	end if;
	
	if(k3<100 and k3>=0) then
		I3_opr1_out<=res_stn(k3)(40 downto 25);
		I3_opr2_out<=res_stn(k3)(23 downto 8);
		I3_opcode_out<=res_stn(k3)(44 downto 41);
		I3_dec_out<=dec(k3);
		I3_dest<=res_stn(k3)(6 downto 1);
		inst_num3<=inst(k3);
		busy(k3)<='0';
	end if;
	
	if(k4<100 and k4>=0) then
		I4_opr1_out<=res_stn(k4)(40 downto 25);
		I4_opr2_out<=res_stn(k4)(23 downto 8);
		I4_opcode_out<=res_stn(k4)(44 downto 41);
		I4_dec_out<=dec(k4);
		I4_dest<=res_stn(k4)(6 downto 1);
		inst_num4<=inst(k4);
		busy(k4)<='0';
	end if;
	
	if(wb_wr1='1') then
		L1: for k in 0 to 99 loop
			if(res_stn(k)(24 downto 24)='0' and res_stn(k)(40 downto 25)=wb_Addrin1) then
				res_stn(k)(40 downto 25)<=wb_din1;
				res_stn(k)(24 downto 24)<='1';
			end if;
			if(res_stn(k)(7 downto 7)='0' and res_stn(k)(23 downto 8)=wb_Addrin1) then
				res_stn(k)(23 downto 8)<=wb_din1;
				res_stn(k)(7 downto 7)<='1';
			end if;
			if(res_stn(k)(24 downto 24)='0' and res_stn(k)(40 downto 25)=wb_Addrin2) then
				res_stn(k)(40 downto 25)<=wb_din2;
				res_stn(k)(24 downto 24)<='1';
			end if;
			if(res_stn(k)(7 downto 7)='0' and res_stn(k)(23 downto 8)=wb_Addrin2) then
				res_stn(k)(23 downto 8)<=wb_din2;
				res_stn(k)(7 downto 7)<='1';
			end if;
		end loop L2;
end if;
end process;

process(inst_cz, inst, cin, zin, inst, temp)
begin
	check: for k in 0 to 99 loop
		if(inst(k)>inst_cz) then
			c(k)<=cin;
			z(k)<=zin;
		end if;
		temp<=inst_cz+1;
		if(inst(k)=temp) then
			czv(k)<='1';
		end if;
	end loop check;
end process;

end rs1;