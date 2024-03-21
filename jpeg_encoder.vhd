library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity JPEG_Encoder is
    Port (
        CLK             : in std_logic;
        RESET           : in std_logic;
        Data_In         : in std_logic_vector(7 downto 0);
        Data_Valid_In   : in std_logic;
        Data_Out        : out std_logic_vector(7 downto 0);
        Data_Valid_Out  : out std_logic
    );
end JPEG_Encoder;

architecture Behavioral of JPEG_Encoder is
    -- Intermediate signals between modules
    signal shift_data_out   : std_logic_vector(7 downto 0);
    signal shift_valid      : std_logic;
    signal dct_data_out     : std_logic_vector(7 downto 0);
    signal dct_valid        : std_logic;
    signal quant_data_out   : std_logic_vector(7 downto 0);
    signal quant_valid      : std_logic;
    signal rlc_data_out     : std_logic_vector(7 downto 0);
    signal rlc_valid        : std_logic;

begin
    -- Instantiate modules assuming all are in the 'work' library
    -- Update entity paths if they are in different libraries

    shift_module: entity work.Shift
        port map (
            CLK         => CLK,
            Input_Valid => Data_Valid_In,
            Output_Valid=> shift_valid,
            A_In        => Data_In,
            B_out       => shift_data_out
        );

    dct_module: entity work.DCT2D
        port map (
            CLK         => CLK,
            Input_Valid => shift_valid,
            Output_Valid=> dct_valid,
            Data_In     => shift_data_out,
            Data_Out    => dct_data_out
        );

    quant_module: entity work.Quantization
        port map (
            CLK         => CLK,
            Input_Valid => dct_valid,
            Output_Valid=> quant_valid,
            Data_In     => dct_data_out,
            Data_Out    => quant_data_out
        );

    rlc_module: entity work.RLC
        port map (
            CLK         => CLK,
            Input_Valid => quant_valid,
            Output_Valid=> rlc_valid,
            Data_In     => quant_data_out,
            Data_Out    => rlc_data_out
        );

    -- Output assignment
    Data_Out <= rlc_data_out;
    Data_Valid_Out <= rlc_valid;

end Behavioral;