import pandas as pd
import matplotlib.pyplot as plt

from quaternion import Quaternion


def main():
    sim_data = pd.read_csv("Data/HDL_data/HDL_data_3000_samples.csv")
    sim_euler_angles = pd.DataFrame(columns=["psi", "theta", "phi"])

    for row in sim_data.itertuples(index=False):
        sim_euler_angles.loc[len(sim_euler_angles)] = Quaternion.to_euler(q=[row.q_w, row.q_x, row.q_y, row.q_z])

    ref_data = pd.read_csv("Data/MATLAB_sim_data/madgwick_sim_data_wider_mag_sqr.csv")

    # Plot comparison of the quaternions
    fig, axs = plt.subplots(4, 1, figsize=(12, 18))
    fig.suptitle('Comparison of Quaternions from Simulation and Reference Data')

    # Plot q_w
    axs[0].plot(sim_data.index, sim_data['q_w'], label='Sim Data q_w')
    axs[0].plot(ref_data.index, ref_data['q_w'], label='Ref Data q_w', linestyle='--')
    axs[0].set_ylabel('q_w')
    axs[0].legend()

    # Plot q_x
    axs[1].plot(sim_data.index, sim_data['q_x'], label='Sim Data q_x')
    axs[1].plot(ref_data.index, ref_data['q_x'], label='Ref Data q_x', linestyle='--')
    axs[1].set_ylabel('q_x')
    axs[1].legend()

    # Plot q_y
    axs[2].plot(sim_data.index, sim_data['q_y'], label='Sim Data q_y')
    axs[2].plot(ref_data.index, ref_data['q_y'], label='Ref Data q_y', linestyle='--')
    axs[2].set_ylabel('q_y')
    axs[2].legend()

    # Plot q_z
    axs[3].plot(sim_data.index, sim_data['q_z'], label='Sim Data q_z')
    axs[3].plot(ref_data.index, ref_data['q_z'], label='Ref Data q_z', linestyle='--')
    axs[3].set_ylabel('q_z')
    axs[3].legend()

    plt.xlabel('Index')
    plt.grid()

    # Extract Euler angles from reference data
    ref_euler_angles = ref_data[['psi', 'theta', 'phi']]

    # Plot comparison of the Euler angles
    fig, axs = plt.subplots(3, 1, figsize=(12, 18))
    fig.suptitle('Comparison of Euler Angles from Simulation and Reference Data')

    # Plot psi
    axs[0].plot(sim_euler_angles.index, sim_euler_angles['psi'], label='Sim Data psi')
    axs[0].plot(ref_euler_angles.index, ref_euler_angles['psi'], label='Ref Data psi', linestyle='--')
    axs[0].set_ylabel('psi')
    axs[0].legend()

    # Plot theta
    axs[1].plot(sim_euler_angles.index, sim_euler_angles['theta'], label='Sim Data theta')
    axs[1].plot(ref_euler_angles.index, ref_euler_angles['theta'], label='Ref Data theta', linestyle='--')
    axs[1].set_ylabel('theta')
    axs[1].legend()

    # Plot phi
    axs[2].plot(sim_euler_angles.index, sim_euler_angles['phi'], label='Sim Data phi')
    axs[2].plot(ref_euler_angles.index, ref_euler_angles['phi'], label='Ref Data phi', linestyle='--')
    axs[2].set_ylabel('phi')
    axs[2].legend()

    plt.xlabel('Index')
    plt.grid()
    plt.show()


if __name__ == "__main__":
    main()
