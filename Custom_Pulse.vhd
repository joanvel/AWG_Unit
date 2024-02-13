library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity Custom_Pulse is
	generic
				(g_bits:integer:=16
				;g_lines:integer:=8
				);
	port
			(i_Clk:in std_logic
			;i_reset:in std_logic
			;i_sta:in std_logic
			;i_Data:in std_logic_vector(g_bits-1 downto 0)
			;o_Data:out std_logic_vector(g_bits-1 downto 0)
			;o_Addr:out std_logic_vector(g_lines-1 downto 0)
			;flag:out std_logic
			);
end Custom_Pulse;

Architecture RTL of Custom_Pulse is
	component FSM_CustomP is
		port
			(
			clk		: in	std_logic;
			sta	 	: in	std_logic;
			reset	 	: in	std_logic;
			UP			: out	std_logic;
			flag		: out	std_logic;
			c			: out	std_logic
			);

	end component;

	signal s_UP:std_logic;
	signal s_c:std_logic;
	signal s_NotClk:std_logic;
begin
	s_NotClk <= not(i_Clk);
	--Contador de dirección de la señal
	process(s_NotClk,i_reset)
		variable v_Temp:integer;
	begin
		if (i_reset = '0') then
			v_Temp := 0;
		elsif (rising_edge(s_NotClk)) then
			if (s_UP='1') then
				v_Temp := v_Temp + 1;
			end if;
		end if;
		o_Addr <= std_logic_vector(to_unsigned(v_Temp, g_lines));
	end process;
	--Multiplexor
	o_Data <= i_Data when s_c = '1' else
					(others=>'0');
	--FSM
	X:	FSM_CustomP	port map	(i_Clk, i_sta, i_reset, s_UP, flag, s_c);
end RTL;