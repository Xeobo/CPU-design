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
		address_wr : out address_t;
		data_wr : out address_t;
		wr : out std_logic;
		bad_address : out std_logic;
		prediction_ok : out std_logic;
		writePc : out std_logic;
		mem_data : out pass_data;
		rdwr_control : out in_signal_dc; 
		write_data : out word_t;
		flush_if : out std_logic;
		flush_id : out std_logic;
		flush_ex : out std_logic;
		data_out : out decoded_instructon
		
	);
	
end entity mem;


architecture RTL of mem is
	signal results_reg, results_next : decoded_instructon;
	signal sp_reg, sp_next : word_t;
	signal mem_state_reg, mem_state_next : mem_state;
begin

clock:process(clk,reset) is
begin
	if(reset = '1')then
		results_reg <= INIT_DECODED_INSTRUCTION;
		sp_reg <= Std_logic_vector((To_unsigned(65000,WORD_SIZE)));
		mem_state_reg <= NO_HALT_MEM_STATE;
	elsif(rising_edge(clk))then
		results_reg <= results_next;
		sp_reg <= sp_next;
		mem_state_reg <= mem_state_next;
	end if;
	
end process clock;

alu:process(data_in,sp_reg,flush_mem,mem_state_reg) is 
	
	variable condition : integer;
	variable sp_temp : unsigned(0 to WORD_SIZE - 1);

begin
	results_next <= data_in;
	results_next.flush <= '1';
	sp_next <= sp_reg;
	rdwr_control.addr <= (others => '0');
	rdwr_control.wr <= '0';
	rdwr_control.hlt <= '0';
	write_data <= (others => '0');
	
	mem_data.dst_value <= data_in.result;
	mem_data.dst <= data_in.rd;
	mem_data.opcode <= data_in.opcode;
	mem_data.flush <= '1';

	sp_temp := to_unsigned(0,WORD_SIZE);
	
	
	if(data_in.flush = '0' AND flush_mem = '0' ) then
		mem_data.flush <= '0';
		results_next.flush <= '0';
		case To_integer(Unsigned(data_in.opcode)) is
			when LOAD.opcode 
				=> rdwr_control.addr <= data_in.result;
				   rdwr_control.wr <= '0';--data is readed from data cache and then one clk after stored from data_cash to out_data.write_back
			when STORE.opcode 
				=> rdwr_control.addr <= data_in.result;
				   rdwr_control.wr <= '1';
				   write_data <= data_in.rs2_value;
			when JSR.opcode
				=> 
					sp_next <= Std_logic_vector(Unsigned(sp_reg) - 1);
			
					rdwr_control.addr <= Std_logic_vector(Unsigned(sp_reg));
			   
					write_data <= data_in.pc_plus_one;
					
					rdwr_control.wr <= '1';
			
			when RTS.opcode
				=> sp_temp := Unsigned(sp_reg) + 1;
				   sp_next <= Std_logic_vector(sp_temp);
				   rdwr_control.addr <= Std_logic_vector(sp_temp);
				   
				   rdwr_control.wr <= '0';--data is readed from data cache and then one clk after stored from data_cash to out_data.write_back
				   
			when PUSH.opcode
				=> report "push-sp: " & integer'image(to_integer(unsigned(sp_reg)));
				   rdwr_control.addr <= sp_reg;
				   rdwr_control.wr <= '1';
				   write_data <= data_in.rs1_value;
				   sp_next <= Std_logic_vector(Unsigned(sp_reg) - 1);
				   
			when POP.opcode
				=> report "pop-sp: " & integer'image(to_integer(unsigned(sp_reg)));
				   sp_temp := Unsigned(sp_reg) + 1;
				   sp_next <= Std_logic_vector(sp_temp);
				   rdwr_control.wr <= '0';
				   rdwr_control.addr <= Std_logic_vector(sp_temp);
				   
			when HALT.opcode
				=> rdwr_control.hlt <= '1';
			when others
				=> null;
		end case;
	end if;
end process alu;

