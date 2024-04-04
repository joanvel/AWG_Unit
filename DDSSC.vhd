library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity DDSSC is
	generic(g_bits:integer:=16);
	port
	(i_Clk:in std_logic
	;i_Ctrl0:in std_logic_vector(g_bits-1 downto 0)--Alpha
	;i_Ctrl1:in std_logic_vector(g_bits-1 downto 0)--Beta
	;i_reset:in std_logic
	;o_sin:out std_logic_vector(g_bits-1 downto 0)
	;o_cos:out std_logic_vector(g_bits-1 downto 0)
	);
end DDSSC;

Architecture rtl of DDSSC is
	component Sat is
		generic(g_bits:integer:=g_bits);
		port(i_data:in std_logic_vector(g_bits-1 downto 0)
			;o_data:out std_logic_vector(g_bits-1 downto 0));
	end component;

	signal s_cos0:std_logic_vector(g_bits-1 downto 0);
	signal s_cos1:std_logic_vector(g_bits-1 downto 0);
	signal s_sin0:std_logic_vector(g_bits-1 downto 0);
	signal s_sin1:std_logic_vector(g_bits-1 downto 0);
	signal s_Temp0:std_logic_vector(2*g_bits-1 downto 0);
	signal s_Temp1:std_logic_vector(2*g_bits-1 downto 0);
	signal s_Temp2:std_logic_vector(2*g_bits-1 downto 0);
	signal s_Temp3:std_logic_vector(2*g_bits-1 downto 0);
	signal s_Temp4:std_logic_vector(2*g_bits-1 downto 0);
	signal s_Temp5:std_logic_vector(2*g_bits-1 downto 0);
	signal s_Temp6:std_logic_vector(g_bits-1 downto 0);
	signal s_Temp7:std_logic_vector(g_bits-1 downto 0);
begin
	--Registro 0
	R0:	process(i_Clk,i_reset)
				variable v_Temp:std_logic_vector(g_bits-1 downto 0);
			begin
				if i_reset='0' then
					v_Temp:=std_logic_vector(to_unsigned(2**(g_bits-2),g_bits));
				else
					if (rising_edge(i_Clk)) then
						v_Temp:=s_cos1;
					end if;
				end if;
				s_cos0<=v_Temp;
			end process;
	--Registro 1
	R1:	process(i_Clk,i_reset)
				variable v_Temp:std_logic_vector(g_bits-1 downto 0);
			begin
				if i_reset='0' then
					v_Temp:=(others=>'0');
				else
					if (rising_edge(i_Clk)) then
						v_Temp:=s_sin1;
					end if;
				end if;
				s_sin0<=v_Temp;
			end process;
			
	--Multiplicador alpha con las señales
	s_Temp0<=std_logic_vector(signed(s_cos0)*signed(i_Ctrl0));
	s_Temp1<=std_logic_vector(signed(s_sin0)*signed(i_Ctrl0));
	--Multiplicador de Beta con las señales
	s_Temp2<=std_logic_vector(signed(s_cos0)*signed(i_Ctrl1));
	s_Temp3<=std_logic_vector(signed(s_sin0)*signed(i_Ctrl1));
	--sumador y restador
	s_Temp4<=std_logic_vector(signed(s_Temp0)-signed(s_Temp3));
	s_Temp5<=std_logic_vector(signed(s_Temp1)+signed(s_Temp2));
	s_Temp6<=s_Temp4(2*g_bits-2 downto g_bits-1);
	s_Temp7<=s_Temp5(2*g_bits-2 downto g_bits-1);
	--Bloques de saturación
	ST0:	Sat port map (s_Temp6,s_cos1);
	ST1:	Sat port map (s_Temp7,s_Sin1);
	--Asocio las salidas
	o_sin<=s_sin0;
	o_cos<=s_cos0;
	
end rtl;