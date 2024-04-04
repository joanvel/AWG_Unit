library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;


entity AWG_Unit is
	generic
		(g_lines:integer:=11
		;g_bits:integer:=16
		;g_addr:integer:=11
		;g_AWGQD:integer:=4
		;g_AWGQR:integer:=3
		;g_RL:integer:=2
		;g_DACs:integer:=6
		);
	port
		(i_Clk:in std_logic
		--Inputs and outputs for the Gaussian Pulse
		;i_StaGP:in std_logic_vector(g_AWGQD+g_RL*g_AWGQR-1 downto 0)
		;i_resetGP:in std_logic_vector(g_AWGQD+g_RL*g_AWGQR-1 downto 0)
		;i_fGP:in std_logic_vector(g_lines*(g_AWGQD+g_RL*g_AWGQR)-1 downto 0)
		;o_finishGP:out std_logic_vector(g_AWGQD+g_RL*g_AWGQR-1 downto 0)
		--Inputs and outputs for the sine and cosine signal generator
		;i_alpha:in std_logic_vector(g_bits*(g_AWGQD + g_RL*g_AWGQR)-1 downto 0)
		;i_beta:in std_logic_vector(g_bits*(g_AWGQD + g_RL*g_AWGQR)-1 downto 0)
		;i_resetCS:in std_logic_vector(g_AWGQD+g_RL*g_AWGQR-1 downto 0)
		--Inputs and outputs for the custom pulse
		;i_resetCP:in std_logic_vector(g_AWGQD+g_RL*g_AWGQR-1 downto 0)
		;i_staCP:in std_logic_vector(g_AWGQD+g_RL*g_AWGQR-1 downto 0)
		;i_DataCP:in std_logic_vector(g_bits*(g_AWGQD+g_RL*g_AWGQR)-1 downto 0)
		;o_Addr:out std_logic_vector(g_addr*(g_AWGQD+g_RL*g_AWGQR)-1 downto 0)
		;o_finishCP:out std_logic_vector(g_AWGQD+g_RL*g_AWGQR-1 downto 0)
		--Extra inputs and outputs that are used by this circuit
		;i_CPulse:in std_logic_vector(g_AWGQD+g_RL*g_AWGQR-1 downto 0)
		;i_gain:in std_logic_vector(g_bits*(g_AWGQD+g_RL*g_AWGQR)-1 downto 0)
		;i_cDAC:in std_logic_vector(g_DACs*(integer(ceil(LOG2(real(3*g_AWGQD+2*g_RL)))))-1 downto 0)
		;o_signals:out std_logic_vector(g_bits*g_DACs-1 downto 0)
		);

end entity;

Architecture rtl of AWG_Unit is

	constant c_cDACs:integer:=integer(ceil(LOG2(real(3*g_AWGQD+2*g_RL))));

	component Qubit_drive is
		generic
			(g_bits:integer:=g_bits
			;g_lines:integer:=g_lines
			;g_Addr:integer:=g_addr
			);
		port
			(i_Clk:in std_logic--Added
			--inputs and outputs for the Gaussian Pulse
			;i_StaGP:in std_logic--Added
			;i_resetGP:in std_logic--Added
			;i_fGP:in std_logic_vector(g_lines-1 downto 0)--Added
			;o_finishGP:out std_logic--Added
			--inputs and outputs for the sine and cosine signal generator
			;i_alpha:in std_logic_vector(g_bits-1 downto 0)--Added
			;i_beta:in std_logic_vector(g_bits-1 downto 0)
			;i_resetCS:in std_logic--Added
			--inputs and outputs for the custom pulse
			;i_resetCP:in std_logic--Added
			;i_staCP:in std_logic--Added
			;i_DataCP:in std_logic_vector(g_bits-1 downto 0)--Added
			;o_Addr:out std_logic_vector(g_Addr-1 downto 0)--Added
			;o_finishCP:out std_logic--Added
			--extra inputs and outputs that are used by only this circuit
			;i_C:in std_logic--Pulse selector (CUstom or Gaussian)--Added
			;i_gain:in std_logic_vector(g_bits-1 downto 0)
			;o_Pulse:out std_logic_vector(g_bits-1 downto 0)
			;o_signalI:out std_logic_vector(g_bits-1 downto 0)--Signal in Phase
			;o_signalO:out std_logic_vector(g_bits-1 downto 0)--Signal Out of phase
			);
	end component;
	
	component Multiplexers is
		generic (
			g_select	: positive := c_cDACs;  -- Número de señales de entrada
			g_bits		: positive := g_bits;  -- Número de bits por señal de entrada
			g_DACs		: positive := g_DACs	-- Número de DACs
		);
		port (
			i_signals : in  std_logic_vector(((2**g_select) * g_bits) - 1 downto 0);
			i_control : in  std_logic_vector(g_select*g_DACs - 1 downto 0);  -- Entrada de control
			o_output  : out std_logic_vector(g_bits*g_DACs - 1 downto 0)
		);
	end component;
	
	type t_signalIn is array (0 to 3*g_AWGQD+2*g_RL-1) of std_logic_vector(g_bits-1 downto 0);
	
	type t_signalOut is array (0 to g_DACs-1) of std_logic_vector(g_bits-1 downto 0);
	
	type t_AWG is array (0 to 2) of std_logic_vector(g_bits-1 downto 0);
	
	type t_signals is array (0 to g_AWGQD+g_RL*g_AWGQR-1) of t_AWG;
	
	type t_fGP is array (0 to g_AWGQD+g_RL*g_AWGQR-1) of std_logic_vector(g_lines-1 downto 0);
	
	type t_fCS_DataCP_gain is array (0 to g_AWGQD+g_RL*g_AWGQR-1) of std_logic_vector(g_bits-1 downto 0);
	
	type t_Addr is array (0 to g_AWGQD+g_RL*g_AWGQR-1) of std_logic_vector(g_addr-1 downto 0);
	
	type t_cDAC is array (0 to g_DACs-1) of std_logic_vector(c_cDACs-1 downto 0);
	
	type t_Mux is array (0 to g_RL*g_AWGQR-1) of std_logic_vector(g_bits-1 downto 0);
	
	signal s_fGP: t_fGP;
	signal s_alpha: t_fCS_DataCP_gain;
	signal s_beta: t_fCS_DataCP_gain;
	signal s_DataCP: t_fCS_DataCP_gain;
	signal s_Addr: t_Addr;
	signal s_gain: t_fCS_DataCP_gain;
	signal s_signalIn: t_signalIn;
	signal s_signalOut: t_signalOut;
	signal s_cDAC: t_cDAC;
	
	signal s_signals:t_signals;
	signal s_Mux: t_Mux;
	
	signal s_Temp:std_logic_vector((2**c_cDACs)*g_bits-1 downto 0);
