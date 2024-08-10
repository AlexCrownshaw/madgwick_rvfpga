import serial
import csv
import os
import numpy as np
import matplotlib.pyplot as plt
import subprocess
from datetime import datetime
from quaternion import Quaternion

# Define the fractional widths
ACC_FRACT_WIDTH = 6  # Fractional bits for accelerometer data
GYRO_FRACT_WIDTH = 8  # Fractional bits for gyroscope data
Q_FRACT_WIDTH = 14     # Fractional bits for quaternion data

def int_to_fixed_point(value, fractional_bits):
    # Convert the integer to signed 16-bit if necessary
    if value >= 2 ** (16 - 1):
        value -= 2 ** 16
    # Convert to fixed-point format by dividing by 2^fractional_bits
    return value / 2 ** fractional_bits

# Compile the madgwick.c file
subprocess.run(["gcc", "processing/madgwick.c", "-o", "processing/madgwick", "-lm"])

# Define the serial port and baud rate.
serial_port = '/dev/ttyUSB1'
baud_rate = 115200  # Match the baud rate from the serial monitor

# Define the headers for the CSV file
headers = [
    'a_x_int', 'a_y_int', 'a_z_int', 'w_x_int', 'w_y_int', 'w_z_int', 'q_w_int', 'q_x_int', 'q_y_int', 'q_z_int',
    'a_x', 'a_y', 'a_z', 'w_x', 'w_y', 'w_z', 'q_w', 'q_x', 'q_y', 'q_z',
    'psi', 'theta', 'phi',
    'q_w_ref', 'q_x_ref', 'q_y_ref', 'q_z_ref', 'psi_ref', 'theta_ref', 'phi_ref',
    'psi_err', 'theta_err', 'phi_err'
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
euler_data = {header: [] for header in headers[20:23]}  # psi, theta, phi
euler_err_data = {header: [] for header in headers[-3:]}  # psi_err, theta_err, phi_err

sample_number = 0
q_ref = [1.0, 0.0, 0.0, 0.0]  # Initial reference quaternion

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
                    acc_fixed_point_data = [int_to_fixed_point(int(data[i]), ACC_FRACT_WIDTH) for i in range(3)]
                    gyro_fixed_point_data = [int_to_fixed_point(int(data[i]), GYRO_FRACT_WIDTH) for i in range(3, 6)]
                    quat_fixed_point_data = [int_to_fixed_point(int(data[i]), Q_FRACT_WIDTH) for i in range(6, 10)]

                    # Convert to Euler angles
                    euler_angles = Quaternion.to_euler(quat_fixed_point_data)

                    # Compute quaternion using Madgwick algorithm
                    madgwick_input = (
                        f"{acc_fixed_point_data[0]:.12f}\n{acc_fixed_point_data[1]:.12f}\n{acc_fixed_point_data[2]:.12f}\n"
                        f"{gyro_fixed_point_data[0]:.12f}\n{gyro_fixed_point_data[1]:.12f}\n{gyro_fixed_point_data[2]:.12f}\n"
                        f"{q_ref[0]:.12f}\n{q_ref[1]:.12f}\n{q_ref[2]:.12f}\n{q_ref[3]:.12f}\n"
                    )

                    process = subprocess.Popen(["./processing/madgwick"], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
                    stdout, _ = process.communicate(input=madgwick_input)
                    q_ref = [float(q_part) for q_part in stdout.strip().split("\t")]

                    # Convert q_ref to Euler angles
                    euler_angles_ref = Quaternion.to_euler(q_ref)

                    # Compute Euler angle errors
                    euler_angle_errors = np.abs(np.array(euler_angles) - np.array(euler_angles_ref))

                    # Combine all data
                    combined_data = data + acc_fixed_point_data + gyro_fixed_point_data + quat_fixed_point_data + euler_angles.tolist() + q_ref + euler_angles_ref.tolist() + euler_angle_errors.tolist()

                    # Write the combined data to the CSV file
                    csv_writer.writerow(combined_data)

                    # Print the fixed-point data and Euler angle errors to the terminal
                    print("Fixed-point data:")
                    print(f"a_x: {acc_fixed_point_data[0]:.6f}, a_y: {acc_fixed_point_data[1]:.6f}, a_z: {acc_fixed_point_data[2]:.6f}")
                    print(f"w_x: {gyro_fixed_point_data[0]:.6f}, w_y: {gyro_fixed_point_data[1]:.6f}, w_z: {gyro_fixed_point_data[2]:.6f}")
                    print(f"q_w: {quat_fixed_point_data[0]:.6f}, q_x: {quat_fixed_point_data[1]:.6f}, q_y: {quat_fixed_point_data[2]:.6f}, q_z: {quat_fixed_point_data[3]:.6f}")

                    print("Euler angles:")
                    print(f"psi: {euler_angles[0]:.6f}, theta: {euler_angles[1]:.6f}, phi: {euler_angles[2]:.6f}")

                    # Print Euler angle error magnitudes
                    print("Euler angle error magnitudes:")
                    print(f"psi_err: {euler_angle_errors[0]:.6f}, theta_err: {euler_angle_errors[1]:.6f}, phi_err: {euler_angle_errors[2]:.6f}")
                    print("-" * 50)

                    # Store data for plotting
                    for i, header in enumerate(headers[16:20]):
                        q_data_fp[header].append(quat_fixed_point_data[i])
                    for i, header in enumerate(headers[20:23]):
                        euler_data[header].append(euler_angles[i])
                    for i, header in enumerate(headers[-3:]):
                        euler_err_data[header].append(euler_angle_errors[i])

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

    # Plot Euler angles error data
    plt.figure(figsize=(10, 6))
    for i, (header, data) in enumerate(euler_err_data.items()):
        plt.subplot(3, 1, i+1)
        plt.plot(range(sample_number), data, label=header)
        plt.ylabel(header)
        plt.legend(loc='upper right')
        plt.grid(True)
        plt.ylim(min(data) - 0.1 * abs(min(data)), max(data) + 0.1 * abs(max(data)))
    plt.xlabel("Sample Number")
    plt.suptitle("Euler Angles Error Data")
    plt.tight_layout(rect=[0, 0, 1, 0.96])
    plt.savefig(os.path.join(output_dir, "euler_error_data.png"))

    print(f"Plots saved in {output_dir}")
