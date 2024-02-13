-- Quartus Prime VHDL Template
-- Four-State Moore State Machine

-- A Moore machine's outputs are dependent only on the current state.
-- The output is written only when the state changes.  (State
-- transitions are synchronous.)

library ieee;
use ieee.std_logic_1164.all;

entity FSM_CustomP is

	port(
		clk		: in	std_logic;
		sta	 	: in	std_logic;
		reset	 	: in	std_logic;
		UP			: out	std_logic;
		flag		: out	std_logic;
		c			: out	std_logic
	);

end entity;

architecture rtl of FSM_CustomP is

	-- Build an enumerated type for the state machine
	type state_type is (s0, s1);

	-- Register to hold the current state
	signal state   : state_type;

begin

	-- Logic to advance to the next state
	process (clk, reset)
	begin
		if reset = '0' then
			state <= s0;
		elsif (rising_edge(clk)) then
			case state is
				when s0=>
					if sta = '1' then
						state <= s1;
					else
						state <= s0;
					end if;
				when s1=>
					state <= s1;
			end case;
		end if;
	end process;

	-- Output depends solely on the current state
	process (state)
	begin
		case state is
			when s0 =>
				UP	<=	'0';
				c	<=	'0';
				flag <= '1';
			when s1 =>
				UP	<=	'1';
				c	<=	'1';
				flag <= '0';
		end case;
	end process;

end rtl;
