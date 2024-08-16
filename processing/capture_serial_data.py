import serial
import csv
import os
import numpy as np
import subprocess
from datetime import datetime
from quaternion import Quaternion

# Define the serial port and baud rate.
serial_port = '/dev/ttyUSB1'
baud_rate = 115200  # Match the baud rate from the serial monitor

# Define the scale factors
ACCEL_SENSE_SCALE_FACTOR = 4096
GYRO_SENSE_SCALE_FACTOR = 65.5

INIT_EULER = [0, 0, 0]

# Compile the madgwick.c file
subprocess.run(["gcc", "processing/madgwick.c", "-o", "processing/madgwick", "-lm"])

# Initial reference quaternion
q_ref = Quaternion.from_euler(INIT_EULER)

# Define the headers for the CSV file
headers = [
    'timestamp', 'axRaw', 'ayRaw', 'azRaw', 'wxRaw', 'wyRaw', 'wzRaw',
    'ax', 'ay', 'az', 'wx', 'wy', 'wz',
    'qw_ref', 'qx_ref', 'qy_ref', 'qz_ref',
    'psi_ref', 'theta_ref', 'phi_ref'
]

# Create the output directory
timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
output_dir = f"processing/Data/mpu6050_data/MPU6050_data_{timestamp}"
os.makedirs(output_dir, exist_ok=True)
csv_filename = os.path.join(output_dir, "data.csv")

# Open the serial port
ser = serial.Serial(serial_port, baud_rate, timeout=1)

# Lists to keep track of timestamps and sample numbers
timestamps = []
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
                # Capture the timestamp
                current_timestamp = datetime.now()

                # Store the timestamp for later calculation of time deltas
                timestamps.append(current_timestamp)

                # Parse the line to extract the relevant data
                parts = line.split(',')
                if len(parts) == 7:  # Make sure we have all the expected parts
                    # Extract the raw values
                    axRaw = int(parts[1].split(':')[1].strip())
                    ayRaw = int(parts[2].split(':')[1].strip())
                    azRaw = int(parts[3].split(':')[1].strip())
                    wxRaw = int(parts[4].split(':')[1].strip())
                    wyRaw = int(parts[5].split(':')[1].strip())
                    wzRaw = int(parts[6].split(':')[1].strip())

                    # Process the accelerometer values
                    ax = axRaw / ACCEL_SENSE_SCALE_FACTOR * 9.81
                    ay = ayRaw / ACCEL_SENSE_SCALE_FACTOR * 9.81
                    az = azRaw / ACCEL_SENSE_SCALE_FACTOR * 9.81

                    # Process the gyroscope values
                    wx = np.radians(wxRaw / GYRO_SENSE_SCALE_FACTOR)
                    wy = np.radians(wyRaw / GYRO_SENSE_SCALE_FACTOR)
                    wz = np.radians(wzRaw / GYRO_SENSE_SCALE_FACTOR)

                    # Prepare input for Madgwick algorithm
                    madgwick_input = (
                        f"{ax:.12f}\n{ay:.12f}\n{az:.12f}\n"
                        f"{wx:.12f}\n{wy:.12f}\n{wz:.12f}\n"
                        f"{q_ref[0]:.12f}\n{q_ref[1]:.12f}\n{q_ref[2]:.12f}\n{q_ref[3]:.12f}\n"
                    )

                    # Run Madgwick algorithm
                    process = subprocess.Popen(["./processing/madgwick"], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
                    stdout, _ = process.communicate(input=madgwick_input)
                    q_ref = [float(q_part) for q_part in stdout.strip().split("\t")]

                    # Convert q_ref to Euler angles
                    euler_angles_ref = Quaternion.to_euler(q_ref)  # [psi, theta, phi]

                    # Combine data into a row
                    row_data = [
                        current_timestamp.strftime("%Y-%m-%d %H:%M:%S.%f"),
                        axRaw, ayRaw, azRaw, wxRaw, wyRaw, wzRaw,
                        ax, ay, az, wx, wy, wz,
                        q_ref[0], q_ref[1], q_ref[2], q_ref[3],
                        euler_angles_ref[0], euler_angles_ref[1], euler_angles_ref[2]
                    ]

                    # Write the row to the CSV file
                    csv_writer.writerow(row_data)

                    # Print the processed data to the terminal for verification
                    print(f"Timestamp: {current_timestamp.strftime('%Y-%m-%d %H:%M:%S.%f')}")
                    print(f"Processed data -> ax: {ax:.6f}, ay: {ay:.6f}, az: {az:.6f}, wx: {wx:.6f}, wy: {wy:.6f}, wz: {wz:.6f}")
                    print(f"Euler angles -> psi: {euler_angles_ref[0]:.6f}, theta: {euler_angles_ref[1]:.6f}, phi: {euler_angles_ref[2]:.6f}")
                    print("-" * 50)

                    sample_number += 1

except KeyboardInterrupt:
    print("Data capture stopped by user.")
    if len(timestamps) > 1:
        # Calculate the time deltas between consecutive timestamps
        time_deltas = [(timestamps[i] - timestamps[i-1]).total_seconds() for i in range(1, len(timestamps))]

        # Calculate the average time delta
        average_time_delta = sum(time_deltas) / len(time_deltas)

        # Print the average time delta
        print(f"Average time delta between samples: {average_time_delta:.6f} seconds")
except Exception as e:
    print(f"Error: {e}")
finally:
    ser.close()
    print(f"Serial port {serial_port} closed.")