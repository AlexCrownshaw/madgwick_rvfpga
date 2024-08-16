import os
import subprocess
import time
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from quaternion import Quaternion

# Paths
DATA_FILE_PATH = r"Data/mpu6050_data/MPU6050_ESP32_10000_points.csv"
HW_DATA_FILE_PATH = r"Data/MATLAB_sim_data/madgwick_sim_data.csv"

# Initial settings
INIT_ROTATION = [0, 0, 0]  # Initial rotation in Euler representation
NORMALISE = False


def process_mpu6050_data():
    input_df = pd.read_csv(DATA_FILE_PATH)
    output_arr = np.zeros((len(input_df), 13))

    # Initial quaternion from Euler angles
    q = Quaternion.from_euler(e=INIT_ROTATION)

    # Compile C code
    subprocess.run(["gcc", "madgwick.c", "-o", "madgwick", "-lm"])

    # Process each row
    for i in range(len(input_df)):
        data = input_df.loc[i].iloc[2:8]
        if NORMALISE:
            norm = np.sqrt(data[0]**2 + data[1]**2 + data[2]**2 + data[3]**2)
            data = data / norm

        # Run the Madgwick filter process
        process = subprocess.Popen(
            ["./madgwick"], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True
        )
        stdout, _ = process.communicate(
            input=f"{data.iloc[0]:.12f}\n{data.iloc[1]:.12f}\n{data.iloc[2]:.12f}\n{data.iloc[3]:.12f}\n{data.iloc[4]:.12f}\n{data.iloc[5]:.12f}\n\n{q[0]:.12f}\n{q[1]:.12f}\n{q[2]:.12f}\n{q[3]:.12f}\n"
        )
        q = [float(q_part) for q_part in stdout.replace("\n", "").split("\t")]
        output_arr[i, 0:6] = data
        output_arr[i, 6:10] = q
        output_arr[i, 10:13] = Quaternion.to_euler(q=output_arr[i, 6:10])

    # Create DataFrame
    output_df = pd.DataFrame(
        output_arr, columns=["ax", "ay", "az", "wx", "wy", "wz", "q_w", "q_x", "q_y", "q_z", "psi", "theta", "phi"]
    )
    output_path = os.path.join(
        os.path.dirname(os.path.abspath(__file__)), "Data", "filtered_data", f"filtered_output_{str(time.strftime('%d-%m-%y_%H-%M-%S'))}.csv"
    )
    output_df.to_csv(output_path, index=False)

    # Optional: Animate the rotation
    Quaternion.animate_rotation(q_data=output_arr[:, 6:10])

    return output_df


def plot_comparisons(output_df, hw_data_df):
    # Extract acceleration and angular velocity components
    qw_output, qx_output, qy_output, qz_output = output_df["q_w"], output_df["q_x"], output_df["q_y"], output_df["q_z"]

    # Extract hardware data with correct column names
    qw_hw, qx_hw, qy_hw, qz_hw = hw_data_df["q_w"], hw_data_df["q_x"], hw_data_df["q_y"], hw_data_df["q_z"]

    # Plot comparisons
    plt.figure(figsize=(12, 16))

    # Acceleration X comparison
    plt.subplot(4, 1, 1)
    plt.plot(qw_output, label="Ref qw")
    plt.plot(qw_hw, label="Hardware qw", linestyle="--")
    plt.title("Quaternion W Component Comparison")
    plt.xlabel("Sample")
    plt.ylabel("Acceleration (m/s²)")
    plt.legend()

    # Acceleration Y comparison
    plt.subplot(4, 1, 2)
    plt.plot(qx_output, label="Ref qx")
    plt.plot(qx_hw, label="Hardware qx", linestyle="--")
    plt.title("Quaternion X Component Comparison")
    plt.xlabel("Sample")
    plt.ylabel("Acceleration (m/s²)")
    plt.legend()

    # Acceleration Z comparison
    plt.subplot(4, 1, 3)
    plt.plot(qy_output, label="Ref qy")
    plt.plot(qy_hw, label="Hardware qy", linestyle="--")
    plt.title("Quaternion Y Component Comparison")
    plt.xlabel("Sample")
    plt.ylabel("Acceleration (m/s²)")
    plt.legend()

    # Angular Velocity X comparison
    plt.subplot(4, 1, 4)
    plt.plot(qz_output, label="Ref qz")
    plt.plot(qz_hw, label="Hardware qz", linestyle="--")
    plt.title("Quaternion Z Component Comparison")
    plt.xlabel("Sample")
    plt.ylabel("Angular Velocity (rad/s)")
    plt.legend()

    plt.tight_layout()
    plt.show()


def main():
    # Process the MPU6050 data
    output_df = process_mpu6050_data()

    # Load the hardware data
    hw_data_df = pd.read_csv(HW_DATA_FILE_PATH)

    # Plot comparisons
    plot_comparisons(output_df, hw_data_df)


if __name__ == "__main__":
    main()
