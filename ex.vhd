library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use work.cpu_pkg.all;

entity ex is
	port(
		clk : in std_logic;
		reset : in std_logic;
		data_in : in decoded_instructon;
		ex_data : out pass_data;
		data_out : out decoded_instructon
	);
	
end entity ex;


architecture RTL of ex is
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

alu:process(data_in,results_reg) is 
variable temp_result : word_t;
begin
	results_next <= data_in;
	ex_data.opcode <= data_in.opcode;
	ex_data.dst <= data_in.rd;
	ex_data.flush <= data_in.flush;
	temp_result := (others =>'0');
	
	
	case To_integer(Unsigned(data_in.opcode)) is
		when LOAD.opcode 
			=> temp_result := Std_logic_vector(Signed(data_in.rs1_value) + Signed(data_in.immediate));
		when STORE.opcode 
			=> temp_result := Std_logic_vector(Signed(data_in.rs1_value) + Signed(data_in.immediate));
		when MOV.opcode
			=> temp_result := data_in.rs1_value;
		when MOVI.opcode
			=> temp_result(15 downto 0) := data_in.immediate;
			   temp_result(31 downto 16) :=  data_in.rs2_value(31 downto 16);
		when ADD.opcode
			=> temp_result := Std_logic_vector(Signed(data_in.rs1_value) + Signed(data_in.rs2_value));
		when ISUB.opcode
			=> temp_result := Std_logic_vector(Signed(data_in.rs1_value) - Signed(data_in.rs2_value));
		when ADDI.opcode
			=> temp_result := Std_logic_vector(Signed(data_in.rs1_value) + Signed(data_in.immediate));
		when SUBI.opcode
			=> temp_result := Std_logic_vector(Signed(data_in.rs1_value) - Signed(data_in.immediate));
		when IAND.opcode
			=> temp_result := Std_logic_vector(Signed(data_in.rs1_value) AND Signed(data_in.rs2_value));
		when IOR.opcode
			=> temp_result := Std_logic_vector(Signed(data_in.rs1_value) OR Signed(data_in.rs2_value));
		when IXOR.opcode
			=> temp_result := Std_logic_vector(Signed(data_in.rs1_value) XOR Signed(data_in.rs2_value));
		when INOT.opcode
			=> temp_result := Std_logic_vector(NOT Signed(data_in.rs1_value));
		when ISHL.opcode
			=> temp_result := Std_logic_vector(Unsigned(data_in.rs2_value) SLL To_integer(Unsigned(data_in.immediate)));
		when ISHR.opcode
			=> temp_result := Std_logic_vector(Unsigned(data_in.rs2_value) SRL To_integer(Unsigned(data_in.immediate)));
		when SAR.opcode
			=> temp_result := To_StdLogicVector(to_bitvector(data_in.rs2_value) SRA To_integer(Unsigned(data_in.immediate)));
		when IROL.opcode
			=> temp_result := To_StdLogicVector(to_bitvector(data_in.rs2_value) ROL To_integer(Unsigned(data_in.immediate)));
		when IROR.opcode
			=> temp_result := To_StdLogicVector(to_bitvector(data_in.rs2_value) ROR To_integer(Unsigned(data_in.immediate)));
		when JMP.opcode | JSR.opcode 
			=> temp_result := Std_logic_vector(Unsigned(data_in.rs1_value) + Unsigned(data_in.immediate));
		when RTS.opcode
			=> null; 
		when PUSH.opcode
			=> null;
		when POP.opcode
			=> null;
		when BEQ.opcode | BNQ.opcode | BGT.opcode | BLT.opcode | BGE.opcode | BLE.opcode
			=> temp_result := Std_logic_vector(Unsigned(data_in.rs1_value) - Unsigned(data_in.rs2_value));
		when HALT.opcode
			=> null;
		when others
			=> null;
	end case;
	ex_data.dst_value <= temp_result;
	results_next.result <= temp_result;
end process alu;
	
	data_out <= results_reg;


end RTL;