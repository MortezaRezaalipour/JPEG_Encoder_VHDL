# A Simple JPEG Encoder in VHDL


## Modules Description
- `Shift.vhd`: Preprocesses the input data by normalizing it.
- `DCT2D.vhd`: Applies the Discrete Cosine Transform to the preprocessed data.
- `Quantization.vhd`: Quantizes the DCT coefficients to reduce the data size.
- `RLC.vhd`: Performs Run-Length Coding on the quantized data for entropy encoding.
- `NewJPEG_Package.vhd`: Contains common definitions and utilities used by the other modules.
- `JPEG_Encoder.vhd`: The top-level module that integrates all the stages of the JPEG encoding process.

---

### Requirements

Install ghdl to compile codes and gtkwave to show signals visually.

- Linux

```bash
sudo apt-get install ghdl gtkwave
```

- Mac

You can also install scansion instead of gtkwave.

```zsh
brew install ghdl gtkwave
```

- Windows

Install make, ghdl and gtkwave using [msys2](https://www.msys2.org/)

[make](https://packages.msys2.org/package/make)

[ghdl](https://packages.msys2.org/base/mingw-w64-ghdl)

[gtkwave](https://packages.msys2.org/base/mingw-w64-gtkwave)

---

# Further Description

## Shift Module 

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


## DCT2D Module

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


## Quantization Module

### Overview
`NewQuantization` is a VHDL module designed for quantizing the DCT coefficients in the JPEG compression process. Quantization is critical for compressing the image data by reducing the precision of the DCT coefficients, thereby retaining only the most significant parts of the data.

### Port Descriptions
- `CLK`: Clock input for synchronization.
- `Input_Valid`: Signal indicating when the input data `A_In` is valid.
- `Output_Valid`: Signal indicating when the output data `B_out` is valid.
- `A_In`: 12-bit input data port for the incoming DCT coefficients.
- `B_out`: 8-bit output data port for the quantized coefficients.

### Internal Behavior
The `NewQuantization` module operates through a finite state machine (FSM) with two main states:
1. **Input**: Captures incoming DCT coefficients into an internal RAM when `Input_Valid` is asserted.
2. **Output**: Quantizes the coefficients by truncating them and then outputs the significant bits.

### Quantization Process
The quantization in this module is performed by truncating the least significant bits from the 12-bit input coefficients, effectively reducing each to 8 bits. This process decreases data size, which is essential for the compression efficiency in JPEG encoding.

### Example Operation
- During the `Input` state, the module stores the 12-bit DCT coefficients in internal RAM as they arrive.
- In the `Output` state, the module processes this RAM-stored data by truncating each coefficient to its most significant 8 bits for output, thereby completing the quantization step.

### Key Points
- `NewQuantization` is pivotal in the JPEG encoding pipeline, impacting both the compression ratio and the image quality.
- The module interfaces directly with the DCT coefficients, aligning with the JPEG standard's typical block processing approach, which operates on 8x8 pixel blocks.


## RLC Module

### Overview
`NewRLC` (Run-Length Coding) is a VHDL module integral to the JPEG encoding process, specifically designed to compress the quantized DCT coefficients through run-length encoding. This process reduces the size of data blocks by encoding sequences of identical values compactly.

### Port Descriptions
- `CLK`: Clock input for synchronization.
- `Input_Valid`: Signal indicating when the input data `A_In` is valid.
- `Output_Valid`: Signal to indicate when the output data `B_out` is valid.
- `A_In`: 8-bit input data port for the quantized DCT coefficients.
- `B_out`: Custom data type `Vector_3Bytes` output port for the encoded data.

### Internal Behavior
`NewRLC` operates in several states, forming part of a state machine:
1. **Input**: Captures incoming quantized data into an internal buffer.
2. **DC_Encoding**: Encodes the DC coefficient (the first coefficient in each block) using differential encoding.
3. **AC_Encoding**: Encodes the AC coefficients (the remaining coefficients) using run-length encoding.
4. **Output**: Outputs the run-length encoded data.

### Encoding Process
- DC coefficients are encoded by calculating the difference from the previous block's DC coefficient and then encoding this difference.
- AC coefficients are encoded by counting consecutive zeros followed by the next non-zero value, producing a pair of values: the number of zeros and the actual non-zero value.

### Example Operation
- In the `Input` state, the module stores the incoming data until all required coefficients are received.
- The `DC_Encoding` and `AC_Encoding` states process the data to apply the run-length encoding algorithm.
- In the `Output` state, the module provides the run-length encoded data, ready for further processing or storage.

### Key Points
- `NewRLC` is crucial for the JPEG compression efficiency, significantly reducing the data size after quantization.
- The module deals with one 8x8 block of image data at a time, consistent with the JPEG standard block processing.




## Contributing
Contributions to the project are welcome. Please follow the standard GitHub pull request process to propose changes.


## Contact
For any inquiries or contributions, please contact Morteza at Rezaalipour.usi@gmail.com.
