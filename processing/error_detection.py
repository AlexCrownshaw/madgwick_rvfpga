import numpy as np
import pandas as pd

REF_DATA_PATH = "Data/MATLAB_sim_data/madgwick_sim_data.csv"
HDL_SIM_DATA_PATH = "Data/HDL_data/HDL_data_2000_samples.csv"


def main():
    ref_data = pd.read_csv(REF_DATA_PATH)
    hdl_sim_data = pd.read_csv(HDL_SIM_DATA_PATH)

    # Define the columns to compare
    ref_columns = ['q_w', 'q_x', 'q_y', 'q_z']
    hdl_columns = ['q_w_fixed', 'q_x_fixed', 'q_y_fixed', 'q_z_fixed']

    # Compare each row and print the results
    for i in range(len(ref_data)):
        ref_row = ref_data.loc[i, ref_columns]
        hdl_row = hdl_sim_data.loc[i, hdl_columns]

        # Check if rows are equivalent
        equivalent = np.allclose(ref_row, hdl_row, atol=1e-8)
        print(f"Row {i}: {'Equivalent' if equivalent else 'Not Equivalent'} - Ref Data: {list(ref_row)} - HDL Data: {list(hdl_row)}")


if __name__ == "__main__":
    main()