begin

	--Hago algunas asociaciones entre entradas, salidas y señales
	A: for i in 0 to g_AWGQD+g_RL*g_AWGQR-1 generate
		s_fGP(i) <= i_fGP((i+1)*g_lines-1 downto i*g_lines);
		s_alpha(i) <= i_alpha((i+1)*g_bits-1 downto i*g_bits);
		s_beta(i) <= i_beta((i+1)*g_bits-1 downto i*g_bits);
		s_DataCP(i) <= i_DataCP((i+1)*g_bits-1 downto i*g_bits);
		o_Addr((i+1)*g_addr-1 downto i*g_addr) <= s_Addr(i);
		s_gain(i) <= i_gain((i+1)*g_bits-1 downto i*g_bits);
	end generate;
	
	--Instancio varias veces el componente de Qubit_Drive
	
	D: for i in 0 to g_AWGQD+g_RL*g_AWGQR-1 generate
		AWG:	Qubit_drive	port map (i_Clk, i_StaGP(i), i_resetGP(i), s_fGP(i), o_finishGP(i)
											,s_alpha(i), s_beta(i), i_resetCS(i), i_resetCP(i), i_staCP(i), s_DataCP(i), s_Addr(i), o_finishCP(i)
											,i_CPulse(i), s_gain(i), s_signals(i)(0), s_signals(i)(1), s_signals(i)(2));
	end generate;
	--Sumo las señales del Readout Line
	
	F: for i in 0 to g_RL-1 generate
		process(s_signals)
			variable v_suma0:signed(g_bits-1 downto 0);
			variable v_suma1:signed(g_bits-1 downto 0);
		begin
		v_suma0:=(others=>'0');
		v_suma1:=(others=>'0');
			for j in 0 to g_AWGQR-1 loop
				v_suma0 := v_suma0 + signed(s_signals(g_AWGQD+i*g_AWGQR+j)(1));
				v_suma1 := v_suma1 + signed(s_signals(g_AWGQD+i*g_AWGQR+j)(2));
			end loop;
			s_signalIn(3*g_AWGQD+2*i) <= std_logic_vector(v_suma0);
			s_signalIn(3*g_AWGQD+2*i+1) <= std_logic_vector(v_suma1);
		end process;
	end generate;
	
	--Asocio algunas señales
	
	G: for i in 0 to g_AWGQD-1 generate
		s_signalIn(i*3)<=s_signals(i)(0);
		s_signalIn(i*3+1)<=s_signals(i)(1);
		s_signalIn(i*3+2)<=s_signals(i)(2);
	end generate;
	
	process(s_signalIn)
		variable v_signal:std_logic_vector((2**c_cDACs)*g_bits-1 downto 0):=(others=>'0');
	begin
		for i in 0 to 3*g_AWGQD+2*g_RL-1 loop
			v_signal(g_bits*(i+1)-1 downto g_bits*i) := s_signalIn(i);
		end loop;
		s_Temp <= v_signal;
	end process;
	
	--Instancio el bloque de multiplexores
	
	MX: Multiplexers	port map (s_Temp, i_cDAC, o_signals);
	
end rtl;