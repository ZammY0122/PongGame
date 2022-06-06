LIBRARY IEEE;
use ieee.numeric_std.all;
USE ieee.std_logic_1164.all;
-------------------------------------------------------
ENTITY game_to_matrix IS

	PORT(
				clk						:	in		std_logic;
				ena						:	in		std_logic;
				rst						:	in		std_logic;

				racket_left				:	in		std_logic_vector(7 downto 0);
				racket_right			:	in		std_logic_vector(7 downto 0);
				-- matRiz 2	
				ball_row_m1 				: 	in	std_logic_vector(7 downto 0);
				ball_col_m1 				: 	in	std_logic_vector(7 downto 0);
				-- matRiz 2
				ball_row_m2 				: 	in	std_logic_vector(7 downto 0);
				ball_col_m2 				: 	in	std_logic_vector(7 downto 0);
				--raqueta izquierda
				leds_x					: 	out	std_logic_vector(7 downto 0);
				leds_y1					: 	out	std_logic_vector(7 downto 0);
				--raqueta dercha
				leds_x2					: 	out	std_logic_vector(7 downto 0);
				leds_y2					: 	out	std_logic_vector(7 downto 0)

			);

END ENTITY game_to_matrix;
-------------------------------------------------------
architecture logic of game_to_matrix is
TYPE state IS (draw1, wait_second1, wait_second2,draw2);
signal pr_state, next_state		: state := draw1;

signal temp_x, temp_x2,	temp_y1,	temp_y2		: std_logic_vector(7 downto 0);
SIGNAL      load,max0,min0 		:  STD_LOGIC;
SIGNAL	  	limit      			 	:  STD_LOGIC;
SIGNAL      up        				:  STD_LOGIC;
SIGNAL      d          				:  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL		p          				:  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL      n0  			      	:  STD_LOGIC_VECTOR(3 DOWNTO 0);
begin
	load <= '0';
	limit <= '1';
	up <= '1';
	counter_1: ENTITY work.univ_bin_counter
	GENERIC MAP (N => 4)
	PORT MAP(
				clk        => clk,
            rst        => rst,
            ena        => ena,
            syn_clr    => '0',
            load       => load,
				limit      => limit,
            up         => up,
            d          => "0000",
				p          => "1111",
            max_tick   => max0,
            min_tick   => min0,
            counter    => n0);
	selector : process(clk,rst)
	begin
		if (rst = '1') then
			pr_state <= draw1;
		elsif (rising_edge(clk)) then
			pr_state <= next_state;
			leds_x <= temp_x;
			leds_y1 <= temp_y1;
			leds_x2 <= temp_x2;
			leds_y2 <= temp_y2;
		end if;
	end process selector;

	mat_case: process(pr_state,max0)
	begin
		case pr_state is
			when draw1 =>
				--mostrar la raqueta 
				temp_x <= "00000001"; 
				temp_y1 <= not racket_left; --"00111000" 11100000
				temp_y2 <= not racket_right;
				temp_x2<= "10000000";
				next_state <= wait_second1;
			when draw2 =>
				--mostrar la pelota
				temp_x <= ball_row_m1; 
				temp_y1 <= not ball_col_m1;
				temp_x2 <= ball_row_m2;
				temp_y2 <= not ball_col_m2;
				next_state <= wait_second2;
			when wait_second1 =>
				temp_x <= "00000001"; 
				temp_y1 <= not racket_left;
				temp_y2 <= not racket_right;
				temp_x2<= "10000000";
				if (max0 = '1') then 
					next_state <= draw2;
				else
					next_state <= wait_second1;
				end if;
			when wait_second2 =>
				temp_x <= ball_row_m1; 
				temp_y1 <= not ball_col_m1;
				temp_x2 <= ball_row_m2;
				temp_y2 <= not ball_col_m2;
				if (max0 = '1') then 
					next_state <= draw1;
				else
					next_state <= wait_second2;
				end if;
		end case;
	end process mat_case;

end architecture;