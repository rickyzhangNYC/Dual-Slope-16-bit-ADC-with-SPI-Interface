-------------------------------------------------------------------------------
--
-- Title       : freclk_dvd_div
-- Design      : lab11
-- Author      : Ricky Zhang
-- Company     : Stonybrook University
--
-------------------------------------------------------------------------------
--
-- File        : c:\Users\Ricky\Documents\ESE 382\lab11\lab11\src\freclk_dvd_div.vhd
-- Generated   : Wed Apr 20 12:12:07 2016
-- From        : interface description file
-- By          : Itf2Vhdl ver. 1.22
--
-------------------------------------------------------------------------------
--
-- Description : 
--
-------------------------------------------------------------------------------

--{{ Section below this comment is automatically maintained
--   and may be overwritten
--{entity {freclk_dvd_div} architecture {behav}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;  
use IEEE.numeric_std.all;

entity freclk_dvd_div is	   
	port (
clk : in std_logic; -- system clock
rst_bar: in std_logic; -- synchronous reset
divisor: in std_logic_vector(3 downto 0);-- divider
clk_dvd: out std_logic); -- output

end freclk_dvd_div;

--}} End of automatically maintained section

architecture behav of freclk_dvd_div is
begin
	
	process(clk)
	variable count_v: unsigned(3 downto 0);
	begin
		if rising_edge(clk) then
			if rst_bar = '0' then
				count_v := unsigned(divisor);
				clk_dvd <= '0';
			else
				case count_v is
					when "0010" =>
						count_v := count_v - 1;
						clk_dvd <= '1';
					when "0001" =>
						count_v := unsigned(divisor);
						clk_dvd <= '0';
					when others =>
						count_v := count_v - 1;
						clk_dvd <= '0';
				end case;
			end if;
		end if;
	end process;	 

end behav;