brunch:process(data_in,flush_mem,mem_state_reg) is 
	procedure brunch (signal prediction : in std_logic; prediction_value : in std_logic; signal result : in word_t;signal predicted_address : in word_t;
						signal brunch_adr : in address_t; signal pc : in address_t; writeAdr : in std_logic;
						signal flush_if : out std_logic; signal flush_id : out std_logic; signal flush_ex : out std_logic; 
						signal writePc : out std_logic;signal data_wr : out address_t; signal address_wr : out address_t;
						signal prediction_ok : out std_logic; signal bad_address : out std_logic) is 
	begin
		if(prediction = prediction_value)then
			if(predicted_address /= result and writeAdr = '1')then
				bad_address <= '1';
				flush_if <= '1';
				flush_id <= '1';
				flush_ex <= '1';
				writePc<= '1';
			end if;
			
			data_wr <= brunch_adr;
			address_wr <= pc;
			prediction_ok <= '1';
		else
			data_wr <= brunch_adr;
			address_wr <= pc;
			prediction_ok <= '0';
			flush_if <= '1';
			flush_id <= '1';
			flush_ex <= '1';
			writePc <= '1';
		end if;
	
		
	end brunch;
	variable condition : integer;
begin

	address_wr <= (others => '0');
	data_wr <= (others => '0');
	wr <= '0';
	prediction_ok <= '0';
	writePc <= '0';
	condition := 0;
	bad_address <= '0';
	
	flush_if <= '0';
	flush_id <= '0';
	flush_ex <= '0';
	
	mem_state_next <= mem_state_reg;
	
	if(mem_state_reg = HALT_MEM_STATE)then
		flush_if <= '1';
	end if;
	
	if(data_in.flush = '0' AND flush_mem = '0' ) then
		case To_integer(Unsigned(data_in.opcode)) is
			
			when BEQ.opcode | BNQ.opcode | BGT.opcode | BLT.opcode | BGE.opcode | BLE.opcode
				=> --from here value should be passed to instruction fetch brunch predictor
					case To_integer(Unsigned(data_in.opcode)) is
						when BEQ.opcode
							=>	
								if(data_in.rs1_value = data_in.rs2_value) then
									condition := 1;
								end if;
						when BNQ.opcode
							=>	
								if(data_in.rs1_value /= data_in.rs2_value) then
									condition := 1;
								end if;
						when BGT.opcode
							=>	
								if(data_in.rs1_value > data_in.rs2_value) then
									condition := 1;
								end if;
						when BLT.opcode
							=>	
								if(data_in.rs1_value < data_in.rs2_value) then
									condition := 1;
								end if;
						when BGE.opcode
							=>	
								if(data_in.rs1_value >= data_in.rs2_value) then
									condition := 1;
								end if;
						when others
							=>	
								if(data_in.rs1_value <= data_in.rs2_value) then
									condition := 1;
								end if;
					end case;
					if(condition = 1) then
						
						brunch(
							prediction => data_in.prediction,
							predicted_address => data_in.predicted_address,
							result => data_in.result,
							bad_address => bad_address,
							flush_if => flush_if,
							flush_ex => flush_ex,
							flush_id => flush_id,
							writePc => writePc,
							data_wr => data_wr,
							address_wr => address_wr,
							prediction_ok => prediction_ok,
							prediction_value => '1',
							pc => data_in.pc,
							brunch_adr => data_in.result,
							writeAdr => '1'
						);
						
					else
						brunch(
							prediction => data_in.prediction,
							predicted_address => data_in.predicted_address,
							result => data_in.result,
							bad_address => bad_address,
							flush_if => flush_if,
							flush_ex => flush_ex,
							flush_id => flush_id,
							writePc => writePc,
							data_wr => data_wr,
							address_wr => address_wr,
							prediction_ok => prediction_ok,
							prediction_value => '0',
							pc => data_in.pc,
							brunch_adr => data_in.pc_plus_one,
							writeAdr => '0'
						);
					end if;
					wr <= '1';
			when JMP.opcode | JSR.opcode
				=> 
					--from here value should be passed to instruction fetch brunch predictor
					brunch(
						prediction => data_in.prediction,  
						predicted_address => data_in.predicted_address,
						result => data_in.result,
						bad_address => bad_address,
						flush_if => flush_if,
						flush_ex => flush_ex,
						flush_id => flush_id,
						writePc => writePc,
						data_wr => data_wr,
						address_wr => address_wr,
						prediction_ok => prediction_ok,
						prediction_value => '1',
						pc => data_in.pc,
						brunch_adr => data_in.result,
						writeAdr => '1'
					);

					wr <= '1';
			when RTS.opcode
				=> 
				   flush_if <= '1';
				   flush_id <= '1';
				   flush_ex <= '1';
			when HALT.opcode
				=> 
				   flush_if <= '1';
				   flush_id <= '1';
				   flush_ex <= '1';
				   
				   mem_state_next <= HALT_MEM_STATE;
			when others
				=> null;
		end case;
	end if;

end process brunch;

data_out <= results_reg;

end RTL;