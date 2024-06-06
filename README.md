# madgwick_rvfpga
The aim of this project is to develop a digital hardware implementation of the Madgwick filter, a modern sensor fusion algorithm aimed at providing accurate attitude state estimates, even at low sensor data rates. Designing the filter in hardware allows for the computation of attitude state estimations to be offloaded from the processing cores of embedded systems. Some modern IMU’s such as the TDK InvenSense ICM-20948 offer onboard motion processing features however these digital algorithms are proprietary closed-source property. This project aims to develop an open-source digital design of an attitude state estimation algorithm that is agnostic to all IMU’s and can be easily implemented in a FPGA or System-on-Chip application. 
To highlight a usage example of the digital filter, and for development and testing purposes, the attitude state estimation algorithm will be integrated into the RISC-V SwerVolfX System-on-Chip (SoC) design on an Artix-7 FPGA. The integrated SPI core will be used to interface the SoC with an external IMU to prove out real-time attitude state processing capabilities. 
