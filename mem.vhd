library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use work.cpu_pkg.all;

entity mem is
	port(
		clk : in std_logic;
		reset : in std_logic;
		flush_mem : in std_logic;
		data_in : in decoded_instructon;
		mem_data : out pass_data;
		rdwr_control : out in_signal_dc; 
		write_data : out word_t;
		data_out : out decoded_instructon
		
	);
	
end entity mem;


architecture RTL of mem is
signal results_reg, results_next : decoded_instructon;
signal sp_reg, sp_next : word_t;
begin

clock:process(clk,reset) is
begin
	if(reset = '1')then
		results_reg <= ('0',others =>(others => '0'));
		sp_reg <= Std_logic_vector((To_unsigned(65000,WORD_SIZE)));
	elsif(rising_edge(clk))then
		results_reg <= results_next;
		sp_reg <= sp_next;
	end if;
	
end process clock;

alu:process(data_in,sp_reg,flush_mem) is 
begin
	results_next <= data_in;
	sp_next <= sp_reg;
	rdwr_control.addr <= (others => '0');
	rdwr_control.wr <= '0';
	rdwr_control.hlt <= '0';
	write_data <= (others => '0');
	
	mem_data.dst_value <= data_in.result;
	mem_data.dst <= data_in.rd;
	mem_data.opcode <= data_in.opcode;
	mem_data.flush <= '1';
	
	if(data_in.flush = '0' AND flush_mem = '0' ) then
		mem_data.flush <= '0';
		case To_integer(Unsigned(data_in.opcode)) is
			when LOAD.opcode 
				=> rdwr_control.addr <= data_in.result;
				   rdwr_control.wr <= '0';--data is readed from data cache and then one clk after stored from data_cash to out_data.write_back
			when STORE.opcode 
				=> rdwr_control.addr <= data_in.result;
				   rdwr_control.wr <= '1';
				   write_data <= data_in.rs2_value;
			when MOV.opcode
				=> null;
			when MOVI.opcode
				=> null;
			when ADD.opcode
				=> null;
			when ISUB.opcode
				=> null;
			when ADDI.opcode
				=> null;
			when SUBI.opcode
				=> null;
			when IAND.opcode
				=> null;
			when IOR.opcode
				=> null;
			when IXOR.opcode
				=> null;
			when INOT.opcode
				=> null;
			when ISHL.opcode
				=> null;
			when ISHR.opcode
				=> null;
			when SAR.opcode
				=> null;
			when IROL.opcode
				=> null;
			when IROR.opcode
				=> null;
			when JMP.opcode | JSR.opcode 
				=> null;--from here value should be passed to instruction fetch brunch predictor
			when RTS.opcode
				=> sp_next <= Std_logic_vector(Unsigned(sp_reg) + 1);
				   rdwr_control.addr <= Std_logic_vector(Unsigned(sp_reg) + 1);
				   
				   rdwr_control.wr <= '0';--data is readed from data cache and then one clk after stored from data_cash to out_data.write_back
			when PUSH.opcode
				=> report "push-sp: " & integer'image(to_integer(unsigned(sp_reg)));
				   rdwr_control.addr <= sp_reg;
				   rdwr_control.wr <= '1';
				   write_data <= data_in.rs1_value;
				   sp_next <= Std_logic_vector(Unsigned(sp_reg) - 1);
				   
				   
			when POP.opcode
				=> report "pop-sp: " & integer'image(to_integer(unsigned(sp_reg)));
				   sp_next <= Std_logic_vector(Unsigned(sp_reg) + 1);
				   rdwr_control.wr <= '0';
				   rdwr_control.addr <= Std_logic_vector(Unsigned(sp_reg) + 1);
				   
			when BEQ.opcode | BNQ.opcode | BGT.opcode | BLT.opcode | BGE.opcode | BLE.opcode
				=> null;--from here value should be passed to instruction fetch brunch predictor
			when HALT.opcode
				=> rdwr_control.hlt <= '1';--when halt comes data from data_cash should be written in output file
			when others
				=> null;
		end case;
	end if;
end process alu;

data_out <= results_reg;

end RTL;