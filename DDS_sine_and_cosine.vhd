library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity DDS_sine_and_cosine is
	generic(g_bits:integer:=64);
	port
			(i_Clk:in std_logic
			;i_fctrl:in std_logic_vector(g_bits-1 downto 0)
			;i_reset:in std_logic
			;o_sin:out std_logic_vector(g_bits-1 downto 0)
			;o_cos:out std_logic_vector(g_bits-1 downto 0)
			);
		end DDS_sine_and_cosine;
	
Architecture RTL of DDS_sine_and_cosine is

	component Sat is
			generic(g_bits:integer:=g_bits);
		port(i_data:in std_logic_vector(g_bits-1 downto 0)
				;o_data:out std_logic_vector(g_bits-1 downto 0));
	end component;

	signal s_Temp0:std_logic_vector(g_bits-1 downto 0);--Bus de datos que conecta el Phase Addition (realmente es un restador) con el circuito de saturación 0.
	signal s_Temp1:std_logic_vector(g_bits-1 downto 0);--Bus de datos que conecta el phase adittion con el circuito de saturación 1.
	signal s_Temp2:std_logic_vector(g_bits*2-1 downto 0);--Bus de datos que conecta el multiplicador con el phase adittion.
	signal s_Temp3:std_logic_vector(g_bits*2-1 downto 0);--Bus de datos que conecta el multiplicador con el phase adittion (que en realidad es un restador).
	signal s_Temp4:std_logic_vector(g_bits-1 downto 0);--Bus de datos que conecta la salida con el phase adittion (en realidad es un restador) y con el registro cosine (Rcos).
	signal s_Temp5:std_logic_vector(g_bits-1 downto 0);--Bus de datos que conecta la salida con el phase adittion y con el registro sine (Rsin).
	signal s_Temp6:std_logic_vector(g_bits-1 downto 0);--Bus de datos que conecta el circuito de saturación 0 con el registro Cosine (Rcos).
	signal s_Temp7:std_logic_vector(g_bits-1 downto 0);--Bus de datos que conecta el circuito de saturación 1 con el registro Sine (Rsin).
	begin
		--Registro del coseno (Rcos)
		Rcos:	process(i_Clk, i_reset)
					variable v_Temp:std_logic_vector(g_bits-1 downto 0);
					begin
					if i_reset='0' then
						v_Temp(g_bits-3 downto 0):=(others=>'0');
						v_Temp(g_bits-1 downto g_bits-2):="01";
					else
						if (rising_edge(i_Clk)) then
							v_Temp:=s_Temp6;
						end if;
					end if;
					s_Temp4<=v_Temp;
				end process;
		--Registro del seno (Rsin)
		Rsin:	process(i_Clk, i_reset)
					variable v_Temp:std_logic_vector(g_bits-1 downto 0);
					begin
					if i_reset='0' then
						v_Temp:=(others=>'0');
					else
						if (rising_edge(i_Clk)) then
							v_Temp:=s_Temp7;
						end if;
					end if;
					s_Temp5<=v_Temp;
				end process;
		--Restador
		s_Temp0<= std_logic_vector(signed(s_Temp4) - signed(s_Temp3(g_bits*2-3 downto g_bits-2)));
		--Sumador
		s_Temp1<= std_logic_vector(signed(s_Temp5) + signed(s_Temp2(g_bits*2-3 downto g_bits-2)));
		--Multiplicador coseno
		s_Temp2<= std_logic_vector(signed(i_fctrl)*signed(s_Temp4));
		--Multiplicador seno
		s_Temp3<= std_logic_vector(signed(i_fctrl)*signed(s_Temp5));
		
		S0: Sat	port map (s_Temp0,s_Temp6);
		S1: Sat	port map	(s_Temp1,s_Temp7);
		
		o_sin<=s_Temp5;
		o_cos<=s_Temp4;
		--prueba0<=s_Temp2(g_bits*2-3 downto g_bits-2);
		--prueba1<=s_Temp3(g_bits*2-3 downto g_bits-2);
	end RTL;