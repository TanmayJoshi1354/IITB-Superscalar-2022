library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;

entity ls_pipeline is
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
end ls_pipeline;

architecture ls1 of ls_pipeline is
	
	component adder is
		port(
			a: in std_logic_vector(15 downto 0);
			b: in std_logic_vector(15 downto 0);
			
			op: out std_logic_vector(15 downto 0)
		);
	end component;
	
	component AGMA_reg is
		port(
			clk: in std_logic;
			clr: in std_logic;
			wr: in std_logic;
			inst_num_in: in std_logic_vector(6 downto 0);
			mem_addr_in: in std_logic_vector(15 downto 0);
			inst_opcode_in: in std_logic_vector(3 downto 0);
			data_in:in std_logic_vector(15 downto 0);
			
			inst_num_out: out std_logic_vector(6 downto 0);
			mem_addr_out: out std_logic_vector(15 downto 0);
			inst_opcode_out: out std_logic_vector(3 downto 0);
			data_out: out std_logic_vector(15 downto 0)
		);
	end component;
	
	component mux41 is
		 port (
			  A0: in std_logic_vector(15 downto 0);
			  A1: in std_logic_vector(15 downto 0);
			  A2: in std_logic_vector(15 downto 0);
			  A3: in std_logic_vector(15 downto 0);
			  S: in std_logic_vector(1 downto 0);
			  Op: out std_logic_vector(15 downto 0)
		 ) ;
	end component;
	
	signal add_out: std_logic_vector(15 downto 0);
	signal m2_out: std_logic_vector(15 downto 0);
	signal data: std_logic_vector(15 downto 0);
	
begin
	a1: adder port map (a=>opr1,b=>opr2,op=>add_out);
	Intermediate_reg: AGMA_reg port map (clk=>clk, clr=>clr, wr=>wr_reg, inst_num_in=>inst_num_in, 
													mem_addr_in=>add_out, inst_opcode_in=>inst_opcode_in, data_in=>opr1,
													inst_num_out=>inst_num_out, mem_addr_out=>mem_addr_out,
													inst_opcode_out=>inst_opcode_out, data_out=>data);
	m2: mux41 port map (A0=>data, A1=>sq_data_in, A2=>mem_data_in, A3=>(others=>'0'), S=>s_m2, Op=>data_out);
		
end ls1;