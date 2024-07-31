import serial
import csv
import os
import numpy as np
import matplotlib.pyplot as plt
from datetime import datetime
from quaternion import Quaternion

FRACT_WIDTH = 14

def int_to_fixed_point(value, fractional_bits):
    # Convert the integer to signed 16-bit if necessary
    if value >= 2 ** (16 - 1):
        value -= 2 ** 16
    # Convert to fixed-point format by dividing by 2^fractional_bits
    return value / 2 ** fractional_bits

# Define the serial port and baud rate.
serial_port = '/dev/ttyUSB1'
baud_rate = 115200  # Match the baud rate from the serial monitor

# Define the headers for the CSV file
headers = [
    'a_x', 'a_y', 'a_z', 'w_x', 'w_y', 'w_z', 'q_w_int', 'q_x_int', 'q_y_int', 'q_z_int',
    'a_x_fp', 'a_y_fp', 'a_z_fp', 'w_x_fp', 'w_y_fp', 'w_z_fp', 'q_w', 'q_x', 'q_y', 'q_z',
    'psi', 'theta', 'phi'
]

# Create the output directory
timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
output_dir = f"processing/Data/hardware_data/HW_data_{timestamp}"
os.makedirs(output_dir, exist_ok=True)
csv_filename = os.path.join(output_dir, "data.csv")

# Open the serial port
ser = serial.Serial(serial_port, baud_rate, timeout=1)

# Lists to store data for plotting
q_data_fp = {header: [] for header in headers[16:20]}  # q_w, q_x, q_y, q_z
euler_data = {header: [] for header in headers[20:]}  # psi, theta, phi
sample_number = 0

try:
    with open(csv_filename, 'w', newline='') as csvfile:
        csv_writer = csv.writer(csvfile)
        # Write the headers to the CSV file
        csv_writer.writerow(headers)

        print(f"Capturing data to {csv_filename}... Press Ctrl+C to stop.")

        while True:
            # Read a line from the serial port
            line = ser.readline().decode('utf-8').strip()
            if line:
                # Split the line by commas
                data = line.split(',')
                # Ensure the data has the correct number of columns
                if len(data) == 10:
                    # Convert to fixed-point values
                    fixed_point_data = [int_to_fixed_point(int(value), FRACT_WIDTH) for value in data]

                    # Convert to Euler angles
                    euler_angles = Quaternion.to_euler([fixed_point_data[6], fixed_point_data[7], fixed_point_data[8], fixed_point_data[9]])

                    # Combine all data
                    combined_data = data + fixed_point_data + euler_angles.tolist()

                    # Write the combined data to the CSV file
                    csv_writer.writerow(combined_data)

                    # Print the fixed-point data and Euler angles to the terminal
                    print("Fixed-point data:")
                    print(f"a_x_fp: {fixed_point_data[0]:.6f}, a_y_fp: {fixed_point_data[1]:.6f}, a_z_fp: {fixed_point_data[2]:.6f}")
                    print(f"w_x_fp: {fixed_point_data[3]:.6f}, w_y_fp: {fixed_point_data[4]:.6f}, w_z_fp: {fixed_point_data[5]:.6f}")
                    print(f"q_w: {fixed_point_data[6]:.6f}, q_x: {fixed_point_data[7]:.6f}, q_y: {fixed_point_data[8]:.6f}, q_z: {fixed_point_data[9]:.6f}")

                    print("Euler angles:")
                    print(f"psi: {euler_angles[0]:.6f}, theta: {euler_angles[1]:.6f}, phi: {euler_angles[2]:.6f}")
                    print("-" * 50)

                    # Store data for plotting
                    for i, header in enumerate(headers[16:20]):
                        q_data_fp[header].append(fixed_point_data[i+6])
                    for i, header in enumerate(headers[20:]):
                        euler_data[header].append(euler_angles[i])

                    sample_number += 1
                else:
                    print(f"Unexpected data format: {line}")

except KeyboardInterrupt:
    print("Data capture stopped by user.")
except Exception as e:
    print(f"Error: {e}")
finally:
    ser.close()
    print(f"Serial port {serial_port} closed.")

    # Plot quaternion fixed-point data
    plt.figure(figsize=(10, 8))
    for i, (header, data) in enumerate(q_data_fp.items()):
        plt.subplot(4, 1, i+1)
        plt.plot(range(sample_number), data, label=header)
        plt.ylabel(header)
        plt.legend(loc='upper right')
        plt.grid(True)
        plt.ylim(min(data) - 0.1 * abs(min(data)), max(data) + 0.1 * abs(max(data)))
    plt.xlabel("Sample Number")
    plt.suptitle("Quaternion Fixed-Point Data")
    plt.tight_layout(rect=[0, 0, 1, 0.96])
    plt.savefig(os.path.join(output_dir, "quaternion_data.png"))

    # Plot Euler angles data
    plt.figure(figsize=(10, 6))
    for i, (header, data) in enumerate(euler_data.items()):
        plt.subplot(3, 1, i+1)
        plt.plot(range(sample_number), data, label=header)
        plt.ylabel(header)
        plt.legend(loc='upper right')
        plt.grid(True)
        plt.ylim(min(data) - 0.1 * abs(min(data)), max(data) + 0.1 * abs(max(data)))
    plt.xlabel("Sample Number")
    plt.suptitle("Euler Angles Data")
    plt.tight_layout(rect=[0, 0, 1, 0.96])
    plt.savefig(os.path.join(output_dir, "euler_data.png"))

    print(f"Plots saved in {output_dir}")
