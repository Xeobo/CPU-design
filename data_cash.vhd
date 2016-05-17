library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.cpu_pkg.all;

entity data_cash is
	port(
		clk : in std_logic;
		reset : in std_logic;
		in_control : in in_signal_dc; 
		in_data : in word_t;
		out_data : out word_t
	);
end entity data_cash;


architecture RTL of data_cash is
	signal memory_reg, memory_next : data_memory_t;
	signal d_reg, d_next : std_logic_vector(DATA_MEM_SIZE_IN_WORDS -1 downto 0) ;
	
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
	procedure writeToOutput(signal mem : in data_memory_t;signal d : in  std_logic_vector(DATA_MEM_SIZE_IN_WORDS -1 downto 0))is
		FILE out_file : text open write_mode is "C:/Users/Xeobo/Desktop/courses/VLSI/VHDL/sims/data_cash/javni_test_data_out.txt";
		VARiable out_line: line;
		variable index : integer := 0;
	begin
		while( index < DATA_MEM_SIZE_IN_WORDS) loop
			if(d(index) = '1') then
				hwrite(out_line, std_logic_vector(to_unsigned(index, WORD_SIZE)),left,9);
				
				write(out_line, mem(index),left,32);
				
				writeline(out_file, out_line);
			end if;
			index := index + 1;
		end loop;
		
	end procedure writeToOutput;
	
begin
	clock:process (clk,reset) is
		variable ret_val : data_memory_t;
	begin
		if(reset = '1')then
			ret_val := init_mem;
			memory_reg <= ret_val;
			address_reg <=  (others =>'0');
			d_reg <= (others =>'0');
		elsif(clk'event and clk = '1')then
			memory_reg <= memory_next;
			address_reg <= address_next;
			d_reg <= d_next;
		end if;
	end process clock;
	
	con:process(in_control,memory_reg,in_data,address_reg) is
	begin
		memory_next <= memory_reg;
		address_next <= in_control.addr;
		d_next <= d_reg;
		
		report "address: " & integer'image(to_integer(unsigned(in_control.addr)));
		if(in_control.hlt = '1')then
			writeToOutput(memory_reg,d_reg);
		elsif(in_control.wr = '1')then
			
			memory_next(to_integer(Unsigned(in_control.addr))) <= in_data;
			d_next(to_integer(Unsigned(in_control.addr))) <= '1';
			
		end if;
	end process con;
	
	out_data <= memory_reg(to_integer(Unsigned(address_reg)));
end RTL;