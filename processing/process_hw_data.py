import pandas as pd
import matplotlib.pyplot as plt


HW_DATA_PATH = "Data/hardware_data/hw_data_1000_samples.csv"
REF_DATA_PATH = "Data/MATLAB_sim_data/madgwick_sim_data.csv"
FRACT_WIDTH = 14


def main():
    hw_data = pd.read_csv(HW_DATA_PATH)
    hw_data = hw_data.iloc[:, :4]

    ref_data = pd.read_csv(REF_DATA_PATH)

    fixed_point_data = hw_data.map(lambda y: int_to_fixed_point(y, FRACT_WIDTH))
    fixed_point_data.columns = ['q_w_fixed', 'q_x_fixed', 'q_y_fixed', 'q_z_fixed']

    hw_data = pd.concat([hw_data, fixed_point_data], axis=1)
    hw_data.to_csv(HW_DATA_PATH, index=False)

    plt.figure(figsize=(14, 8))
    colors = {'q_w': 'blue', 'q_x': 'green', 'q_y': 'red', 'q_z': 'purple'}
    for col in ['q_w', 'q_x', 'q_y', 'q_z']:
        plt.plot(ref_data[col][:len(hw_data)], linestyle='dotted', color=colors[col], label=f'MATLAB_sim {col}')
        plt.plot(hw_data[col + '_fixed'], linestyle='solid', color=colors[col], label=f'Hardware {col}')

    plt.title('Comparison of q_w, q_x, q_y, q_z between MATLAB and FPGA Hardware processed Data')
    plt.xlabel('Sample')
    plt.ylabel('Value')
    plt.legend()
    plt.grid(True)
    plt.show()


def int_to_fixed_point(value, fractional_bits):
    # Convert the integer to signed 16-bit if necessary
    if value >= 2 ** (16 - 1):
        value -= 2 ** 16

    # Convert to fixed-point format by dividing by 2^fractional_bits
    return value / 2 ** fractional_bits


if __name__ == "__main__":
    main()
