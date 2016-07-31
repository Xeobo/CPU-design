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
	
	signal stall : std_logic;
	
	signal id_source1_pass : std_logic;
	
	signal id_source1_value : word_t;
	
	signal id_source2_pass :  std_logic;
	
	signal id_source2_value : word_t;
	
	signal id_source1 : reg_address_t;
	
	signal id_source2 : reg_address_t;
	
	signal flush_mem :  std_logic;
	
	signal flush_wb :  std_logic;
	
	signal ex_pass : pass_data;
	
	signal mem_pass : pass_data;
	
	signal wb_pass : pass_data;
	
	signal id_opcode : opcode_t;
	
begin
	inst_cash : entity work.instr_cash(RTL) port map (in_ic, reset, clk, instruction, init_pc );
	
	if_level : entity work.instucton_fetch(RTL) port map (clk, reset, init_pc, stall, in_ic.addr, in_ic.rd );
	
	id_full_level : entity work.id_full(RTL) port map (clk, reset, instruction, write_line_control, write_line_data, stall, id_source1_pass, id_source1_value
					, id_source2_pass, id_source2_value, id_opcode, id_source1, id_source2, ex_data );
	
	ex_level : entity work.ex(RTL) port map (clk, reset, ex_data, ex_pass,mem_data );
	
	mem_level : entity work.mem(RTL) port map (clk, reset, flush_mem, mem_data, mem_pass, in_dc, write_data, wb_data );
	
	data_cash_level : entity work.data_cash(RTL) port map (clk, reset, in_dc, write_data, write_back );
	
	wb_level : entity work.wb(RTL) port map (clk, reset, flush_wb, wb_data, write_back, wb_pass, write_line_control, write_line_data, out_data );
	
	pass_level : entity work.pass(RTL) port map (clk, reset, id_opcode, id_source1, id_source2, ex_pass, mem_pass, wb_pass, id_source1_pass, id_source1_value 
					, id_source2_pass, id_source2_value, flush_mem, flush_wb, stall );
	
end RTL;
	
