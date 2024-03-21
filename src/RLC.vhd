----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:18:57 02/03/2017 
-- Design Name: 
-- Module Name:    NewRLC - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use WORK.NEWJPEG_PACKAGE.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity NewRLC is
	Port (CLK : in std_logic;
			Input_Valid : in std_logic;
			Output_Valid : out std_logic;
			A_In : in std_logic_vector(7 downto 0);
			B_out : out Vector_3Bytes);
end NewRLC;

architecture Behavioral of NewRLC is

Type State is (Input,DC_Encoding,AC_Encoding,Output);
Signal Current : State :=Input;

Type RAM64Bytes is array (0 to 63) of std_logic_vector(7 downto 0);
Signal A : RAM64Bytes := (Others =>(Others =>'0'));
Signal B : Block64x3 :=(Others =>(Others =>(Others => '0')));

Signal i : integer range 0 to 64:=0;
Signal j : integer range 0 to 64:=1;
Signal k : std_logic_vector (5 downto 0):=(Others => '0');

Signal EOB : STD_LOGIC := '0';
Signal Count_Z : STD_LOGIC_VECTOR (7 downto 0):=X"00";


begin
Process(CLK)

Variable Data_in1 : STD_LOGIC_VECTOR (7 downto 0) :=X"00";

begin
	if rising_edge(CLK) then 
		case current is 
---------------------------------------------------------------------------		
			when input =>
				if Input_valid='1' then
					Output_Valid_Temp <= '0';
					if (k /= "111111") then
						A(conv_integer(k)) <= A_In;
						k <= k + 1;
					else
						A(conv_integer(k)) <= A_In;
						k <= (Others => '0');
						Current <= DC_Encoding;
					end if;
				end if;
---------------------------------------------------------------------------			
			when DC_Encoding =>
				B(0,0) <= X"DC";
				if (A(0)(7)='0') then  						  -- if #1 
					if (A(0)(7 downto 0) = "00000001") then --  if #2
						B(0,1) <= X"01";
						B(0,2)(0) <= A(0)(0);
					elsif (A (0)( 7 downto 1 ) = "0000001") then
						B (0,1) <= X"02";
						B (0, 2)(1 downto 0) <= A(0)(1 downto 0);
						
					elsif	A(0)( 7 downto 2 ) = "000001" then
						B(0,1) <= X"03";
						B(0, 2)(2 downto 0) <= A(0)(2 downto 0);
						
					elsif
						A(0)( 7 downto 3 ) = "00001" then
						B  (0,1) <= X"04";
						B (0, 2)(3 downto 0) <= A(0)(3 downto 0);
					elsif
						A(0)( 7 downto 4 ) = "0001" then
						B  (0,1) <= X"05";
						B (0, 2)(4 downto 0) <= A(0)(4 downto 0);
					elsif
						A(0)( 7 downto 5 ) = "001" then
						B  (0,1) <= X"06";
						B (0, 2)(5 downto 0) <= A(0)(5 downto 0);
					elsif
						A(0)( 7 downto 6 ) = "01" then
						B (0,1) <= X"07";
						B(0, 2)(6 downto 0) <= A(0)(6 downto 0);
					end if;													-- End of if #2  A(0)(7 downto 0) = "00000001"
				else															-- Else of if #1
					Data_in1 := (X"00") - (A(0));
					if Data_in1( 7 downto 0 ) = "00000001" then	-- if #3
						B (0,1) <= X"01";
						B(0, 2)(0) <= not Data_in1(0);
					elsif
						Data_in1( 7 downto 1 ) = "0000001" then
						B (0,1) <= X"02";
						B(0, 2)(1 downto 0) <= not Data_in1(1 downto 0);
					elsif
						Data_in1( 7 downto 2 ) = "000001" then
						B (0,1) <= X"03";
						B(0, 2)(2 downto 0) <= not Data_in1(2 downto 0);
					elsif
						Data_in1( 7 downto 3 ) = "00001" then
						B (0,1) <= X"04";
						B(0, 2)(3 downto 0)<= not Data_in1(3 downto 0);
					elsif
						Data_in1( 7 downto 4 ) = "0001" then
						B (0,1) <= X"05";
						B(0, 2)(4 downto 0) <= not Data_in1(4 downto 0);
					elsif
						Data_in1( 7 downto 5 ) = "001" then
						B (0,1) <= X"06";
						B(0, 2)(5 downto 0) <= not Data_in1(5 downto 0);
					elsif
						Data_in1( 7 downto 6 ) = "01" then
						B (0,1) <= X"07";
						B(0, 2)(6 downto 0) <= not Data_in1(6 downto 0);
					end if;															-- End of if #3   Data_in1( 7 downto 0 ) = "00000001"
				end if;																-- End of if #1
						current <= AC_Encoding;
