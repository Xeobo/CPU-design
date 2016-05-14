library ieee;
use ieee.std_logic_1164.all;

package cpu_pkg is

constant WORD_SIZE : integer := 32;

constant REGISTER_COUNT : integer := 32;

constant REGISTER_ADDRESS_WIDTH : integer := 5;

constant MEM_SIZE_IN_WORDS : integer := 65536;

constant DATA_MEM_SIZE_IN_WORDS : integer := 65536;

subtype word_t is std_logic_vector(WORD_SIZE - 1 downto 0);

subtype reg_address_t is std_logic_vector(REGISTER_ADDRESS_WIDTH - 1 downto 0);

subtype address_t is std_logic_vector(WORD_SIZE - 1 downto 0);

type memory_t is array (0 to MEM_SIZE_IN_WORDS - 1) of word_t;

type data_memory_t is array (0 to DATA_MEM_SIZE_IN_WORDS - 1) of word_t;

type register_t is array (0 to REGISTER_COUNT - 1) of word_t;

type cpuRecord is record
	pc : word_t;
	readed : word_t;
end record cpuRecord;

type in_signal_reg is record
	addr : reg_address_t;
	wr : std_logic;
end record in_signal_reg;

type in_signal_ic is record
	addr : word_t;
	rd : std_logic;
end record in_signal_ic;

type in_signal_dc is record
	addr : word_t;
	wr : std_logic;
end record in_signal_dc;

type return_init_mem is record
	mem : memory_t;
	pc : word_t;
end record return_init_mem;

type instruction_info is record
	opcode : integer;
	instruction_type : integer;
end record instruction_info;

constant LOAD : instruction_info := (0,1);
constant STORE : instruction_info := (1,7);
constant MOV : instruction_info := (4,3);
constant MOVI : instruction_info := (5,4);
constant ADD : instruction_info := (8,2);
constant ISUB : instruction_info := (9,2);
constant ADDI : instruction_info := (12,1);
constant SUBI : instruction_info := (13,1);
constant IAND : instruction_info := (16,2);
constant IOR : instruction_info := (17,2);
constant IXOR : instruction_info := (18,2);
constant INOT : instruction_info := (19,2);
constant ISHL : instruction_info := (24,6);
constant ISHR : instruction_info := (25,6);
constant SAR : instruction_info := (26,6);
constant IROL : instruction_info := (27,6);
constant IROR : instruction_info := (28,6);
constant JMP : instruction_info := (32,5);
constant JSR : instruction_info := (33,5);
constant RTS : instruction_info := (34,10);
constant PUSH : instruction_info := (36,9);
constant POP : instruction_info := (37,8);
constant BEQ : instruction_info := (40,7);
constant BNQ : instruction_info := (41,7);
constant BGT : instruction_info := (42,7);
constant BLT : instruction_info := (43,7);
constant BGE : instruction_info := (44,7);
constant BLE : instruction_info := (45,7);
constant HALT : instruction_info := (63,10);


constant OPCODE_LENGTH : integer := 6;

type decoded_instructon is record
	opcode : std_logic_vector(OPCODE_LENGTH - 1 downto 0);
	rd : std_logic_vector(REGISTER_ADDRESS_WIDTH - 1  downto 0);
	rs1 : std_logic_vector(REGISTER_ADDRESS_WIDTH - 1 downto 0);
	rs2 : std_logic_vector(REGISTER_ADDRESS_WIDTH - 1 downto 0);
	rs1_value : word_t;
	rs2_value : word_t;
	immediate : std_logic_vector(15 downto 0);
	result : word_t;
	write_back : word_t;
end record decoded_instructon;
	
end package cpu_pkg;
