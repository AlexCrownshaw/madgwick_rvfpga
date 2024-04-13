# madgwick_rvfpga
The Madgwick filter is a quaternion-based algorithm that fuses accelerometer and gyroscope data from an inertial measurement unit (IMU) to form an enhanced attitude estimate. The Madgwick filter is a lightweight alternative to the extended Kalman Filter which is often used for IMU attitude state estimation. Modern mechanical electro-magnetic (MEM) IMU integrated circuits often contain digital filters allowing them to output attitude estimates directly, often termed, Digital Motion Processing (DMP). The aim of this project is to develop a digital implementation of the Madgwick filter that could be used on a modern inertial measurement IC providing DMP functionality. The RVFPGA platform can be used to interface an existing IMU peripheral device to prove out the filter performance using real-time accelerometer and gyroscope data as well as controlling filter inputs and outputs. 
