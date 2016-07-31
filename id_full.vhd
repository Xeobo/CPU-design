library ieee;

use work.cpu_pkg.all;
use ieee.std_logic_1164.all;

entity id_full is
	port (
		clk, reset: in std_logic;
		instruction : in word_t;
		line3 : in in_signal_reg;
		line3_out : in word_t;
		stall : in std_logic;
		id_source1_pass : in std_logic;
		id_source1_value : in word_t;
		id_source2_pass : in std_logic;
		id_source2_value : in word_t;
		id_opcode : out opcode_t;
		id_source1 : out reg_address_t;
		id_source2 : out reg_address_t;
		out_data : out decoded_instructon
	);
end entity id_full;

architecture RTL of id_full is
	signal in_ic : in_signal_ic;
	
	signal line1 : in_signal_reg;
	signal line1_out : word_t;
	signal line2 : in_signal_reg;
	signal line2_out : word_t;
	
begin
	id_without_regfile : entity work.id_without_regfile(RTL) port map (clk, reset, instruction, out_data , line1_out, line2_out,stall, 
									id_source1_pass, id_source1_value, id_source2_pass, id_source2_value, id_opcode, id_source1, id_source2, line1, line2 );
	
	reg_file : entity work.reg_file(RTL) port map (clk, reset, line1, line2, line3, line3_out, line1_out, line2_out);
	
	
end RTL;