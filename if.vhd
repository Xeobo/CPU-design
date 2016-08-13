library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

use work.cpu_pkg.all;

entity instucton_fetch is
	port(
			clk :	in std_logic := '0';
			reset :in std_logic := '0';
			prediction :in std_logic;
			prediction_valid :in std_logic;
			predicted_adr :in address_t;
			wr_pc :in std_logic;
			wr_pc_start :in std_logic;
			address_wr : in address_t;
			wr_pc_wb : in std_logic;
			address_wr_wb : in address_t;
			pc_start : in word_t := (others => '0');
			stall : in std_logic;
			flush : in std_logic;
			flush_wb : in std_logic;
			cpu_pc : out word_t;
			address : out address_t;
			out_data : out decoded_instructon
	);

end entity instucton_fetch;

architecture RTL of  instucton_fetch is
	signal pc_reg, pc_next: word_t;
	signal instr_data_reg, instr_data_next : decoded_instructon; 
	
begin
	clock:process(clk,reset) is
	begin
		if(reset = '1')then
			pc_reg <= (others => '0');
			instr_data_reg <= INIT_DECODED_INSTRUCTION;
			instr_data_reg.flush <= '1';
		elsif(rising_edge(clk))then
			pc_reg <= pc_next;
			instr_data_reg <= instr_data_next;
		end if;	
	end process clock;
	
	next_clk:process(pc_reg,stall,flush,wr_pc,prediction,address_wr,flush_wb,wr_pc_wb,address_wr_wb,instr_data_reg, 
						prediction_valid, predicted_adr, wr_pc_start, pc_start) is
	begin
		instr_data_next <= instr_data_reg;
		address <= pc_reg;
		instr_data_next.flush <= flush or flush_wb;
		
		pc_next <= pc_reg;
		
		if(stall = '0') then
			if(wr_pc_wb = '1') then
				pc_next<= address_wr_wb;
			elsif(wr_pc = '1') then
				pc_next<= address_wr;
			else
				if(prediction_valid = '1') then
					pc_next <= predicted_adr;
				else
					pc_next <= Std_logic_vector(Unsigned(pc_reg) + 1);
				end if;
				instr_data_next.prediction <= prediction;
				instr_data_next.pc <= pc_reg;
				instr_data_next.pc_plus_one <= Std_logic_vector(Unsigned(pc_reg) + 1);
				instr_data_next.predicted_address <= predicted_adr;
			end if;
		end if;
		
		if(wr_pc_start = '1')then
			pc_next <= pc_start;
		end if;
	end process next_clk;
	
	out_data <= instr_data_reg;
	
	cpu_pc <= pc_reg;

end RTL;