LIBRARY IEEE;
use ieee.numeric_std.all;
USE ieee.std_logic_1164.all;
-------------------------------------------------------
ENTITY gameStates IS

	PORT(
				clk						:	in		std_logic;
				ena						:	in		std_logic;
				rst						:	in		std_logic;
				direction 				:	out   std_logic_vector(1 downto 0); -- arriba abajo
				left_righ				: 	out   std_logic; 
				ball_m1_x 				: 	in	std_logic_vector(7 downto 0);
				ball_m1_y 				: 	in	std_logic_vector(7 downto 0);
				ball_m2_x 				: 	in		std_logic_vector(7 downto 0);
				ball_m2_y 				: 	in	std_logic_vector(7 downto 0);
				racket_left				:	in		std_logic_vector(7 downto 0);
				racket_right			:	in		std_logic_vector(7 downto 0);
				points_pyLeft			:	out 	std_logic_vector(3 downto 0);
				points_pyRight			:	out 	std_logic_vector(3 downto 0);
				autoResetBall			: 	out 	std_logic;
				win						:	out 	std_logic
			);

END ENTITY gameStates;
-------------------------------------------------------
architecture logic of gameStates is
	TYPE state IS (play, up_rebound,down_rebound);
	TYPE statePoints IS (init, wait_time,add_left,add_right);
	signal pr_state, next_state				: state := play;
	signal pr_state2, next_state2				: statePoints := init;
	signal temp_left_righ	:std_logic := '0';
	signal temp_direction					: STD_LOGIC_VECTOR(1 downto 0);
	signal temp_movimiento					: STD_LOGIC_VECTOR(1 downto 0);
	SIGNAL      max0					:  STD_LOGIC;
	signal		golpe_izquierda, golpe_derecha 	: STD_LOGIC_VECTOR(7 downto 0);
	signal goal_left, goal_right		: std_logic := '0';
	signal points_Right_next,points_Right, points_Left_next,points_Left		:	 UNSIGNED(3 downto 0) := "0000";
	SIGNAL tempwin :std_logic := '0';
begin
	golpe_derecha <= racket_right and ball_m1_y;
	golpe_izquierda <= racket_left  and ball_m1_y;
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
         max_tick  	=> max0
    );
	
	--------------------------------------------------------------------
	-- temp_direction <= "00" when ball_m1_y = "00000001" else
	-- 					"01" when ball_m1_y = "10000000" else
	-- 					temp_direction;
	--------------------------------------------------------------------
	temp_left_righ <= '0' when (ball_m2_x = "01000000") and (golpe_derecha /= "00000000") else
						'1' when (ball_m1_x = "00000010") and (golpe_izquierda /= "00000000") else
						temp_left_righ;
	--------------------------------------------------------------------
	goal_left <= '1' when (ball_m2_x = "10000000")  else
					'0';
	--------------------------------------------------------------------
	goal_right <= '1' when (ball_m1_x = "00000001")  else
					'0';
	tempwin <= '1' when (points_Left = "0101" ) or(points_Right = "0101"  )  else
					'0';	
	selector : process(clk,rst)
	begin
		if (rst = '1') then
			pr_state <= play;
			direction <= "01";
			left_righ <= '0';
			points_Left <= "0000";
			points_Right <= "0000";
			autoResetBall <= '0';
		elsif (rising_edge(clk)) then
			pr_state <= next_state;
			pr_state2 <= next_state2;
			direction <= temp_direction;
			left_righ <= temp_left_righ;
			win <= tempwin;
			autoResetBall <= goal_left or goal_right;
			points_pyLeft <= STD_LOGIC_VECTOR(points_Left_next);
			points_pyRight <= STD_LOGIC_VECTOR(points_Right_next);
			points_Left <= points_Left_next;
			points_Right <=points_Right_next;
		end if;
		
	end process selector;
	-----------------------------------------------------------------
	mat_case: process(pr_state,temp_left_righ,racket_left,racket_right,ball_m2_x,ball_m1_x,ball_m1_y,ball_m2_y)
	begin
		case pr_state is
			when play => 
				temp_left_righ <= temp_left_righ;
				temp_direction<= temp_direction;
				if (ball_m1_y = "00000001" ) then 
					next_state <= up_rebound;
				elsif (ball_m1_y = "10000000" ) then 
					next_state <= down_rebound;	
				else
					next_state <= play;
				end if;
			when up_rebound =>
				temp_left_righ <= temp_left_righ;
				temp_direction <= "00";
				next_state <= play;
			when down_rebound =>
				temp_left_righ <= temp_left_righ;
				temp_direction <= "01";
				next_state <= play;			
			when others	=>
		end case;
	end process;
	--------------------------------------------------------------
	case_points: process(pr_state2,goal_left,goal_right,max0)
	begin
		case pr_state2 is
			when init =>
				points_Left_next <= points_Left ; 
				points_Right_next<= points_Right;
				if (goal_left = '1' ) then 
					next_state2 <= add_left;
				elsif (goal_right = '1' ) then 
					next_state2 <= add_right;	
				else
					next_state2 <= init;
				end if;
			when add_left =>
				points_Left_next <= points_Left + 1;
				points_Right_next<= points_Right;
				next_state2 <= wait_time;
			when add_right =>
				
				points_Left_next <= points_Left ;
				points_Right_next <= points_Right +1;
				next_state2 <= wait_time;
			when wait_time =>
				points_Left_next <= points_Left ; 
				points_Right_next<= points_Right;
				if (max0 = '1')then 
					next_state2 <= init;
				else
					next_state2 <= wait_time;
				end if;
			when others	=>
		end case;
	end process; 

end architecture;