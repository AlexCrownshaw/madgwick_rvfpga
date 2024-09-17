import cocotb
import pandas as pd

from cocotb.triggers import RisingEdge, Timer


TEST_VECTORS = pd.read_csv("../../processing/Data/mpu6050_data/Sample_Data.csv")


@cocotb.test()
async def madgwick_tb(dut):
    """
    Testbench for Madgwick filter using cocotb.
    """
    # Clock generation
    cocotb.start_soon(clock_gen(dut.clk))

    # Reset the DUT
    await reset_dut(dut)

    # Open a file to write output
    output_file = "behavioral_sim_data.txt"
    with open(output_file, "w") as f:
        f.write("q_w,q_x,q_y,q_z\n")

        # Run test vectors
        for i in range(len(TEST_VECTORS)):
            await apply_inputs_and_sample(dut, f, i)

    # Complete the test
    dut._log.info(f"Simulation completed. Data written to {output_file}.")


async def clock_gen(clk):
    """Generate clock pulses with a period of 10ns (100MHz)."""
    while True:
        clk.value = 0
        await Timer(5, units="ns")
        clk.value = 1
        await Timer(5, units="ns")


async def reset_dut(dut):
    """Apply reset to the DUT."""
    dut.rst_n.value = 0
    dut.valid_in.value = 0
    dut.ready_out.value = 0
    dut.a_x.value = 0
    dut.a_y.value = 0
    dut.a_z.value = 0
    dut.w_x.value = 0
    dut.w_y.value = 0
    dut.w_z.value = 0

    await Timer(25, units="ns")  # Hold reset for 25ns
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)


async def apply_inputs_and_sample(dut, f, i):
    """Apply inputs to DUT, wait for outputs, and capture data."""
    # Apply test vector inputs
    dut.a_x.value = TEST_VECTORS.ax.iloc[i]
    dut.a_y.value = TEST_VECTORS.ay.iloc[i]
    dut.a_z.value = TEST_VECTORS.az.iloc[i]
    dut.w_x.value = TEST_VECTORS.wx.iloc[i]
    dut.w_y.value = TEST_VECTORS.wy.iloc[i]
    dut.w_z.value = TEST_VECTORS.wz.iloc[i]

    # Set valid_in and wait for ready_in
    dut.valid_in.value = 1
    await RisingEdge(dut.clk)
    while not dut.ready_in.value:
        await RisingEdge(dut.clk)

    # Capture output when valid_out and ready_out are set
    dut.valid_in.value = 0
    dut.ready_out.value = 1
    while not (dut.valid_out.value and dut.ready_out.value):
        await RisingEdge(dut.clk)

    # Capture and log the results
    q_w = dut.q_w_norm_output.value.signed_integer
    q_x = dut.q_x_norm_output.value.signed_integer
    q_y = dut.q_y_norm_output.value.signed_integer
    q_z = dut.q_z_norm_output.value.signed_integer

    dut._log.info(f"Output: {q_w},{q_x},{q_y},{q_z}")
    f.write(f"{q_w},{q_x},{q_y},{q_z}\n")

    # Clear ready_out after capture
    dut.ready_out.value = 0
    await RisingEdge(dut.clk)
