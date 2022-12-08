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
		I2_opr1_in:in std_logic_vector(15 downto 0);
		I2_opr2_in:in std_logic_vector(15 downto 0);
		I2_v1_in: in std_logic_vector(0 downto 0);
		I2_v2_in: in std_logic_vector(0 downto 0);
		I2_dest_reg_in: in std_logic_vector(5 downto 0);
		I2_opcode_in: in std_logic_vector(3 downto 0);
		
		inst_cz: in integer;
		cin: in std_logic;
		zin: in std_logic;
		cz_dep: in std_logic_vector(1 downto 0);
		k1: in integer;
		k2: in integer;
		
		--LMSM
		lmsm: in std_logic;
		Iout1,Iout2,Iout3,Iout4,Iout5,Iout6,Iout7,Iout0: in std_logic_vector(43 downto 0);
		N: in integer;
		
		I1_opr1_out:out std_logic_vector(15 downto 0);
		I1_opr2_out:out std_logic_vector(15 downto 0);
		I1_dest_reg_out: out std_logic_vector(2 downto 0);
		I1_opcode_out: out std_logic_vector(3 downto 0);
		I2_opr1_out:out std_logic_vector(15 downto 0);
		I2_opr2_out:out std_logic_vector(15 downto 0);
		I2_dest_reg_out: out std_logic_vector(2 downto 0);
		I2_opcode_out: out std_logic_vector(3 downto 0);
		v: out std_logic_vector(99 downto 0);
		inst_num1: out integer;
		inst_num2: out integer
	);
end rs;

architecture rs1 of rs is
type rs_index is array(99 downto 0) of std_logic_vector(44 downto 0);
---Mapping of each entry: Opcode, OPR1, V1, OPR2, V2, Renamed Register index, V
type inst_index is array(0 to 99) of integer;
signal res_stn: rs_index;
signal inst: inst_index:=(others=>0);
shared variable i: integer:=0;
signal busy: std_logic_vector(99 downto 0):=(others=>'0');
signal entry: std_logic_vector(44 downto 0);
signal c: std_logic_vector(99 downto 0):=(others=>'0');
signal z: std_logic_vector(99 downto 0):=(others=>'0');
signal czv: std_logic_vector(99 downto 0):=(others=>'0');
signal temp: integer;
signal lmsm_tempcheck: std_logic_vector(43 downto 0):=(others=>'Z');

begin
process(clk, rst, wr1, wr2, clr, busy, cz_dep, c, z, entry, res_stn, inst)
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
end process;

process(k1, k2, res_stn, inst)
begin
	------Change if better method found, current method could stagnate ROB
		if(k1<100 and k1>=0) then
			I1_opr1_out<=res_stn(k1)(40 downto 25);
			I1_opr2_out<=res_stn(k1)(23 downto 8);
			--I1_dest_reg_out<=res_stn(k1)(5 downto 0);
			I1_opcode_out<=res_stn(k1)(44 downto 41);
			inst_num1<=inst(k1);
			busy(k1)<='0';
		end if;
		if(k2<100 and k2>=0) then
			I2_opr1_out<=res_stn(k2)(40 downto 25);
			I2_opr2_out<=res_stn(k2)(23 downto 8);
			--I1_dest_reg_out<=res_stn(k2)(5 downto 0);
			I2_opcode_out<=res_stn(k2)(44 downto 41);
			inst_num2<=inst(k2);
			busy(k2)<='0';
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