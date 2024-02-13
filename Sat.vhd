library ieee;
use ieee.std_logic_1164.all;

entity Sat is
	generic(g_bits:integer:=8);
	port(i_data:in std_logic_vector(g_bits-1 downto 0)
			;o_data:out std_logic_vector(g_bits-1 downto 0));
	end Sat;
	
Architecture RTL of Sat is
	begin
		X: for i in 0 to g_bits-3 generate
				o_data(i)<=(not(i_data(g_bits-1)) and not(i_data(g_bits-2)) and i_data(i))or(i_data(g_bits-1) and i_data(g_bits-2) and i_data(i));
		end generate;
		o_data(g_bits-1 downto g_bits-2)<= i_data(g_bits-1) & (i_data(g_bits-1) or i_data(g_bits-2));
	end RTL;