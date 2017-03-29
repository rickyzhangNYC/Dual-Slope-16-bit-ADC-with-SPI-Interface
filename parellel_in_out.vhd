-------------------------------------------------------------------------------
--
-- Title       : parallel_in_out
-- Design      : lab12
-- Author      : Ricky Zhang
-- Company     : Stonybrook University
--
-------------------------------------------------------------------------------
--
-- File        : c:\Users\Ricky\Documents\ESE 382\lab12\lab12\src\parellel_in_out.vhd
-- Generated   : Wed May  4 13:23:23 2016
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
--{entity {parallel_in_out} architecture {behavioral}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity parallel_in_out is 
	generic(n:integer := 16);
	port(
	load,clk, rst_bar: in std_logic;
	d: in std_logic_vector(n-1 downto 0);
	q: out std_logic_vector(n-1 downto 0));
end parallel_in_out;

--}} End of automatically maintained section

architecture behavioral of parallel_in_out is
begin
	process(clk)
	begin
		if rising_edge(clk) then
			if rst_bar = '0' then
				q <= (others => '0');
			elsif load = '1' then
				q <= d;
			end if;
		end if;
	end process;
	
	 -- enter your statements here --

end behavioral;
