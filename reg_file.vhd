library ieee;

use work.cpu_pkg.all;

use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity reg_file is
	port (
		clk : in std_logic;
		reset : in std_logic;
		line1 : in in_signal_reg;
		line2 : in in_signal_reg;
		line3 : in in_signal_reg;
		line3_in : in word_t;
		line1_out : out word_t;
		line2_out : out word_t
	);
end entity reg_file;

architecture RTL of reg_file is
	signal registers_reg, registers_next : register_t;
		
	procedure readRegister(signal lineX : in in_signal_reg;signal lineX_out : out word_t ) is 
	begin
		
		lineX_out <= registers_reg(to_integer(Unsigned(lineX.addr)));
		
	end procedure;
	
	procedure writeRegister (signal reg : inout register_t;signal lineX : in in_signal_reg;signal lineX_in : in word_t ) is 
	begin
		if (lineX.wr = '1') then
			reg(to_integer(Unsigned(lineX.addr))) <= lineX_in;
		end if;
	end writeRegister;
begin
	clock:process(clk, reset) is 
	begin
		if(reset = '1')then 
			registers_reg <= (others => (others=>'0'));
		elsif(rising_edge(clk))then
			registers_reg <= registers_next;
		end if;
	end process clock;
	
	con: process(registers_next,line1, line2, line3, line3_in, registers_reg) is 
	begin
		registers_next <= registers_reg;
		writeRegister(registers_next,line3,line3_in);
		readRegister(line1,line1_out);
		readRegister(line2,line2_out);
	end process con;
end RTL;