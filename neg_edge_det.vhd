-------------------------------------------------------------------------------
--
-- Title       : neg_edge_det
-- Design      : lab12
-- Author      : Ricky Zhang
-- Company     : Stonybrook University
--
-------------------------------------------------------------------------------
--
-- File        : c:\Users\Ricky\Documents\ESE 382\lab12\lab12\src\neg_edge_det.vhd
-- Generated   : Wed May  4 13:29:22 2016
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
--{entity {neg_edge_det} architecture {heuristic}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity neg_edge_det is	  
	port(
sclk : in std_logic; -- external shift clock (from master)
rst_bar : in std_logic;-- synchronous reset
clk : in std_logic; -- system clock
neg_edge : out std_logic-- negative edge detected (one clk wide)
);

end neg_edge_det;

--}} End of automatically maintained section

architecture heuristic of neg_edge_det is  
signal sclk_delayed : std_logic;
begin

	process(clk)
	begin
		if rising_edge(clk) then
			if rst_bar ='0' then
				sclk_delayed <= '0';
				neg_edge<= '0';
			else
				sclk_delayed <= sclk;
				neg_edge <= not sclk and sclk_delayed;
			end if;
		end if;
	end process;

end heuristic;
