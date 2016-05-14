
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
	write_line_control : in in_signal_reg;
	write_line_data : in word_t;
	out_data : out decoded_instructon

	);
END COMPONENT;
BEGIN
	i1 : cpu
	PORT MAP (
-- list connections between master ports and signals
	clk => clk,
	write_line_control => write_line_control,
	write_line_data => write_line_data,
	out_data => out_data,
	reset => reset
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
  
  wait until clk'event and clk='1';
  write_line_data <= Std_logic_vector((To_unsigned(24,WORD_SIZE)));
	write_line_control.addr <= Std_logic_vector((To_unsigned(4,REGISTER_ADDRESS_WIDTH)));
	write_line_control.wr <= '1';
	
	wait until clk'event and clk='1';
  write_line_data <= Std_logic_vector((To_unsigned(26,WORD_SIZE)));
	write_line_control.addr <= Std_logic_vector((To_unsigned(6,REGISTER_ADDRESS_WIDTH)));
	write_line_control.wr <= '1';
	
  wait until clk'event and clk='1';
  write_line_data <= Std_logic_vector((To_unsigned(25,WORD_SIZE)));
	write_line_control.addr <= Std_logic_vector((To_unsigned(5,REGISTER_ADDRESS_WIDTH)));
	write_line_control.wr <= '1';
	
	wait until clk'event and clk='1';
	write_line_control.wr <= '0';
WAIT;                                                        
END PROCESS always;                                          
END cpu_arch;
