import os
import subprocess
import time

import pandas as pd
import numpy as np

from quaternion import Quaternion

DATA_FILE_PATH = r"Data/mpu6050_data/MPU6050_ESP32_10000_points.csv"
INIT_ROTATION = [0, 0, 0]   # Initial rotation in Euler representation
NORMALISE = False


def main():
    input_df = pd.read_csv(DATA_FILE_PATH)
    output_arr = np.zeros((len(input_df), 13))

    q = Quaternion.from_euler(e=INIT_ROTATION)

    subprocess.run(["gcc", "madgwick.c", "-o", "madgwick", "-lm"])

    for i in range(len(input_df)):
        data = input_df.loc[i].iloc[2: 8]
        if NORMALISE:
            norm = np.sqrt(data[0]**2 + data[1]**2 + data[2]**2 + data[3]**2)
            data = data / norm

        process = subprocess.Popen(["madgwick.exe"], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        stdout, _ = process.communicate(input=f"{data.iloc[0]:.5f}\n{data.iloc[1]:.5f}\n{data.iloc[2]:.5f}\n{data.iloc[3]:.5f}\n{data.iloc[4]:.5f}\n{data.iloc[5]:.5f}\n\n{q[0]:.5f}\n{q[1]:.5f}\n{q[2]:.5f}\n{q[3]:.5f}\n")
        q = [float(q_part) for q_part in stdout.replace("\n", "").split("\t")]
        output_arr[i, 0:6] = data
        output_arr[i, 6:10] = q
        output_arr[i, 10:13] = Quaternion.to_euler(q=output_arr[i, 6:10])

    output_df = pd.DataFrame(output_arr, columns=["ax", "ay", "az", "wx", "wy", "wz", "q_w", "q_x", "q_y", "q_z", "psi", "theta", "phi"])
    output_df.to_csv(os.path.join(os.path.dirname(os.path.abspath(__file__)), "Data", "filtered_data", f"filtered_output_{str(time.strftime('%d-%m-%y_%H-%M-%S'))}.csv"), index=False)

    Quaternion.animate_rotation(q_data=output_arr[:, 6:10])


if __name__ == "__main__":
    main()
