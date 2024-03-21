--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package NewJPEG_Package is
--Type Declaration---------------------------------------------------
Type Vector_3Bytes is array (0 to 2) of std_logic_vector(7 downto 0);
Type Block64x3 is array (0 to 64,0 to 2) of STD_LOGIC_VECTOR (7 downto 0);

end NewJPEG_Package;

package body NewJPEG_Package is
end NewJPEG_Package;
