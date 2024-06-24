import os
import serial

import pandas as pd


PORT = "COM3"
BAUD = 115200
NUM_DATA_POINTS = 10000


def main():
    df = pd.DataFrame(columns=["t", "ax", "ay", "az", "wx", "wy", "wz"])

    try:
        ser = serial.Serial(PORT, BAUD, timeout=1)
        for _ in range(NUM_DATA_POINTS):
            data = ser.readline().decode().strip().split('\t')
            if data:
                print(data)
                if len(data) == len(df.columns):
                    df.loc[len(df)] = [float(j) for j in data]
    except serial.SerialException as e:
        print(f"Error: {e}")

    df.to_csv(os.path.join(os.path.dirname(os.path.abspath(__file__)), "Data", "mpu6050_data", f"MPU6050_ESP32_{NUM_DATA_POINTS}_points.csv"), index=True)


if __name__ == "__main__":
    main()
