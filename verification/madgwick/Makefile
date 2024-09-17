# The toplevel module (DUT)
TOPLEVEL_LANG = verilog

# Set the top level module in your Verilog design
TOPLEVEL = madgwick

# Point to the testbench Python file you created
MODULE = madgwick_tb

# Verilator executable and options
SIM = verilator
VERILATOR_COMPILE_ARGS += --cc --trace --top-module $(TOPLEVEL)
VERILATOR_LDFLAGS += -pthread

# Paths to the source files
VERILOG_SOURCES = $(PWD)/../../RVfpga/src/SweRVolfSoC/Peripherals/attitude_sensor/madgwick_filter/madgwick.sv \
                  $(PWD)/../../RVfpga/src/SweRVolfSoC/Peripherals/attitude_sensor/madgwick_filter/madgwickDefines.vh \
                  $(PWD)/../../RVfpga/src/SweRVolfSoC/Peripherals/attitude_sensor/madgwick_filter/fastInvSqrt/src/fastInvSqrt.sv \
                  $(PWD)/../../RVfpga/src/SweRVolfSoC/Peripherals/attitude_sensor/madgwick_filter/fastInvSqrt/src/fixToSingle.sv \
                  $(PWD)/../../RVfpga/src/SweRVolfSoC/Peripherals/attitude_sensor/madgwick_filter/fastInvSqrt/src/singleToFix.sv \
                  $(PWD)/../../RVfpga/src/SweRVolfSoC/Peripherals/attitude_sensor/madgwick_filter/fastInvSqrt/src/newtonRaphson.sv

# cocotb Python tests are expected to be in the same directory
PYTHONPATH := $(PWD)

# Include cocotb's makefiles
export COCOTB_REDUCED_LOG_FMT=1
include $(shell cocotb-config --makefiles)/Makefile.sim