---------------------------------------------------------------------------
			when AC_Encoding =>
				if EOB = '0' then				-- if #1 
					if A(j) = X"00" then				-- if #2	
						if(Count_Z = X"0F") then
							B(i,0) <= X"0F";
							B(i,1) <= X"00";
							B(i,2) <= X"00";
							Count_Z <= X"00";
							i <= i + 1;
						else
							count_Z <= count_Z + '1';
						end if;
					else									-- Else of if #2
						B(i,0) <= count_Z;
						count_Z <= X"00";
						if A(j)(7) = '0' then			-- if #3
							if A(j)( 7 downto 0 ) = "00000001" then			-- if #4 
								B(i,1) <= X"01";
								B(i, 2)(0) <= '1';
							elsif
								A(j)( 7 downto 1 ) = "0000001" then
								B(i,1) <= X"02";
								B(i,2)(1 downto 0) <= A(j)(1 downto 0);
							elsif
								A(j)( 7 downto 2 ) = "000001" then
								B (i,1) <= X"03";
								B(i, 2)(2 downto 0) <= A(j)(2 downto 0);
							elsif
								A(j)( 7 downto 3 ) = "00001" then
								B (i,1) <= X"04";
								B(i, 2)(3 downto 0) <= A(j)(3 downto 0);
							elsif
								A(j)( 7 downto 4 ) = "0001" then
								B (i,1) <= X"05";
								B(i, 2)(4 downto 0) <= A(j)(4 downto 0);
							elsif
								A(j)( 7 downto 5 ) = "001" then
								B (i,1) <= X"06";
								B(i, 2)(5 downto 0) <= A(j)(5 downto 0);
							elsif
								A(j)( 7 downto 6 ) = "01" then
								B (i,1) <= X"07";
								B(i, 2)(6 downto 0) <= A(j)(6 downto 0);
							end if;															-- End of if #4  A(i)( 7 downto 0 ) = "00000001"
						else																	-- Else of if #3
							Data_in1 := (X"00") - (A(j));
							if Data_in1( 7 downto 0 ) = "00000001" then			-- if #5
								B (i,1) <= X"01";
								B(i, 2)(0) <= not Data_in1(0);
							elsif
								Data_in1( 7 downto 1 ) = "0000001" then
								B (i,1) <= X"02";
								B(i, 2)(1 downto 0) <= not Data_in1(1 downto 0);
							elsif
								Data_in1( 7 downto 2 ) = "000001" then
								B (i,1) <= X"03";
								B(i, 2)(2 downto 0) <= not Data_in1(2 downto 0);
							elsif
								Data_in1( 7 downto 3 ) = "00001" then
								B (i,1) <= X"04";
								B(i, 2)(3 downto 0)<= not Data_in1(3 downto 0);
							elsif
								Data_in1( 7 downto 4 ) = "0001" then
								B (i,1) <= X"05";
								B(i, 2)(4 downto 0) <= not Data_in1(4 downto 0);
							elsif
								Data_in1( 7 downto 5 ) = "001" then
								B (i,1) <= X"06";
								B(i, 2)(5 downto 0) <= not Data_in1(5 downto 0);
							elsif
								Data_in1( 7 downto 6 ) = "01" then
								B (i,1) <= X"07";
								B(i, 2)(6 downto 0) <= not Data_in1(6 downto 0);
							end if;																-- End of if #5 Data_in1( 7 downto 0 ) = "00000001"
						end if;																	-- End of if #3 A(i)(7) = '0'
						
							i <= i + 1;
					end if;								-- End of if #2 A(i) = X"00"
					
					if(j /= 63) then 
						j <= j + 1;
					else
						if (Count_z > X"00") then 
							B(i,0) <= Count_Z;
							B(i,1) <= X"00";
							B(i,2) <= X"00";
							i <= i + 1;
						end if;
						j <= 0;
						EOB <= '1';
					end if;
				else											-- Else of if #1
							B(i,0) <= X"00";
							B(i,1) <= X"00";
							B(i,2) <= X"FF";
							count_Z <= X"00";
							i <= 0;
							Current <= OUTPUT;
				end if;										-- End of if #1 EOB = '0'
---------------------------------------------------------------------------
			when Output =>
				if (k /= "111111") then 
					B_out(0) <= B(conv_integer(k),0);
					B_out(1) <= B(conv_integer(k),1);
					B_out(2) <= B(conv_integer(k),2);
					k <= k + 1;
					Output_Valid_Temp <= '1';
				else 
					B_out(0) <= B(conv_integer(k),0);
					B_out(1) <= B(conv_integer(k),1);
					B_out(2) <= B(conv_integer(k),2);
					k <= (Others => '0');
					Output_Valid_Temp <= '0';
					Current <= Input;
				end if;
---------------------------------------------------------------------------
			when Others => NULL;
---------------------------------------------------------------------------
		end case;
	end if;
end process;
Output_Valid <= '1' when OutPut_valid_Temp ='1' else '0'; 
end Behavioral;

