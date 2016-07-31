
LIBRARY ieee;                                               
USE ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;     
USE work.cpu_pkg.all;                          

ENTITY cpu_vhd_tst IS
END cpu_vhd_tst;
ARCHITECTURE cpu_arch OF cpu_vhd_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL clk : STD_LOGIC;
SIGNAL write_line_control : in_signal_reg;
SIGNAL write_line_data : word_t;
SIGNAL out_data :  decoded_instructon;
SIGNAL reset : STD_LOGIC;
COMPONENT cpu
	PORT (
	clk : IN STD_LOGIC;
	reset : IN STD_LOGIC;
	out_data : out decoded_instructon

	);
END COMPONENT;
BEGIN
	i1 : cpu
	PORT MAP (
-- list connections between master ports and signals
	clk => clk,
	reset => reset,
	out_data => out_data
	);
init : PROCESS                                               
variable clk_next : std_LOGIC := '1';
BEGIN  
                                    
	loop
		clk <= clk_next; 
		clk_next := not clk_next;
		wait for 5 ns;
	end loop;-- code that executes only once                      

END PROCESS init;                                           
always : PROCESS                                              
-- optional sensitivity list                                  
-- (        )                                                 
-- variable declarations                                      
BEGIN                                                         
  reset <= '1';
  wait for 1 ns;
  reset <= '0';
WAIT;                                                        
END PROCESS always;                                          
END cpu_arch;
