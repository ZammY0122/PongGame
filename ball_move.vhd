LIBRARY IEEE;
use ieee.numeric_std.all;
USE ieee.std_logic_1164.all;
-------------------------------------------------------
ENTITY ball_move IS

	PORT(
				clk						:	in		std_logic;
				ena						:	in		std_logic;
				rst						:	in		std_logic;
				direction				: 	in    std_logic_vector(1 downto 0);
				left_righ				: 	in 	std_logic;
				next_ball_m1_x 		:  out std_logic_vector(7 downto 0);
				next_ball_m2_x 		:  out std_logic_vector(7 downto 0);
				next_ball_y 			:  out std_logic_vector(7 downto 0)
			);

END ENTITY ball_move;
-------------------------------------------------------
architecture logic of ball_move is
TYPE state IS (move_right, wait_seconds,move,move_left);
SIGNAL pr_state, next_state : state :=move;
SIGNAL temporal_ball_x :std_logic_vector(15 downto 0):= "0100000000000000";
SIGNAL temporal_ball_y :std_logic_vector(7 downto 0) := "00001000";
SIGNAL max_counter1 :	std_logic;
SIGNAL min_counter1 :	std_logic;
SIGNAL max_counter2 :	std_logic;
SIGNAL min_counter2 :	std_logic;
SIGNAL ball_x :std_logic_vector(15 downto 0) := "0000000100000000";
SIGNAL ball_y :std_logic_vector(7 downto 0) := "00010000";

---------------------------------------------------------
begin

	counter1: ENTITY work.univ_bin_counter
    GENERIC MAP(N =>24)
	PORT MAP(   
			clk        	=> clk,
            rst        	=> rst,
            ena        	=> ena,
            syn_clr    	=> '0',
            load       	=> '0',
				limit      	=> '1',
            up         	=> '1',
            d          	=> "000000000000000000000000",
			   p          	=> "010011000100101101000000",
            max_tick  	=> max_counter1,  
            min_tick	=> min_counter1
    );
	counter2: ENTITY work.univ_bin_counter
    GENERIC MAP(N =>4)
	PORT MAP(   
			clk        	=> max_counter1,
            rst        	=> rst,
            ena        	=> ena,
            syn_clr    	=> '0',
            load       	=> '0',
				limit      	=> '1',
            up         	=> '1',
            d          	=> "0000",
				p          	=> "0100",
            max_tick  	=> max_counter2,  
            min_tick	=> min_counter2
    );
	
	selector: process(clk,rst)
	begin
		if (rst = '1') then
			pr_state <= move;
			next_ball_m1_x <= "10000000";
			next_ball_m2_x <= "00000000";
			next_ball_y <= "00010000";
			ball_x <= "0000000100000000";
			ball_y <= "00010000";
		elsif (rising_edge(clk)) then 
			pr_state <= next_state;
			ball_x <= temporal_ball_x;
			ball_y <= temporal_ball_y;
			----------------------------------------
			next_ball_m1_x(0) <= temporal_ball_x(15);
			next_ball_m1_x(1) <= temporal_ball_x(14);
			next_ball_m1_x(2) <= temporal_ball_x(13);
			next_ball_m1_x(3) <= temporal_ball_x(12);
			next_ball_m1_x(4) <= temporal_ball_x(11);
			next_ball_m1_x(5) <= temporal_ball_x(10);
			next_ball_m1_x(6) <= temporal_ball_x(9);
			next_ball_m1_x(7) <= temporal_ball_x(8);
			----------------------------------------
			next_ball_m2_x(0) <= temporal_ball_x(7);
			next_ball_m2_x(1) <= temporal_ball_x(6);
			next_ball_m2_x(2) <= temporal_ball_x(5);
			next_ball_m2_x(3) <= temporal_ball_x(4);
			next_ball_m2_x(4) <= temporal_ball_x(3);
			next_ball_m2_x(5) <= temporal_ball_x(2);
			next_ball_m2_x(6) <= temporal_ball_x(1);
			next_ball_m2_x(7) <= temporal_ball_x(0);
			----------------------------------------
			next_ball_y <= temporal_ball_y;
		end if;
	end process selector;
	----------------------------------------------------
	estados: process(pr_state,max_counter1,direction,left_righ)
	begin
		case( pr_state ) is
			when move =>
				temporal_ball_y <= ball_y;
				temporal_ball_x <= ball_x;
				if(max_counter1 = '1' and left_righ = '1' ) then 
					next_state <= move_right;
				elsif(max_counter1 = '1' and left_righ = '0' ) then 
					next_state <= move_left;
				else
					next_state <= move;
				end if;
			when move_right =>
				next_state <= wait_seconds;
				temporal_ball_x <=   '0' & ball_x(15 downto 1);
				if direction = "01" then 
					temporal_ball_y <= '0' & ball_y(7 downto 1);
				elsif direction = "00" then
					temporal_ball_y <= ball_y(6 downto 0 ) & '0';
				elsif direction = "11" then
					temporal_ball_y <= temporal_ball_y;
					
				end if;
			
			when move_left =>
				next_state <= wait_seconds;
				temporal_ball_x <=   ball_x(14 downto 0 ) & '0';
				if direction = "01" then 
					temporal_ball_y <= '0' & ball_y(7 downto 1);
				elsif direction = "00" then
					temporal_ball_y <= ball_y(6 downto 0 ) & '0';
				elsif direction = "11" then
						temporal_ball_y <= temporal_ball_y;
				end if;
			when wait_seconds =>
				temporal_ball_x <= ball_x;
				temporal_ball_y <= ball_y;
				if(max_counter1 = '1')then 
					next_state <= move;
				else
					next_state <= wait_seconds;
				end if;
			
		end case ;
	end process estados;	
end architecture;