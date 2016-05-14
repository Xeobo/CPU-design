library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.cpu_pkg.all;

entity instr_cash is
	port(
		in_signal : in in_signal_ic := (addr => (others => '0'), rd => '0' ); 
		reset : in std_logic := '0';
		clk : in std_logic := '0';
		out_data : out word_t;
		out_init_pc : out word_t
	);
end entity instr_cash;


architecture RTL of instr_cash is
	signal memory_reg, memory_next : memory_t;
	
	signal state_reg, state_next : std_logic;
	
	signal address_reg, address_next : word_t;
	
	function init_mem return return_init_mem is
		variable mem : return_init_mem;
		variable index, strlen: natural; 
		variable vl : integer;
		variable read_ok : boolean;
		variable bits : bit_vector( WORD_SIZE - 1 downto 0); 
		variable ads : word_t;
		FILE load_file : text open read_mode is "C:\Users\Xeobo\Desktop\courses\VLSI\VHDL\sims\instr_cash\javni_test_inst_in.txt";
		VARiable l: line;
	begin
		mem.pc := (others => '0');
		
		readline(load_file, l);
		hread(l,mem.pc,read_ok);
	    if not read_ok then
			report "error reading integer from line: "
			severity error;
		end if;

		--mem.pc := Std_logic_vector(To_unsigned(vl,WORD_SIZE));
		index := 0;
		while (not endfile(load_file)) loop
			readline(load_file, l);
			hread(l, ads,read_ok);
			report "procitano: " & integer'image(to_integer(unsigned(ads)));
			if not read_ok then
				report "error reading integer from line: "
				severity error;
			end if;
						
			
			read(l, bits,read_ok);
			report "procitano: " & integer'image(vl);
			if not read_ok then
				report "error reading bit_vector from line: "
				severity error;
			end if;
							
			mem.mem(To_integer(Unsigned(ads))) := To_StdLogicVector(bits);
			index := index + 1;
		end loop;
		
		
		return mem;
	end function init_mem;
	
begin
	clock:process (clk,reset) is
		variable ret_val : return_init_mem;
	begin
		if(reset = '1')then
			ret_val := init_mem;
			memory_reg <= ret_val.mem;
			out_init_pc <= ret_val.pc;
			state_reg <= '0';
			address_reg <=  (others =>'0');
		elsif(clk'event and clk = '1')then
			memory_reg <= memory_next;
			state_reg <= state_next;
			address_reg <= address_next;
			out_init_pc <= (others => '0');
		end if;
	end process clock;
	
	con:process(in_signal,memory_reg,state_reg,address_reg) is
	begin
		memory_next <= memory_reg;
		state_next <= state_reg;
		address_next <= address_reg;
		
		if(in_signal.rd = '1')then
			state_next <= '1';
			address_next <= in_signal.addr;
		end if;
		if(state_reg = '1') then
			state_next <= '0';
		end if;
	end process con;
	
	out_data <= memory_reg(to_integer(Unsigned(address_reg)));
end RTL;