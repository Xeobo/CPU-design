library ieee;

use work.cpu_pkg.all;
use ieee.std_logic_1164.all;

entity id_full is
	port (
		clk, reset: in std_logic;
		instruction : in word_t;
		line3 : in in_signal_reg;
		line3_out : in word_t;
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
	id_without_regfile : entity work.id_without_regfile(RTL) port map (clk, reset, instruction, out_data , line1, line1_out, line2, line2_out );
	
	reg_file : entity work.reg_file(RTL) port map (clk, reset, line1, line2, line3, line3_out, line1_out, line2_out);
	
	
end RTL;