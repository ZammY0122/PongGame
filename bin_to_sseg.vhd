LIBRARY IEEE;
use ieee.numeric_std.all;
USE ieee.std_logic_1164.all;
-------------------------------------------------------
ENTITY bin_to_sseg IS
	PORT(		bin				:	IN		STD_LOGIC_VECTOR(3 DOWNTO 0);

				sseg				:	OUT	STD_LOGIC_VECTOR(6 DOWNTO 0));
END ENTITY bin_to_sseg;
-------------------------------------------------------
ARCHITECTURE behaviour OF bin_to_sseg IS
BEGIN 
		WITH bin SELECT
			sseg <=
				"1000000" WHEN "0000",
				"1111001" WHEN "0001",
				"0100100" WHEN "0010",
				"0110000" WHEN "0011",
				"0011001" WHEN "0100",
				"0010010" WHEN "0101",
				"0000010" WHEN "0110",
				"1111000" WHEN "0111",
				"0000000" WHEN "1000",
				"0010000" WHEN "1001",
				"0000110" WHEN OTHERS;

END behaviour;