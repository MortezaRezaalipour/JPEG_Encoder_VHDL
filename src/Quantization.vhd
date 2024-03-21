----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:01:00 02/03/2017 
-- Design Name: 
-- Module Name:    NewQuantization - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity NewQuantization is
	Port (CLK : in std_logic;
			Input_Valid : in std_logic;
			Output_Valid : out std_logic;
			A_In : in std_logic_vector(11 downto 0);
			B_out : out std_logic_vector(7 downto 0));
end NewQuantization;

architecture Behavioral of NewQuantization is

Signal Output_Valid_Temp : Std_logic;

Type State is (Input,Output);
Signal Current : State :=Input;

Type RAM64x12Bits is array (0 to 63) of std_logic_vector(11 downto 0);
Signal RAM_12 : RAM64x12Bits := (Others =>(Others =>'0'));

Signal i : Std_logic_vector(5 downto 0):=(Others => '0');
Signal m,n : integer range 0 to 8:=0;

begin
Process(CLK)
Begin
	if rising_edge(CLK) then
		case current is 
--------------------------------------------------------------------------		
			when Input =>
				if Input_valid='1' then
					Output_Valid_Temp <= '0';
					if (i /= "111111") then
						RAM_12(conv_integer(i)) <= A_In;
						i <= i + 1;
					else
						RAM_12(conv_integer(i)) <= A_In;
						i <= (Others => '0');
						Current <= Output;
					end if;
				end if;

--------------------------------------------------------------------------
			when Output =>
				if (i /= "111111") then 
					B_out <= RAM_12(conv_integer(i))(11 downto 4);
					i <= i + 1;
					Output_Valid_Temp <= '1';
				else 
					B_out <= RAM_12(conv_integer(i))(11 downto 4);
					i <= (Others => '0');
					Output_Valid_Temp <= '0';
					Current <= Input;
				end if;
--------------------------------------------------------------------------
	
	when Others => NULL;
		end case;
	end if;
end process;
Output_Valid <= '1' when OutPut_valid_Temp ='1' else '0'; 
end Behavioral;

