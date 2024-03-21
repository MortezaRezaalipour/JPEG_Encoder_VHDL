----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:00:00 02/02/2017 
-- Design Name: 
-- Module Name:    NewDCT2D - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.Numeric_STD.all;


entity NewDCT2D is
	Port (CLK : in std_logic;
			Input_Valid : in std_logic;
			Output_Valid : out std_logic;
			A_In : in std_logic_vector(7 downto 0);
			B_out : out std_logic_vector(11 downto 0));
end NewDCT2D;

architecture Behavioral of NewDCT2D is

Type State is (Input,Store_Matrix,DCT1D,DCT1D_T,Store_RAM,Output);
Signal Current : State :=Input;

Type RAM64Bytes is array (0 to 63) of std_logic_vector(7 downto 0);
Signal RAM : RAM64Bytes :=(Others=>(Others=>'0'));

Type RAM64x12Bits is array (0 to 63) of std_logic_vector(11 downto 0);
Signal RAM_12 : RAM64x12Bits := (Others =>(Others =>'0'));


Signal i : Std_logic_vector(5 downto 0):=(Others => '0');
Signal m,n,k : integer range 0 to 8:=0;

Signal Output_Valid_Temp : Std_logic;

Type SMatrix8x8 is array (0 to 7,0 to 7) of Signed(7 downto 0);
Type sMatrix8x8_11 is array (0 to 7,0 to 7) of Signed (10 downto 0);
Type sMatrix8x8_12 is array (0 to 7,0 to 7) of Signed (11 downto 0);
Type sMatrix8x8_22 is array (0 to 7,0 to 7) of Signed (21 downto 0);


Signal Window : SMatrix8x8 :=(Others=>(Others=>(Others=>'0')));

Constant U : SMatrix8x8 := ((X"5B", X"5B", X"5B", X"5B", X"5B", X"5B", X"5B", X"5B"),
									(X"7E", X"6A", X"47", X"19", X"E7", X"B9", X"96", X"82"),
									(X"76", X"31", X"CF", X"8A", X"8A", X"CF", X"31", X"76"),
									(X"6A", X"E7", X"82", X"B9", X"47", X"7E", X"19", X"96"),
									
									(X"5B", X"A5", X"A5", X"5B", X"5B", X"A5", X"A5", X"5B"),
									(X"47", X"82", X"19", X"6A", X"96", X"E7", X"7E", X"B9"),
									(X"31", X"8A", X"76", X"CF", X"CF", X"76", X"8A", X"31"),
									(X"19", X"B9", X"6A", X"82", X"7E", X"96", X"47", X"E7"));

Signal UA : SMatrix8x8_11;
Signal UA_TEMP : Signed (18 downto 0):=(Others => '0');
Signal UAU : SMatrix8x8_12;
Signal UAU_Temp : Signed (21 downto 0):=(Others => '0');

begin
Process(CLK)
begin
	if rising_edge(CLK) then
		case current is 
--Input State------------------------------------------------------------------
			when input =>
			m <= 0;
			n <= 0;
			k <= 0;
			if Input_valid='1' then
					Output_Valid_Temp <= '0';
					if (i /= "111111") then
						RAM(conv_integer(i)) <= A_In;
						i <= i + 1;
					else
						RAM(conv_integer(i)) <= A_In;
						i <= (Others => '0');
						Current <= Store_Matrix;
					end if;
				end if;
--Store RAM into a matrix------------------------------------------------------------------				
			when Store_Matrix =>
			if (n /= 8 ) then 
					if(m /= 8 ) then 
						Window (n,m) <= Signed(RAM(Conv_integer(i)));
						m <= m + 1;
					else 
						m <= 0;
						n <= n + 1;
					end if;
			else 
					Current <= DCT1D;
					m <= 0;
					n <= 0;
			end if;		
--DCT1D------------------------------------------------------------------			
			when DCT1D =>
			if (m /= 8 ) then 
					if(n /= 8 ) then 
						if (k /= 8) then
							k <= k + 1;
							UA_Temp <= UA_Temp + U(m,k) * Window(k,n);
						else
							UA(m,n) <= UA_Temp(18 downto 8);
							UA_Temp <= (Others => '0');
							k <= 0;
							n <= n + 1;
						end if;
					else 
						n <= 0;
						m <= m + 1;
					end if;
			else 
					Current <= DCT1D_T;
					m <= 0;
					n <= 0;
			end if;
			
--DCT1D & Transpose------------------------------------------------------------------			
			when DCT1D_T =>
			if (m /= 8 ) then 
					if(n /= 8 ) then 
						if (k /= 8) then
							k <= k + 1;
							UAU_Temp <= UAU_Temp + UA(m,k) * U(n,k);
						else
							UAU(m,n)<=UAU_Temp(19 downto 8);
							UAU_Temp <= (Others=>'0');
							k <= 0;
							n <= n + 1;
						end if;
					else 
						n <= 0;
						m <= m + 1;
					end if;
			else 
					Current <= Store_RAM;
					m <= 0;
					n <= 0;
			end if;
			
--Store Matrix into the RAM------------------------------------------------------------------			
			when Store_RAM =>
			if (n /= 8 ) then 
					if(m /= 8 ) then 
						RAM_12(Conv_integer(i)) <= std_logic_vector(UAU(n,m));
						m <= m + 1;
						i <= i + 1;
					else 
						m <= 0;
						n <= n + 1;
					end if;
			else 
					Current <= Output;
					m <= 0;
					n <= 0;
					i <= (Others => '0');
			end if;
--Sending the output to the next module------------------------------------------------------------------			
			when Output =>
				if (i /= "111111") then 
					B_out <= RAM_12(conv_integer(i));
					i <= i + 1;
					Output_Valid_Temp <= '1';
				else 
					B_out <= RAM_12(conv_integer(i));
					i <= (Others => '0');
					Output_Valid_Temp <= '0';
					Current <= Input;
				end if;

			when Others => NULL;
		end case;
	end if;
end process;
Output_Valid <= '1' when OutPut_valid_Temp ='1' else '0'; 
end Behavioral;

