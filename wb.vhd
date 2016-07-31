library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use work.cpu_pkg.all;

entity wb is
	port(
		clk : in std_logic;
		reset : in std_logic;
		flush_wb : in std_logic;
		data_in : in decoded_instructon;
		write_back : in word_t;
		wb_data : out pass_data;
		rdwr_control : out in_signal_reg; 
		write_data : out word_t;
		data_out : out decoded_instructon
		
	);
	
end entity wb;


architecture RTL of wb is
signal results_reg, results_next : decoded_instructon;
begin

clock:process(clk,reset) is
begin
	if(reset = '1')then
		results_reg <= ('0',others =>(others => '0'));
	elsif(rising_edge(clk))then
		results_reg <= results_next;
	end if;
	
end process clock;

alu:process(data_in,write_back,flush_wb) is 
begin
	results_next <= data_in;
	rdwr_control.addr <= (others => '0');
	rdwr_control.wr <= '0';
	write_data <= (others => '0');
	
	wb_data.dst_value <= data_in.result;
	wb_data.dst <= data_in.rd;
	wb_data.opcode <= data_in.opcode;
	wb_data.flush <= '1';
	
	if(data_in.flush = '0' AND flush_wb = '0' ) then
		wb_data.flush <= '0';
		case To_integer(Unsigned(data_in.opcode)) is
			when LOAD.opcode | POP.opcode
				=> wb_data.dst_value <= write_back;
				
				   rdwr_control.addr <= data_in.rd;
				   rdwr_control.wr <= '1';
				   write_data <= write_back;
			when STORE.opcode 
				=> null;
			when MOV.opcode | MOVI.opcode | ADD.opcode | ISUB.opcode | ADDI.opcode | SUBI.opcode | IXOR.opcode | INOT.opcode | ISHL.opcode |
				ISHR.opcode | SAR.opcode | IROL.opcode | IROR.opcode | IAND.opcode | IOR.opcode 
				=> rdwr_control.addr <= data_in.rd;
				   rdwr_control.wr <= '1';
				   write_data <= data_in.result;
			when JMP.opcode | JSR.opcode 
				=> null;
			when RTS.opcode
				=> null;
			when PUSH.opcode
				=> null;
			when BEQ.opcode | BNQ.opcode | BGT.opcode | BLT.opcode | BGE.opcode | BLE.opcode
				=> null;
			when HALT.opcode
				=> null;
			when others
				=> null;
		end case;
	end if;
end process alu;

data_out <= results_reg;

end RTL;