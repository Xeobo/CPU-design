library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use work.cpu_pkg.all;

entity predictor is
	port(
		clk : in std_logic;
		reset : in std_logic;
		address : in address_t;
		address_wr : in address_t;
		data_wr : in address_t;
		wr : in std_logic;
		prediction_ok : in std_logic;
		predict : out std_logic;
		predict_address : out address_t;
		valid : out std_logic
	);
	
end entity predictor;


architecture RTL of predictor is
	signal predictions_reg, predictions_next : predictor_memory_t;
begin

clock:process(clk,reset) is
begin
	if(reset = '1')then
		predictions_reg <= (others => INIT_PREDICTOR_REG);
	elsif(rising_edge(clk))then
		predictions_reg <= predictions_next;
	end if;
	
end process clock;

alu:process(address,predictions_reg,data_wr,address_wr,wr,prediction_ok) is 
	variable index : integer;
	variable index_wr : integer;
begin
	predictions_next <= predictions_reg;
	predict_address <= (others =>'0');
	predict <= '0';
	valid <= '0';
	index := to_integer(Unsigned(address(WORD_SIZE - TAG_LENGTH - 1 downto 0 ) ));
	index_wr := to_integer(Unsigned(address_wr(WORD_SIZE - TAG_LENGTH - 1 downto 0 ) ));
	
	if(predictions_reg(index).tag = address((WORD_SIZE - 1) downto (WORD_SIZE - TAG_LENGTH)) and predictions_reg(index).valid = '1' )then
		predict <= prediction_array(to_integer(Unsigned(predictions_reg(index).twobits)));
		predict_address <= predictions_reg(index).prediction;
		valid <= '1';
	end if;
	
	if(wr = '1') then
		if(predictions_reg(index_wr).tag = address_wr((WORD_SIZE - 1) downto (WORD_SIZE - TAG_LENGTH)) 
				and predictions_reg(index_wr).valid = '1' )then
			
			if(prediction_ok = '1')then
				
				predictions_next(index_wr).twobits <= Std_logic_vector(To_Unsigned(positive_prediction(to_integer(Unsigned(predictions_reg(index_wr).twobits))),2));
				
			else
				predictions_next(index_wr).twobits <= Std_logic_vector(To_Unsigned(negative_prediction(to_integer(Unsigned(predictions_reg(index_wr).twobits))),2));
			end if;
			
			if((to_integer(Unsigned(predictions_reg(index_wr).twobits)) = WEAK_TAKEN and prediction_ok = '0')
					OR (to_integer(Unsigned(predictions_reg(index_wr).twobits)) = WEAK_NOT_TAKEN and prediction_ok = '0')) then
				predictions_next(index_wr).prediction <= data_wr;
			end if;
		else
			predictions_next(index_wr).tag <= address_wr((WORD_SIZE - 1) downto (WORD_SIZE - TAG_LENGTH));
			
			predictions_next(index_wr).prediction <= data_wr;
			
			if(prediction_ok  = '1') then
				predictions_next(index_wr).twobits <= ('0', '0');
			else
				predictions_next(index_wr).twobits <= ('1', '1');
			end if;
		end if;
		

		
		
		predictions_next(index_wr).valid <= '1';
		
	end if;
	
end process alu;


end RTL;