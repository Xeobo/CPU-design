library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.cpu_pkg.all;

entity id_without_regfile is 
	port(
		clk : in std_logic;
		reset : in std_logic;
		instruction : in word_t;
		data : out decoded_instructon;
		line1_control : out in_signal_reg;
		line1_data : in word_t;
		line2_control : out in_signal_reg;
		line2_data : in word_t
	);
	
end entity id_without_regfile;


architecture RTL of id_without_regfile is
	signal decoded_reg, decoded_next : decoded_instructon;
	
	procedure init_type1 (signal decode : out decoded_instructon; signal instruction : word_t) is
	begin
		decode.rd <= instruction(25 downto 21);
		decode.rs1 <= instruction(20 downto 16);
		decode.immediate <= instruction(15 downto 0);
	end init_type1;
	procedure init_type2 (signal decode : out decoded_instructon; signal instruction : word_t) is
	begin
		decode.rd <= instruction(25 downto 21);
		decode.rs1 <= instruction(20 downto 16);
		decode.rs2 <= instruction(15 downto 11);
	end init_type2;
	procedure init_type3 (signal decode : out decoded_instructon; signal instruction : word_t) is
	begin
		decode.rd <= instruction(25 downto 21);
		decode.rs1 <= instruction(20 downto 16);
	end init_type3;
	procedure init_type4 (signal decode : out decoded_instructon; signal instruction : word_t) is
	begin
		decode.rd	 <= instruction(25 downto 21);
		decode.immediate <= instruction(15 downto 0);
	end init_type4;
	procedure init_type5 (signal decode : out decoded_instructon; signal instruction : word_t) is
	begin
		decode.rs1 <= instruction(20 downto 16);
		decode.immediate <= instruction(15 downto 0);
	end init_type5;
	procedure init_type6 (signal decode : out decoded_instructon; signal instruction : word_t) is
	begin
		decode.rd <= instruction(25 downto 21);
		decode.immediate(4 downto 0) <= instruction(15 downto 11);
		decode.immediate(15 downto 5) <= (others => '0');
	end init_type6;
	procedure init_type7 (signal decode : out decoded_instructon; signal instruction : word_t) is
	begin
		decode.rs1 <= instruction(20 downto 16);
		decode.rs2 <= instruction(15 downto 11);
		
		decode.immediate(10 downto 0) <= instruction(10 downto 0);
		decode.immediate(15 downto 11) <= instruction(25 downto 21);
	end init_type7;
	procedure init_type8 (signal decode : out decoded_instructon; signal instruction : word_t) is
	begin
		decode.rd <= instruction(25 downto 21);
	end init_type8;
	procedure init_type9 (signal decode : out decoded_instructon; signal instruction : word_t) is
	begin
		decode.rs1 <= instruction(20 downto 16);
	end init_type9;
	procedure init_type10 (signal decode : out decoded_instructon; signal instruction : word_t) is
	begin
		
	end init_type10;
begin
	clock: process(reset,clk) is
	begin
		if(reset = '1')then 
			decoded_reg <= (others => (others=>'0'));
		elsif(rising_edge(clk))then
			decoded_reg <= decoded_next;
		end if;
	end process clock;
	
	con:process(line1_data,line2_data,decoded_reg,instruction) is
	begin
		decoded_next <= decoded_reg;
		
		case To_integer(Unsigned(instruction(31 downto 26))) is
			when LOAD.opcode| ADDI.opcode | SUBI.opcode
				=> init_type1(decoded_next,instruction);
			when ADD.opcode | ISUB.opcode | IAND.opcode | IOR.opcode | IXOR.opcode | INOT.opcode
				=> init_type2(decoded_next,instruction);
			when MOV.opcode 
				=> init_type3(decoded_next,instruction);
			when MOVI.opcode
				=> init_type4(decoded_next,instruction);
			when JMP.opcode | JSR.opcode 
				=> init_type5(decoded_next,instruction);
			when ISHL.opcode | ISHR.opcode | SAR.opcode | IROL.opcode | IROR.opcode 
				=> init_type6(decoded_next,instruction);
			when BEQ.opcode | BNQ.opcode | BGT.opcode | BLT.opcode | BGE.opcode | BLE.opcode | STORE.opcode
				=> init_type7(decoded_next,instruction);
			when POP.opcode 
				=> init_type8(decoded_next,instruction);
			when PUSH.opcode 
				=> init_type9(decoded_next,instruction);
			when RTS.opcode | HALT.opcode 
				=> init_type10(decoded_next,instruction);
			when others
				=> init_type10(decoded_next,instruction);
		end case;
		decoded_next.opcode <= instruction(31 downto 26);
		line1_control.addr <= instruction(20 downto 16);
		line2_control.addr <= instruction(15 downto 11);
		
		decoded_next.rs1_value <= line1_data;
		decoded_next.rs2_value <= line2_data;
		
	end process con;
	
	data <= decoded_reg;
end RTL;
