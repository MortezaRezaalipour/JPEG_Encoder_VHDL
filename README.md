# A Simple JPEG Encoder in VHDL


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

# Further Description

## Shift Module (NewShift)

### Overview
`NewShift` is a VHDL module designed to perform data shifting operations, commonly used in image processing tasks like JPEG encoding. This module serially receives image data, shifts it for normalization or other processing needs, and outputs the shifted data.

### Port Descriptions
- `CLK`: Clock input for synchronization.
- `Input_Valid`: Signal indicating valid input data.
- `Output_Valid`: Signal indicating valid output data.
- `A_In`: 8-bit input data port.
- `B_out`: 8-bit output data port.

### Internal Behavior
The module operates in three main states controlled by an internal state machine:
1. **Input**: Captures incoming data into a 64-byte RAM when `Input_Valid` is high.
2. **Shift**: Applies a shift operation (e.g., subtracting 128) to each byte in RAM to normalize the data.
3. **Output**: Sends out the shifted data through `B_out` and indicates data validity through `Output_Valid`.

### Architecture
- Utilizes a finite state machine (FSM) with states: `Input`, `Shift`, and `Output`.
- Employs a 64-byte RAM (`RAM64Bytes`) for temporary storage of input data.
- Uses a 6-bit index (`i`) to access RAM locations sequentially.

### Example Operation
1. During the `Input` state, the module fills the RAM with data from `A_In` as long as `Input_Valid` is asserted. It increments the `i` counter after storing each byte.
2. Once the RAM is full, the module transitions to the `Shift` state, where it subtracts `128` (binary `10000000`) from each byte in the RAM, effectively normalizing the data.
3. In the `Output` state, the module sends out the shifted data through `B_out` and sets `Output_Valid` high for each byte outputted. The `i` counter is incremented similarly to the input phase.

### Key Points
- This module is crucial for preprocessing data in image encoding pipelines, particularly for JPEG encoding, where data normalization is a necessary step before the DCT (Discrete Cosine Transform).
- The shift operation in the `Shift` state is crucial for centering the pixel value range around zero, a common requirement in image processing algorithms.


## NewDCT2D Module

### Overview
`NewDCT2D` is a VHDL module designed to perform a 2-dimensional Discrete Cosine Transform (DCT) on 8x8 blocks of image data. This operation is a key part of the JPEG image compression process, converting spatial pixel data into frequency domain coefficients.

### Port Descriptions
- `CLK`: Clock input for synchronization.
- `Input_Valid`: Signal indicating when the input data `A_In` is valid.
- `Output_Valid`: Signal indicating when the output data `B_out` is valid.
- `A_In`: 8-bit input data port for incoming image data.
- `B_out`: 12-bit output data port for DCT coefficients.

### Internal Behavior
The module processes data in multiple states managed by a finite state machine (FSM):
1. **Input**: Captures 8x8 blocks of image data into an internal RAM.
2. **Store_Matrix**: Transfers data from RAM into a processing matrix.
3. **DCT1D**: Performs the 1D DCT on rows of the matrix.
4. **DCT1D_T**: Transposes and performs 1D DCT on columns, effectively completing the 2D DCT.
5. **Store_RAM**: Stores the transformed coefficients back into a RAM buffer.
6. **Output**: Sequentially outputs the DCT coefficients from the RAM buffer.

The transformation process involves multiplying image data by a fixed cosine matrix, which represents the DCT basis functions, to obtain frequency-domain representations.

### Example Operation
The operation starts when 64 bytes of data (representing an 8x8 image block) are received and stored in internal RAM. Once the block is fully received, the data is organized into a matrix and the DCT process begins. The 1D DCT is applied first to rows, then the result is transposed and the 1D DCT is applied to columns. The final DCT coefficients are stored back in RAM, ready for output.

### Key Points
- `NewDCT2D` implements critical functionality for JPEG encoding, specifically the transformation of pixel data into a format that can be effectively compressed.
- It works on a block-by-block basis, processing 8x8 blocks of data which is standard in JPEG compression.






## Contributing
Contributions to the project are welcome. Please follow the standard GitHub pull request process to propose changes.


## Contact
For any inquiries or contributions, please contact Morteza at Rezaalipour.usi@gmail.com.
