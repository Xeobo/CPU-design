library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use work.cpu_pkg.all;

entity pass is
	port(
		clk : in std_logic;
		reset : in std_logic;
		id_opcode : in opcode_t;
		id_source1 : in reg_address_t;
		id_source2 : in reg_address_t;
		ex_data : in pass_data;
		mem_data : in pass_data;
		wb_data : in pass_data;
		id_source1_pass : out std_logic;
		id_source1_value : out word_t;
		id_source2_pass : out std_logic;
		id_source2_value : out word_t;
		flush_mem : out std_logic;
		flush_wb : out std_logic;
		stall : out std_logic
	);
	
end entity pass;


architecture RTL of pass is
	signal state_reg, state_next : first_instr_state_t;
	
	function hasDestOpCode(signal opcode : opcode_t) return integer is 
	begin
		case To_integer(Unsigned(opcode)) is
			when LOAD.opcode | POP.opcode
				=> return 2;
			when STORE.opcode | PUSH.opcode | JMP.opcode | JSR.opcode | RTS.opcode | BEQ.opcode | BNQ.opcode 
					| BLT.opcode | BGT.opcode | BLE.opcode | BGE.opcode | HALT.opcode
				=> return 0;
			when others
				=> return 1;
		end case;
	end function;
	
	function hasSource1OpCode(signal opcode : opcode_t) return integer is 
	begin
		case To_integer(Unsigned(opcode)) is
			-- these instructions use dst as  source2 register or as HALT and RST don't have source regs
			when MOVI.opcode | ISHL.opcode | ISHR.opcode | SAR.opcode | IROL.opcode | IROR.opcode | HALT.opcode | RTS.opcode
				=> return 0;
			when others
				=> return 1;
		end case;
	end function;
	
	function hasSource2OpCode(signal opcode : opcode_t) return integer is 
	begin
		case To_integer(Unsigned(opcode)) is
			-- some instructions use dst as source2 register
			when LOAD.opcode | ADDI.opcode | SUBI.opcode | MOV.opcode | JMP.opcode | JSR.opcode | POP.opcode | PUSH.opcode | HALT.opcode | RTS.opcode
				=> return 0;
			when others
				=> return 1;
		end case;
	end function;
	
	procedure passData(signal passed_data : in pass_data; signal source : in  reg_address_t; 
									signal source_value: out word_t; signal source_pass : out std_logic; isInited : out integer;signal out_stall : out std_logic) is
	begin
		source_value <= (others => '0');
		source_pass <= '0';
		isInited := 0;
		
		--check if the destination folder is the same and if instruction isn't flushed
		if(To_integer(Unsigned(passed_data.dst)) = To_integer(Unsigned(source)) and passed_data.flush = '0') then
			source_value <= passed_data.dst_value;
			source_pass <= '1';
			
			isInited := 1;
			
			if(hasDestOpCode(passed_data.opcode) = 2)then
				out_stall <= '1';
			end if;
		end if;
	
		
	
	end procedure;
	
begin

clock:process(clk,reset) is
begin
	if(reset = '1')then
		state_reg <= IF_CONST;
	elsif(rising_edge(clk))then
		state_reg <= state_next;
	end if;
	
end process clock;

alu:process(state_reg, id_source1, id_source2,
				ex_data, mem_data, wb_data
			) is 
variable isInited :integer;
begin
	state_next <= state_reg;
	flush_mem <= '0';
	flush_wb <= '0';
	stall <= '0';
	
	isInited := 0;
	
	id_source1_pass <= '0';
	id_source2_pass <= '0';
	
	id_source1_value <= (others => '0');
	id_source2_value <= (others => '0');
	
	case state_reg is
		when IF_CONST
			=>
				flush_mem <= '1';
				flush_wb <= '1';
				state_next <= ID_CONST;
		when ID_CONST
			=>	
				
				flush_mem <= '1';
				flush_wb <= '1';
				
				state_next <= EX_CONST;
		when EX_CONST
			=> 	
				if(hasSource1OpCode(id_opcode) > 0) then
					if(hasDestOpCode(ex_data.opcode) > 0) then
						passData(ex_data, id_source1, id_source1_value, id_source1_pass, isInited,stall);
					end if;
				end if;
				
				isInited := 0;
				if(hasSource2OpCode(id_opcode) > 0) then
					if(hasDestOpCode(ex_data.opcode) > 0) then
						passData(ex_data, id_source2, id_source2_value, id_source2_pass, isInited,stall);
					end if;
				end if;
				
				flush_mem <= '1';
				flush_wb <= '1';
				
				state_next <= MEM_CONST;
		when MEM_CONST
			=> 	
				if(hasSource1OpCode(id_opcode) > 0) then
					if( hasDestOpCode(ex_data.opcode) > 0) then
						passData(ex_data, id_source1, id_source1_value, id_source1_pass, isInited,stall);
					end if;
					if(isInited = 0 AND hasDestOpCode(mem_data.opcode) > 0) then
						passData(mem_data, id_source1, id_source1_value, id_source1_pass, isInited,stall);
					end if;
				end if;
				isInited := 0;
				
				if(hasSource2OpCode(id_opcode) > 0) then
					if( hasDestOpCode(ex_data.opcode) > 0) then
						passData(ex_data, id_source2, id_source2_value, id_source2_pass, isInited,stall);
					end if;
					if(isInited  = 0 AND hasDestOpCode(mem_data.opcode) > 0) then
						passData(mem_data, id_source2, id_source2_value, id_source2_pass, isInited,stall);
					end if;
				end if;
				
				flush_wb <= '1';
				
				state_next <= OTHER;
		when others
			=> 
				if(hasSource1OpCode(id_opcode) > 0) then
					if(hasDestOpCode(ex_data.opcode) > 0) then
						passData(ex_data, id_source1, id_source1_value, id_source1_pass, isInited,stall);
					end if;	
					if(isInited  = 0 AND  hasDestOpCode(mem_data.opcode) > 0) then
						passData(mem_data, id_source1, id_source1_value, id_source1_pass, isInited,stall);
					end if;
					if(isInited  = 0 AND hasDestOpCode(wb_data.opcode) > 0) then
						passData(wb_data, id_source1, id_source1_value, id_source1_pass, isInited,stall);
						stall <= '0';
					end if;
				end if;
				isInited := 0;
				
				if(hasSource2OpCode(id_opcode) > 0) then
					if(hasDestOpCode(ex_data.opcode) > 0) then
						passData(ex_data, id_source2, id_source2_value, id_source2_pass, isInited,stall);
					end if;	
					if(isInited  = 0 AND  hasDestOpCode(mem_data.opcode) > 0) then
						passData(mem_data, id_source2, id_source2_value, id_source2_pass, isInited,stall);
					end if;
					if(isInited  = 0 AND hasDestOpCode(wb_data.opcode) > 0) then
						passData(wb_data, id_source2, id_source2_value, id_source2_pass, isInited,stall);
						stall <= '0';
					end if;
				end if;
				
				
	end case;
end process alu;


end RTL;