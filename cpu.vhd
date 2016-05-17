  library ieee;

use work.cpu_pkg.all;
use ieee.std_logic_1164.all;

entity cpu is
	port (
		clk, reset: in std_logic;
		out_data : out decoded_instructon
	);
end entity cpu;

architecture RTL of cpu is
	signal in_ic : in_signal_ic;
	
	signal in_dc : in_signal_dc;
	
	signal init_pc : word_t;
	
	signal ex_data : decoded_instructon;
	
	signal write_data : word_t;
	
	signal mem_data : decoded_instructon;
	
	signal instruction : word_t;
	
	signal write_line_data : word_t;
	
	signal wb_data : decoded_instructon;
	
	signal write_line_control : in_signal_reg;
	
	signal write_back : word_t;
	
begin
	inst_cash : entity work.instr_cash(RTL) port map (in_ic, reset, clk, instruction , init_pc );
	
	if_level : entity work.instucton_fetch(RTL) port map (clk, reset, init_pc, in_ic.addr, in_ic.rd );
	
	id_full_level : entity work.id_full(RTL) port map (clk, reset, instruction, write_line_control, write_line_data, ex_data );
	
	ex_level : entity work.ex(RTL) port map (clk, reset, ex_data, mem_data );
	
	mem_level : entity work.mem(RTL) port map (clk, reset, mem_data, in_dc, write_data, wb_data );
	
	data_cash_level : entity work.data_cash(RTL) port map (clk, reset, in_dc, write_data, write_back );
	
	wb_level : entity work.wb(RTL) port map (clk, reset, wb_data, write_back, write_line_control, write_line_data, out_data );
	
end RTL;
	
