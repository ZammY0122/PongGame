LIBRARY IEEE;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-------------------------------------------------------
ENTITY univ_bin_counter IS
    GENERIC (N  : INTEGER := 4);
	PORT(    clk        : IN STD_LOGIC;
            rst        : IN STD_LOGIC;
            ena        : IN STD_LOGIC;
            syn_clr    : IN STD_LOGIC;
            load       : IN STD_LOGIC;
				limit      : IN STD_LOGIC;
            up         : IN STD_LOGIC;
            d          : IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
				p          : IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
            max_tick   : OUT STD_LOGIC;
            min_tick   : OUT STD_LOGIC;
            counter    : OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0)
    );

				
END ENTITY ;
-------------------------------------------------------
ARCHITECTURE rtl OF univ_bin_counter IS
    CONSTANT ONES       : UNSIGNED (N-1 DOWNTO 0) := (OTHERS => '1');
    CONSTANT ZEROS      : UNSIGNED (N-1 DOWNTO 0) := (OTHERS => '0');

    SIGNAL count_s      : UNSIGNED (N-1 DOWNTO 0);
    SIGNAL count_next   : UNSIGNED  (N-1 DOWNTO 0);
BEGIN 
    count_next <=   (OTHERS =>'0')  WHEN syn_clr = '1'  else
                    UNSIGNED(d)     WHEN load   = '1'    else
						 (OTHERS =>'0')	WHEN (limit = '1' and p = STD_LOGIC_VECTOR(count_s) )  else
                    count_s + 1     WHEN (ena = '1' AND up = '1') else
                    count_s - 1     WHEN (ena = '1' AND up = '0') else
                    count_s;
    PROCESS(clk,rst)
        VARIABLE temp   :   UNSIGNED(N-1 DOWNTO 0);
    begin
        IF(rst = '1') THEN
            temp := (OTHERS => '0');
        ELSIF (RISING_EDGE(clk)) THEN
            IF (ena = '1') THEN
                temp     := count_next;
            END IF;
        END IF;
        counter <= STD_LOGIC_VECTOR(temp);
        count_s <= temp;
    END PROCESS;

    max_tick <= '1' WHEN count_s = ONES ELSE 
				'1' WHEN p = STD_LOGIC_VECTOR(count_s) ELSE '0';
    min_tick  <= '1' WHEN count_s = ZEROS   ELSE '0';

END rtl;