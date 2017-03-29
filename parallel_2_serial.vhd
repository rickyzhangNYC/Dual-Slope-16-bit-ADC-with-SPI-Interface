-------------------------------------------------------------------------------
--
-- Title       : parallel_2_serial
-- Design      : lab12
-- Author      : Ricky Zhang
-- Company     : Stonybrook University
--
-------------------------------------------------------------------------------
--
-- File        : c:\Users\Ricky\Documents\ESE 382\lab12\lab12\src\parallel_2_serial.vhd
-- Generated   : Wed May  4 13:26:07 2016
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
--{entity {parallel_2_serial} architecture {slices}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity parallel_2_serial is	   
	generic(n: integer := 16);
	port(
	load, clk, rst_bar, shift_en: in std_logic;
	d: in std_logic_vector(n-1 downto 0);
	msb: out std_logic);
end parallel_2_serial;

--}} End of automatically maintained section

architecture slices of parallel_2_serial is				 
signal qa: std_logic_vector(n-1 downto 0);
begin

	process(clk)
	variable q: std_logic_vector(n-1 downto 0);
	begin
		if rising_edge(clk) then
			if rst_bar ='0' then
				q:= (others => '0');
				qa <= (others => '0');
			elsif load ='1' then
				q:= d;			  
				qa <= d;
			elsif shift_en ='1' then
				q := q(n-2 downto 0) & '0';		  
				qa <= q(n-2 downto 0) & '0';		
			end if;		 
		end if;
		msb <= q(n-1);
	end process;	
	
end slices;
