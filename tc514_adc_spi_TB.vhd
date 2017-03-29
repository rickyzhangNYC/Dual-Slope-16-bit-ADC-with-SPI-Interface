-- Testbench for TC514_adc_spi


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tc514_adc_spi_tb is
	generic(
		n : integer := 16 ;				-- width of ADC
		-- integer analog value simulated, Vin = (analog_val * Vref)/2**n
		analog_val : integer := 32768);	
end tc514_adc_spi_tb;

architecture tb_architecture of tc514_adc_spi_tb is
	
	-- Stimulus signals
	signal soc : std_logic;
	signal rst_bar : std_logic;
	signal clk : std_logic;
	signal cmptr : std_logic;
	signal sck : std_logic;
	signal ss_bar : std_logic;
	-- Observed signals
	signal a : std_logic;
	signal b : std_logic;
	signal dout : std_logic_vector(n-1 downto 0);
	signal busy_bar : std_logic;
	signal dav : std_logic;
	signal miso : std_logic;
	
	-- vector equivalent to analog_val integer
	signal analog_val_bin : std_logic_vector(n-1 downto 0);
	-- serial result received by SPI master
	signal master_spi_receiver : std_logic_vector (n -1 downto 0);
	-- system clock perdion
	constant clk_period : time := 125 ns;
	-- boolean signal to stop system clock
	signal END_SIM : boolean := false;
	
begin
	
	-- Unit Under Test port map
	UUT : entity tc514_adc_spi
	generic map (
		n => n
		)
	
	port map (
		soc => soc,
		rst_bar => rst_bar,
		clk => clk,
		cmptr => cmptr,
		a => a,
		b => b,
		dout => dout,
		busy_bar => busy_bar,
		dav => dav,
		miso => miso,
		sck => sck,
		ss_bar => ss_bar
		);
	
	-- TC514 Precision Analog Front End VHDL Model
	TC514: entity tc514model generic map (n => n) 
	port map
		(a => a,
		b => b,
		analog_val_bin => analog_val_bin,
		clk => clk,
		--	clk_dvd => clk_dvd_sig,
		cmptr => cmptr,
		rst_bar => rst_bar);
	
	-- System Clock Process
	clock_gen : process
	begin
		clk <= '0';
		wait for clk_period/2;
		loop	-- inifinite loop
			clk <= not clk;
			wait for clk_period/2;
			exit when END_SIM = true;
		end loop;
		wait;
	end process;
	
	-- Reset Signal
	rst_bar <= '0', '1' after 2.5 * clk_period;
	
	-- Stimulus Process acts as Master
	tb: process
	begin
		-- Initial stimulus values
		soc <= '0';
		ss_bar <= '1';
		sck <= '0';
		wait until rst_bar = '1';
		
		-- Two conversions will be peformed with the same analog input value
		for i in 0 to 1 loop
			
			-- Create a vector equal to analog input value integer
			analog_val_bin <= std_logic_vector(to_unsigned(analog_val,n));		
			
			-- Wait for busy_bar to be unasserted (at end of Auto Zero phase)
			wait until busy_bar = '1';
			wait for 4 * clk_period;
			
			-- Generate a start of conversion pulse
			soc <= '1';		
			wait for 4 * clk_period;
			
			soc <= '0';		
			wait for 4 * clk_period;
			
			-- Wait for analog-to-digital conversion to end
			wait until dav = '1';
			wait for 4 * clk_period;
			
			-- Select TC514_adc_spi for a serial transfer
			ss_bar <= '0';
			wait for  4 * clk_period;
			
			-- Generate the n shift clocks, master reads data on rising edge.
			-- The data the master reads is stored in master_spi_signal for
			-- later verification
			-- TC514_adc_spi shifts data on falling edge
			for i in 15 downto 0 loop
				sck <= '1';
				master_spi_receiver <= master_spi_receiver(n -2 downto 0) & miso;
				wait for  4 * clk_period;
				sck <= '0';
				wait for  4 * clk_period;
			end loop;
			
			-- Verify parallel output and serial output
			assert (dout = analog_val_bin) and (master_spi_receiver = analog_val_bin)
			report "Error for analog value = " & to_hstring(analog_val_bin)
			& ", parallel output = " & to_hstring(dout)
			& ", serial output = " & to_hstring(master_spi_receiver)
			severity error;
			
			-- Deselect tC514_adc_spi
			ss_bar <= '1';
			
		end loop;
		
		-- Stop the system clock
		END_SIM <= true;
		
		wait;		-- done
	end process;
	
end tb_architecture;



--------------------- TC514 Model ------------------------------------
--
--  File: TC514model.vhd
--  


-- Counter component

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bin_cntr is
	generic (n : integer := 16);
	port (clk, cnten1, cnten2, up, ld_bar, rst_bar: in std_logic;
		ld_val: in std_logic_vector(n-1 downto 0);
		--		q: out std_logic_vector (n-1 downto 0);
		cntr_zero: out std_logic);
end bin_cntr;

