-------------------------------------------------------------------------------
--
-- Title       : tc514_adc_SPI
-- Design      : lab12
-- Author      : Ricky Zhang
-- Company     : Stonybrook University
--
-------------------------------------------------------------------------------
--
-- File        : c:\Users\Ricky\Documents\ESE 382\lab12\lab12\src\tc514_adc_SPI.vhd
-- Generated   : Wed May  4 13:32:47 2016
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
--{entity {tc514_adc_SPI} architecture {structural}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity tc514_adc_SPI is
generic ( n : integer := 16);
port (
soc: in std_logic; -- start of conversion input
rst_bar: in std_logic; -- reset
clk: in std_logic; -- clock
cmptr: in std_logic; -- from TC514 comparator
a: out std_logic; -- TC514 phase control input
b: out std_logic; -- TC514 phase control input
dout: out std_logic_vector (n-1 downto 0); -- conversion result
busy_bar: out std_logic; -- converter busy
dav: out std_logic; -- SPI data valid flag
miso: out std_logic; -- SPI serial output data
sck: in std_logic; -- SPI shift data clock
ss_bar: in std_logic -- SPI slave select
);
attribute loc: string;
attribute loc of soc: signal is "D1";
attribute loc of rst_bar: signal is "C2";
attribute loc of clk: signal is "G3";
attribute loc of cmptr: signal is "D3";
attribute loc of a: signal is "F1";
attribute loc of b: signal is "E1";
attribute loc of dout: signal is "A13,F8,C12,E10,F9,E8,E7,D7,A3,A4,A5,B7,B9,F7,C4,D6";	  
attribute loc of busy_bar: signal is "F3";
attribute loc of dav : signal is "B5";
attribute loc of sck : signal is "D9";
attribute loc of miso : signal is "B4";
attribute loc of ss_bar : signal is "B6";

end tc514_adc_SPI;

--}} End of automatically maintained section

architecture structural of tc514_adc_SPI is	   
signal clk_dvd: std_logic;
signal q_int: std_logic_vector(n-1 downto 0);
signal max_cnt: std_logic;
signal cnt_en: std_logic;
signal clr_cntr_bar: std_logic;
signal load_result: std_logic; 
signal neg_edge: std_logic;	   
signal shift_reg_load: std_logic; 
signal shift_enable: std_logic;
signal q_rightside: std_logic_vector(n-1 downto 0);	   
signal msb: std_logic;

begin	
	
	freq_div: entity freclk_dvd_div port map(clk => clk, rst_bar => rst_bar, divisor => "0100", clk_dvd => clk_dvd);
	
	binary_cntr: entity binary_cntr port map(cnten2=>clk_dvd, up=> '1', clr_bar => clr_cntr_bar, rst_bar => rst_bar, clk => clk, cnten1=>cnt_en, q => q_int, max_cnt => max_cnt);
	
	tc514fsm: entity tc514fsm port map(soc => soc, cmptr => cmptr, max_cnt => max_cnt, clk => clk, clk_dvd => clk_dvd, rst_bar => rst_bar, load_result => load_result, clr_cntr_bar=> clr_cntr_bar, cnt_en => cnt_en, busy_bar => busy_bar, a=> a, b=> b);
		
	neg_edge_det: entity neg_edge_det port map(sclk => sck, clk => clk, rst_bar => rst_bar, neg_edge => neg_edge);    
		
	serializer_fsm: entity serializer_fsm port map(rst_bar => rst_bar, clk => clk, neg_edge_det => neg_edge, selected_bar => ss_bar, load => load_result, shift_reg_load => shift_reg_load, shift_enable => shift_enable, dav => dav);
		
	parallel_in_out: entity parallel_in_out port map(rst_bar => rst_bar, load => load_result, clk => clk, d=> q_int, q => q_rightside);
	dout <= q_rightside;
	parallel_2_serial: entity parallel_2_serial port map(load=> shift_reg_load, clk => clk, rst_bar => rst_bar, shift_en => shift_enable, d => q_rightside, msb => msb);
	
	miso <= msb when (not ss_bar	= '1') else 'Z';

end structural;		   		 
			