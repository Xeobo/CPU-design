library ieee;

use work.cpu_pkg.all;
use ieee.std_logic_1164.all;

entity cpu is
	port (
		clk, reset: in std_logic
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
	inst_cash : entity work.instr_cash(RTL) port map (in_ic, reset, clk, instruction, init_pc );
	
	cpu_no_cache : entity work.cpu_no_cache(RTL) port map (clk, reset, init_pc, instruction, write_back, write_data, in_dc, in_ic);
	
	data_cash_level : entity work.data_cash(RTL) port map (clk, reset, in_dc, write_data, write_back );

	
end RTL;
	