architecture behavioral of bin_cntr is
begin
	
	cntr: process (clk)
		variable count_v : unsigned(n-1 downto 0);
	begin
		if rising_edge(clk) then
			if rst_bar = '0' then
				count_v := (others => '0');
			elsif ld_bar = '0' then
				count_v := unsigned(ld_val);
			elsif cnten1 = '1' and cnten2 = '1'  then
				case up is
					when '1' => count_v := count_v + 1;
					when others => count_v := count_v - 1;
				end case;
			else
				null;
			end if;
			
			--			q <= std_logic_vector(count_v);
			
			if count_v = to_unsigned(0,n)  then
				cntr_zero <= '1';
			else
				cntr_zero <= '0';
			end if;
		end if;
	end process;
end behavioral;


-- FSM component
-- This FSM has four states: idle, de_int, ovr_shoot, and zero_int
-- The idle state models the TC514 auto_zero and integrate states,
-- for these two states the comparator output is 1.
-- When in the de_int state for a positive voltage the comparator
-- output is 1, but we must stay in this state for a time for a nunber
-- of counter clock periods equal to the binary reprsentatio of the
-- analog input value.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fsm is
	port (a, b, clk, rst_bar, cntr_zero: in std_logic;
		cnten, up, ld_bar, cmptr : out std_logic);
end fsm;

architecture behavioral of fsm is
	type state is (idle, de_int, ovr_shoot, zero_int);
	signal present_state, next_state : state;
	
begin
	
	state_reg: process (clk)				-- state register process
	begin
		if rising_edge(clk) then
			if rst_bar = '0' then
				present_state <= idle;
			else
				present_state <= next_state;
			end if;
		end if;
	end process;
	
	output: process (present_state)			-- output process
	begin
		case present_state is
			
			when idle =>
				cmptr <= '1' after 10 ns;
				cnten <= '0';
				up <= '0';
				ld_bar <= '0';			
			
			when de_int =>
				cmptr <= '1' after 10 ns;
				cnten <= '1';
				up <= '0';
				ld_bar <= '1';
			
			when ovr_shoot =>
				-- overshoot proportional to input voltage
				cmptr <= '0' after 10 ns;
				cnten <= '1';
				up <= '1';
				ld_bar <= '1';
			
			when zero_int =>
				cmptr <= '0' after 10 ns;
				cnten <= '1';
				up <= '0';
				ld_bar <= '1';
			
			when others =>
				cmptr <= '1' after 10 ns;
				cnten <= '0';
				up <= '0';
				ld_bar <= '0';			
			
		end case;							
	end process;
	
	nx_state: process (present_state, a, b, cntr_zero)	-- next state process
	begin
		case present_state is
			
			when idle =>
				if a = '1' and b = '1' then
					next_state <= de_int;
				else
					next_state <= idle;
				end if;
			
			when de_int =>
				if cntr_zero = '1' then
					next_state <= ovr_shoot;
				else
					next_state <= de_int;
				end if;
			
			when ovr_shoot =>
				if a = '0' and b = '0' then
					next_state <= zero_int;
				else
					next_state <= ovr_shoot;
				end if;
			
			when zero_int =>
				if cntr_zero = '1' then
					next_state <= idle;
				else
					next_state <= zero_int;
				end if;
			
			when others =>
				next_state <= idle;
			
		end case;							
	end process;
end behavioral;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity freq_div_tc514_model is
	port (
		clk : in std_logic;			-- system clock
		rst_bar: in std_logic;		-- synchronous reset
		divisor: in std_logic_vector(3 downto 0);	-- divider
		clk_dvd: out std_logic);	-- output
end freq_div_tc514_model;

architecture behavioral of freq_div_tc514_model is
begin
	
	div: process (clk)
		variable count_v : unsigned(3 downto 0);
		variable q_v : std_logic;
	begin
		if rising_edge(clk) then
			if rst_bar = '0' then
				count_v := unsigned(divisor);
				q_v := '0';
			else
				case count_v is
					when "0001" =>
						count_v := unsigned(divisor);
					q_v := '1';
					when others =>
						count_v := count_v - 1;
					q_v := '0';
				end case;
			end if;
			clk_dvd <= q_v;
		end if;
	end process;
end behavioral;


-- top-level TC514 Modelentity

library ieee;
use ieee.std_logic_1164.all;

entity tc514model is
	generic (n : integer := 16);
	port (
		a: in std_logic;
		b: in std_logic;
		analog_val_bin: in std_logic_vector(n-1 downto 0);
		clk: in std_logic;
		--		clk_dvd: in std_logic;
		cmptr: out std_logic;
		rst_bar: in std_logic
		);
end TC514model;


architecture behavior of TC514model is
	
	signal cnten1_sig, up_sig, ld_bar_sig, cntr_zero_sig: std_logic;
	signal clk_dvd_sig: std_logic;
	
begin
	
	u0: entity freq_div_TC514_model port map (clk => clk, rst_bar => rst_bar, divisor => "0100",
		clk_dvd => clk_dvd_sig);
	
	u1: entity bin_cntr
	generic map (n => n)
	port map (clk => clk, cnten1 => cnten1_sig, cnten2 => clk_dvd_sig, up => up_sig, ld_bar => ld_bar_sig,
		rst_bar => rst_bar, ld_val => analog_val_bin, cntr_zero => cntr_zero_sig);
	
	u2: entity fsm
	port map (a => a, b => b, clk => clk, rst_bar => rst_bar,
		cntr_zero => cntr_zero_sig, cnten => cnten1_sig, up => up_sig,
		ld_bar => ld_bar_sig, cmptr => cmptr);
	
end architecture;	




