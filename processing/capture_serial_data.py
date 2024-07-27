import serial
import csv
import os
from datetime import datetime

# Define the serial port and baud rate.
serial_port = '/dev/ttyUSB1'
baud_rate = 115200  # Match the baud rate from the serial monitor

# Define the headers for the CSV file
headers = ['a_x', 'a_y', 'a_z', 'w_x', 'w_y', 'w_z', 'q_w', 'q_x', 'q_y', 'q_z']

# Create the output directory if it doesn't exist
output_dir = 'Data/hardware_data'
os.makedirs(output_dir, exist_ok=True)

# Create a timestamped CSV file
timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
csv_filename = os.path.join(output_dir, f"HW_data_{timestamp}.csv")

# Open the serial port
ser = serial.Serial(serial_port, baud_rate, timeout=1)

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
                if len(data) == len(headers):
                    # Write the data to the CSV file
                    csv_writer.writerow(data)
                else:
                    print(f"Unexpected data format: {line}")

except KeyboardInterrupt:
    print("Data capture stopped by user.")
except Exception as e:
    print(f"Error: {e}")
finally:
    ser.close()
    print(f"Serial port {serial_port} closed.")
