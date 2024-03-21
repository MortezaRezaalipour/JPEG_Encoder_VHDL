
## Modules Description
- `Shift.vhd`: Preprocesses the input data by normalizing it.
- `DCT2D.vhd`: Applies the Discrete Cosine Transform to the preprocessed data.
- `Quantization.vhd`: Quantizes the DCT coefficients to reduce the data size.
- `RLC.vhd`: Performs Run-Length Coding on the quantized data for entropy encoding.
- `NewJPEG_Package.vhd`: Contains common definitions and utilities used by the other modules.
- `JPEG_Encoder.vhd`: The top-level module that integrates all the stages of the JPEG encoding process.

## How to Use
1. Clone the repository to your local machine.
2. Open the project in your VHDL synthesis or simulation tool.
3. Ensure the tool recognizes the `src` directory where the module files are located.
4. Compile and simulate the `JPEG_Encoder.vhd` to verify the functionality.
5. Synthesize the design to generate the bitstream for FPGA or ASIC implementation.

## Prerequisites
- VHDL synthesis and simulation tool (e.g., Xilinx Vivado, ModelSim, or similar).
- Basic understanding of VHDL and digital design principles.

## Contributing
Contributions to the project are welcome. Please follow the standard GitHub pull request process to propose changes.


## Contact
For any inquiries or contributions, please contact Morteza at Rezaalipour.usi@gmail.com.
