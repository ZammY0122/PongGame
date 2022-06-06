LIBRARY IEEE;
use ieee.numeric_std.all;
USE ieee.std_logic_1164.all;
-------------------------------------------------------
ENTITY racket_mov IS

	PORT(
				clk						:	in		std_logic;
				ena						:	in		std_logic;
				rst						:	in		std_logic;
				button_r					:	in		std_logic;
				button_l					:	in		std_logic;
				actual_pos				:	in		std_logic_vector(7 downto 0);
				next_pos					:	out	std_logic_vector(7 downto 0)
			);

END ENTITY racket_mov;
-------------------------------------------------------
architecture movimiento of racket_mov is
TYPE state IS (unclicked, wait_second,click_r,clcik_l);
signal pr_state, next_state		: state := unclicked;
signal temporal			:			std_logic_vector(7 downto 0) := "00111000";
SIGNAL max0, max1, max2 : STD_LOGIC;
SIGNAL min0, min1, min2 : STD_LOGIC;
SIGNAL n1,n2            :  STD_LOGIC_VECTOR(3 dowNTO 0);
SIGNAL      load      	:  STD_LOGIC;
SIGNAL	  limit       	:  STD_LOGIC;
SIGNAL      up        	:  STD_LOGIC;
SIGNAL      d          	:  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL		p          	:  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL      n0         	:  STD_LOGIC_VECTOR(23 DOWNTO 0);
begin

	load <= '0';
	limit <= '1';
	up <= '1';
	d <= "0000";
	p <= "1111";
	--contador que permite actualizar el movimiento de los 3 bits
	--tambien permite la velocidad de moverse 
	counter_1: ENTITY work.univ_bin_counter
	GENERIC MAP (N => 24)
	PORT MAP(
			clk        => clk,
         rst        => rst,
         ena        => ena,
			syn_clr    => '0',
         load       => '0',
			limit      => '1',
         up         => '1',
         d          => "000000000000000000000000",
			p          => "010011000100101101000000",
         max_tick   => max0,
         min_tick   => min0
			);
				
	selector : process(clk,rst)
	begin
		if (rst = '1') then
			pr_state <= unclicked;
			next_pos <= "00111000";
		elsif (rising_edge(clk)) then
			pr_state <= next_state;
			next_pos <= temporal;
		end if;
	end process selector;
	--maquina de estados para hacer el movimiento de la raqueta
	estado_raqueta:process(pr_state,button_r,button_l,actual_pos,max0)
		begin
			case pr_state is
				when unclicked =>
					temporal <= actual_pos;
					if(button_r = '1') then 
						next_state <= click_r;
					elsif (button_l = '1') then 
						next_state <= clcik_l;
					else
						next_state <= unclicked;
					end if;
				when click_r =>
					next_state <= wait_second;
					if( actual_pos = "00000111") then
						temporal <= actual_pos;
					else
						temporal <=   '0' & actual_pos(7 downto 1) ;
					end if;
				when clcik_l =>
					next_state <= wait_second;
					if( actual_pos = "11100000") then
						temporal <= actual_pos;
					else
						temporal <= actual_pos(6 downto 0) & '0';
					end if;
				when wait_second =>
						temporal <= actual_pos;
						if (max0 = '1') then 
							next_state <= unclicked;
						else
							next_state <= wait_second;
						end if;
			end case;
	end  process estado_raqueta ;

end architecture;