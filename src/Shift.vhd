----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:25:58 02/02/2017 
-- Design Name: 
-- Module Name:    NewShift - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;

entity NewShift is
	Port (CLK : in std_logic;
			Input_Valid : in std_logic;
			Output_Valid : out std_logic;
			A_In : in std_logic_vector(7 downto 0);
			B_out : out std_logic_vector(7 downto 0));
end NewShift;

architecture Behavioral of NewShift is

Type State is (Input,Shift,Output);
Signal Current : State :=Input;

Type RAM64Bytes is array (0 to 63) of std_logic_vector(7 downto 0);
Signal RAM : RAM64Bytes :=(Others=>(Others=>'0'));

Signal i : Std_logic_vector(5 downto 0):=(Others => '0');

Signal Output_Valid_Temp : std_logic;

begin
Process(CLK)
Begin
	if rising_edge(CLK) then
	
		case current is 
		
			when Input =>
				if Input_valid='1' then
					Output_Valid_Temp <= '0';
					if (i /= "111111") then
						RAM(conv_integer(i)) <= A_In;
						i <= i + 1;
					else
						RAM(conv_integer(i)) <= A_In;
						i <= (Others => '0');
						Current <= Shift;
					end if;
				end if;
				
			when Shift =>
				Output_Valid_Temp <= '0';
				if (i /= "111111") then 
					RAM(conv_integer(i)) <= RAM(conv_integer(i)) - "10000000";
					i <= i + 1;
				else 
					RAM(conv_integer(i)) <= RAM(conv_integer(i)) - "10000000";
					i <= (Others => '0');
					Current <= Output;
				end if;
				
			when Output =>
				
				if (i /= "111111") then 
					B_out <= RAM(conv_integer(i));
					i <= i + 1;
					Output_Valid_Temp <= '1';
				else 
					B_out <= RAM(conv_integer(i));
					i <= (Others => '0');
					Output_Valid_Temp <= '0';
					Current <= Input;
				end if;
			when Others => Current <= Input;
		end case;
	end if;
end Process;
Output_Valid <= '1' when OutPut_valid_Temp ='1' else '0'; 
end Behavioral;

