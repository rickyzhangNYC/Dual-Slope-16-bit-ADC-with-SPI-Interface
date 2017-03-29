-------------------------------------------------------------------------------
--
-- Title       : binary_cntr
-- Design      : lab11
-- Author      : Ricky Zhang
-- Company     : Stonybrook University
--
-------------------------------------------------------------------------------
--
-- File        : c:\Users\Ricky\Documents\ESE 382\lab11\lab11\src\binary_cntr.vhd
-- Generated   : Wed Apr 20 12:16:56 2016
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
--{entity {binary_cntr} architecture {behav}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity binary_cntr is	
	generic (n : integer := 16);
port (clk : in std_logic; -- system clock
cnten1 : in std_logic; -- acitve high count enable
cnten2 : in std_logic; -- active high count enable
up : in std_logic; -- count direction				  			  
clr_bar : in std_logic; -- synchrounous counter clear
rst_bar: in std_logic; -- synchronous reset
q: out std_logic_vector (n-1 downto 0);-- count
max_cnt: out std_logic);-- maximum count indication
end binary_cntr;

--}} End of automatically maintained section

architecture behav of binary_cntr is
begin										
	process (clk, cnten1, cnten2)	  
	variable count: unsigned(n-1 downto 0);			  
	begin
		if rising_edge(clk) then
			if rst_bar = '0' then
				count:= (others => '0');
				max_cnt <= '0';
			elsif clr_bar = '0' then
				count:= (others => '0');
				max_cnt <= '0';
			elsif cnten1 = '1' and cnten2 = '1' then
				if up = '1' then
					count:= count+1;  	   
					max_cnt <= '0';
					if count = to_unsigned(2**n-1,n) then
						max_cnt  <= '1';				
					end if;	
				else
					count := count-1;
					max_cnt <= '0';
					if count = to_unsigned(2**n-1,n) then
						max_cnt <= '1';
					end if;
				end if;
			end if;
		end if;
		q <= std_logic_vector(count);
	end process;
end behav;