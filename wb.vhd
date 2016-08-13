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
		flush_if_wb : out std_logic;
		wr : out std_logic;
		data_wr : out address_t
	);
	
end entity wb;


architecture RTL of wb is

begin

clock:process(clk,reset) is
begin
	if(reset = '1')then
		
	elsif(rising_edge(clk))then
		
	end if;
	
end process clock;	

alu:process(data_in,write_back,flush_wb) is 
begin
	rdwr_control.addr <= (others => '0');
	rdwr_control.wr <= '0';
	write_data <= (others => '0');
	
	wb_data.dst_value <= data_in.result;
	wb_data.dst <= data_in.rd;
	wb_data.opcode <= data_in.opcode;
	wb_data.flush <= '1';
	
	flush_if_wb <= '0';
	wr <= '0';
	data_wr <= (others => '0');
	
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
				=>
				flush_if_wb <= '1';
				wr <= '1';
				data_wr <= write_back;
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

end RTL;