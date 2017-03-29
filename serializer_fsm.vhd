-------------------------------------------------------------------------------
--
-- Title       : serializer_fsm
-- Design      : lab12
-- Author      : Ricky Zhang
-- Company     : Stonybrook University
--
-------------------------------------------------------------------------------
--
-- File        : c:\Users\Ricky\Documents\ESE 382\lab12\lab12\src\serializer_fsm.vhd
-- Generated   : Wed May  4 13:34:41 2016
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
--{entity {serializer_fsm} architecture {three_process}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity serializer_fsm is  
	port(
	clk,rst_bar, neg_edge_det, selected_bar, load: in std_logic;
	shift_reg_load, shift_enable, dav: out std_logic);
end serializer_fsm;

--}} End of automatically maintained section

architecture three_process of serializer_fsm is
type state is (idle, load_state, shift);
signal present_state, next_state: state;
begin

	 state_reg : process (clk)
		 begin
			 if rising_edge(clk) then
				 if(rst_bar = '0') then
					 present_state <= idle;
				 else
					 present_state <= next_state;
				 end if;
			end if;
		end process;
		
	outputs: process (present_state)
		begin
		case present_state is 
			when idle =>   
			shift_reg_load<= '0';
			shift_enable <= '0';
			dav<= '0';
			
			when load_state =>
			shift_reg_load<='1';   
			shift_enable <= '0';
			dav <= '1';
			
			when shift =>	
			shift_enable<= '1'; 
			shift_reg_load <= '0';	 
			dav <= '0';
					   
			
		end case;
	end process;											
	
	nxt_state: process (present_state,selected_bar, load, neg_edge_det)
	begin
		case present_state is
			when idle =>			   
				if load = '1' then  
					next_state <= load_state;	  	 
				else
					next_state <= idle;
				end if;
			when load_state => 
			if (selected_bar='0' and neg_edge_det ='1') then
				next_state <= shift;
			else
				next_state <= load_state;
			end if;	
			
			when shift =>	  
			if (selected_bar = '1') then
				next_state <= idle;
			else
				next_state <= shift;
			   end if;
		end case;
	end process;
	
end three_process;
