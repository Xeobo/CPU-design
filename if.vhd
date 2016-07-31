library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

use work.cpu_pkg.all;

entity instucton_fetch is
	port(
			clk :	in std_logic := '0';
			reset :in std_logic := '0';
			pc_start : in word_t := (others => '0');
			stall : in std_logic;
			cpu_pc : out word_t;
			rd : out std_logic
	);

end entity instucton_fetch;

architecture RTL of  instucton_fetch is
	signal pc_reg, pc_next: word_t;
	signal state_reg,state_next : std_logic;
	
begin
	clock:process(clk,reset,pc_start) is
	begin
		if(reset = '1')then
			pc_reg <= pc_start;
		elsif(rising_edge(clk))then
			pc_reg <= pc_next;
			state_reg <= state_next;
		end if;	
	end process clock;
	
	next_clk:process(pc_reg,stall) is
	begin
		
		if(stall = '0') then
			pc_next <= Std_logic_vector(Unsigned(pc_reg) + 1);
		else
			pc_next <= pc_reg;
		end if;
	end process next_clk;
	
	
	
	rd <= '1';
	
	cpu_pc <= pc_reg;

end RTL;