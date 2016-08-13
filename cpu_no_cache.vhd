library ieee;

use work.cpu_pkg.all;
use ieee.std_logic_1164.all;

entity cpu_no_cache is
	port (
		clk, reset: in std_logic;
		init_pc : in word_t;
		instruction : in word_t;
		write_back : in word_t;
		write_data : out word_t;
		in_dc : out in_signal_dc;
		in_ic : out in_signal_ic
	);
end entity cpu_no_cache;

architecture RTL of cpu_no_cache is
	
	signal ex_data : decoded_instructon;
	
	signal mem_data : decoded_instructon;
	
	signal write_line_data : word_t;
	
	signal wb_data : decoded_instructon;
	
	signal write_line_control : in_signal_reg;
	
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
	
	signal wr_pc : std_logic;
	
	signal address : address_t;
	
	signal address_wr : address_t;
	
	signal data_wr : address_t;
	
	signal wr : std_logic;
	
	signal cpu_pc : std_logic;
	
	signal if_data : decoded_instructon;
	
	signal prediction_ok : std_logic;
	
	signal flush_if : std_logic;
	signal flush_id : std_logic;
	signal flush_ex : std_logic;
	
	signal flush_if_wb : std_logic;
	signal data_wr_wb : address_t;
	
	signal wr_wb : std_logic;
	signal bad_address : std_logic;
	
begin
	
	if_level : entity work.if_full(RTL) port map (clk, reset, wr_pc, address_wr, init_pc, stall, flush_if, flush_if_wb, data_wr, wr, bad_address,data_wr_wb, wr_wb, prediction_ok, in_ic.addr, in_ic.rd, if_data);
	
	id_full_level : entity work.id_full(RTL) port map (clk, reset, instruction, if_data, write_line_control, write_line_data, stall, flush_id, id_source1_pass, id_source1_value
					, id_source2_pass, id_source2_value, id_opcode, id_source1, id_source2, ex_data );
	
	ex_level : entity work.ex(RTL) port map (clk, reset, ex_data, flush_ex, ex_pass, mem_data );
	
	mem_level : entity work.mem(RTL) port map (clk, reset, flush_mem, mem_data, address_wr, data_wr, wr, bad_address, prediction_ok, wr_pc, mem_pass, in_dc, write_data, flush_if, flush_id, flush_ex, wb_data );
	
	wb_level : entity work.wb(RTL) port map (clk, reset, flush_wb, wb_data, write_back, wb_pass, write_line_control, write_line_data, flush_if_wb, wr_wb, data_wr_wb );
	
	pass_level : entity work.pass(RTL) port map (clk, reset, id_opcode, id_source1, id_source2, ex_pass, mem_pass, wb_pass, id_source1_pass, id_source1_value 
					, id_source2_pass, id_source2_value, flush_mem, flush_wb, stall );
	
end RTL;
	
