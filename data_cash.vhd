library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.cpu_pkg.all;

entity data_cash is
	port(
		in_control : in in_signal_dc; 
		reset : in std_logic;
		clk : in std_logic;
		in_data : in word_t;
		out_data : out word_t
	);
end entity data_cash;


architecture RTL of data_cash is
	signal memory_reg, memory_next : data_memory_t;
	
	signal address_reg, address_next : word_t;
	
	function init_mem return data_memory_t is
		variable mem: data_memory_t;
		variable read_ok : boolean;
		variable bits : bit_vector( WORD_SIZE - 1 downto 0); 
		variable ads : word_t;
		FILE load_file : text open read_mode is "C:/Users/Xeobo/Desktop/courses/VLSI/VHDL/sims/data_cash/javni_test_data_in.txt";
		VARiable l: line;
	begin
		mem := (others => (others => '0'));
		while (not endfile(load_file)) loop
			readline(load_file, l);
			hread(l, ads,read_ok);
			report "procitano: " & integer'image(to_integer(unsigned(ads)));
			if not read_ok then
				report "error reading integer from line: "
				severity error;
			end if;
			
			
			read(l, bits,read_ok);
			report "procitano: " & integer'image(to_integer(unsigned(To_StdLogicVector(bits))));
			if not read_ok then
				report "error reading bit_vector from line: "
				severity error;
			end if;
			
			mem(To_integer(Unsigned(ads))) := To_StdLogicVector(bits);
		end loop;
		
		
		return mem;
	end function init_mem;
	
begin
	clock:process (clk,reset) is
		variable ret_val : data_memory_t;
	begin
		if(reset = '1')then
			ret_val := init_mem;
			memory_reg <= ret_val;
			address_reg <=  (others =>'0');
		elsif(clk'event and clk = '1')then
			memory_reg <= memory_next;
			address_reg <= address_next;
		end if;
	end process clock;
	
	con:process(in_control,memory_reg,in_data,address_reg) is
	begin
		memory_next <= memory_reg;
		address_next <= in_control.addr;
		
		if(in_control.wr = '1')then
			
			memory_next(to_integer(Unsigned(address_reg))) <= in_data;
		end if;
	end process con;
	
	out_data <= memory_reg(to_integer(Unsigned(address_reg)));
end RTL;