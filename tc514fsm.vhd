-------------------------------------------------------------------------------
--
-- Title       : tc514fsm
-- Design      : lab11
-- Author      : Ricky Zhang
-- Company     : Stonybrook University
--
-------------------------------------------------------------------------------
--
-- File        : c:\Users\Ricky\Documents\ESE 382\lab11\lab11\src\tc514fsm.vhd
-- Generated   : Wed Apr 20 12:54:08 2016
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
--{entity {tc514fsm} architecture {FSM}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity tc514fsm is	 	 
	port(
soc : in std_logic; -- start conversion control input
cmptr : in std_logic; -- TC 514 comparator status input
max_cnt : in std_logic; -- maximum count status input
clk : in std_logic; -- system clock
clk_dvd : in std_logic; -- clock divided down
rst_bar: in std_logic; -- synchronous reset
a : out std_logic; -- conversion phase control
b : out std_logic; -- conversion phase control
busy_bar : out std_logic; -- active low busy status
cnt_en : out std_logic; -- counter enable control to counter
clr_cntr_bar : out std_logic; -- signal to clear counter
load_result : out std_logic); -- load enable	

end tc514fsm;

--}} End of automatically maintained section

architecture FSM of tc514fsm is	   	  
type state is (auto_zero, az_idle, integrate, deint, outputzero, clear_cnt);
signal present_state, next_state : state;	

begin

	 -- enter your statements here --
	state_reg : process (clk)
		 begin
			 if rising_edge(clk) then
				 if(rst_bar = '0') then
					 present_state <= auto_zero;
				 else
					 present_state <= next_state;
				 end if;
			end if;
		end process;

	outputs: process (present_state)
	begin
		case present_state is 
			when auto_zero =>	
				busy_bar <= '0';
			    a <= '0';
				b <= '1';
				cnt_en <= '1';		   
				clr_cntr_bar <= '1';  
				load_result<='0';
				
			when az_idle =>	 
				clr_cntr_bar<='0';
				a<='0';
				b<='1';	
				cnt_en <= '0';
				load_result<= '0';	
				busy_bar <='1';
				
			when integrate => 	
				clr_cntr_bar<='1';
				busy_bar <='0';
				cnt_en <= '1';
			    a <= '1';
				b <= '0';
  				load_result <= '0';
				
			when deint =>
			cnt_en <= '1'; 
			clr_cntr_bar<='1';
				a<='1';
				b<='1';	  
				load_result <= '0';	 
				busy_bar <='0';
				
			when outputzero =>
				  	 clr_cntr_bar<='1';
				cnt_en<= '0';
				a<= '0';
				b<= '0'; 	 
				load_result<='1';
				busy_bar <='0';
				
			when clear_cnt =>
				a<= '0';
				b<='0';
				cnt_en <= '0';
				clr_cntr_bar <='0';
				busy_bar <='0';
				
			when others	=>
				load_result <= '0';
		end case;			 	
	end process;
	
	nxt_state: process (present_state, max_cnt, clk_dvd, soc,cmptr)
	begin
		case present_state is
			when auto_zero =>  
			if max_cnt = '1' then				
				next_state <= az_idle;
			else
				next_state <= auto_zero;
			end if;	
			
			when az_idle =>	
				if soc = '1' then
					next_state <= integrate;  
				else
					next_state <= az_idle;
				end if;
			
			when integrate =>	
				if max_cnt = '1' and clk_dvd='1' then
					next_state <= deint;  
				else
					next_state <= integrate;
				end if;
				
			when deint =>		 
					
				if cmptr = '0' then	    
					next_state <= outputzero;
				else
					next_state <= deint;
				end if;	  
				
			when outputzero =>		
				if cmptr = '1' then 
					next_state <= clear_cnt;  
				else
					next_state <= outputzero;
				end if;	  
				
			when clear_cnt =>	 
					next_state <= auto_zero;  
			when others =>
		end case;
	end process;
end FSM;
