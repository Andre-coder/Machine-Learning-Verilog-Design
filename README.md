# Machine-Learning-Verilog-Design

Hardware-accelerated implementation of the k-Nearest Neighbors (k-NN) algorithm in Verilog, featuring an AXI-Stream interface for seamless integration with FPGA-based systems.

## Overview

This project demonstrates k-NN classifier designed for FPGAs, using Verilog HDL. The design supports high-speed data transfer and integration with embedded processors via the AXI-Stream protocol, making it suitable for edge AI and embedded machine learning applications.

## Features

- Pure Verilog k-NN algorithm
- AXI-Stream interface for flexible system integration
- Parameterizable k value and feature dimensions 
- Testbench and example input files included
- Compatible with Xilinx FPGA platforms (Arty Z7-20 and others)

## Getting Started

1. Clone the repository.
2. Add the source files to your FPGA project.
3. Simulate using the provided testbench or synthesize for your target FPGA.

## File Structure

- `/src` - Verilog source code
- `/testbench` - Testbench files
- `/docs` - Documentation and block diagrams

## Contact

For questions or contributions, please open an issue or reach out via email.

---

*For educational and research purposes only.*
