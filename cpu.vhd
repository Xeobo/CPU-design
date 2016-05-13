library ieee;

use work.cpu_pkg.all;
use ieee.std_logic_1164.all;

entity cpu is
	port (
		clk, reset: in std_logic;
		write_line_control : in in_signal_reg;
		write_line_data : in word_t;
		out_data : out decoded_instructon
	);
end entity cpu;

architecture RTL of cpu is
	signal in_ic : in_signal_ic;
	
	signal init_pc : word_t;
	
	signal instruction : word_t;
	
begin
	inst_cash : entity work.instr_cash(RTL) port map (in_ic, reset, clk, instruction , init_pc );
	
	if_level : entity work.instucton_fetch(RTL) port map (clk, reset, init_pc, in_ic.addr, in_ic.rd );
	
	id_full_level : entity work.id_full(RTL) port map (clk, reset, instruction, write_line_control, write_line_data, out_data );
	
	
end RTL;
	
