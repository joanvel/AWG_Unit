library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Multiplexers is
  generic (
    g_select	: positive := 4;  -- Número de señales de entrada
    g_bits		: positive := 8;  -- Número de bits por señal de entrada
	 g_DACs		: positive := 4	-- Número de DACs
  );
  port (
    i_signals : in  std_logic_vector(((2**g_select) * g_bits) - 1 downto 0);
    i_control : in  std_logic_vector(g_select*g_DACs - 1 downto 0);  -- Entrada de control
    o_output  : out std_logic_vector(g_bits*g_DACs - 1 downto 0)
  );
end entity Multiplexers;

architecture Behavioral of Multiplexers is

	type t_DataOut is array (0 to g_DACs-1) of std_logic_vector(g_bits-1 downto 0);
	type t_DataIn is array (0 to 2**g_select-1) of std_logic_vector(g_bits-1 downto 0);
	type t_select is array (0 to g_DACs-1) of std_logic_vector(g_select-1 downto 0);
	
	signal s_signals: t_DataIn;
	signal s_control: t_select;
	signal s_output: t_DataOut;

begin
	A: for i in 0 to (2**g_select)-1 generate
		s_signals(i) <= i_signals((i+1)*g_bits-1 downto i*g_bits);
	end generate;
	
	B: for i in 0 to g_DACs-1 generate
		s_control(i) <= i_control((i+1)*g_select-1 downto i*g_select);
		o_output((i+1)*g_bits-1 downto i*g_bits) <= s_output(i);
	end generate;
	
	c: for i in 0 to g_DACs-1 generate
		s_output(i) <= s_signals(to_integer(unsigned(s_control(i))));
	end generate;
end architecture Behavioral;