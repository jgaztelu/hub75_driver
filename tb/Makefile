# Makefile
RTLDIR := $(PROJDIR)/rtl
# defaults
SIM ?= verilator
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += 	$(RTLDIR)/hub75_framebuf.sv \
					$(RTLDIR)/hub75_test_bars.sv \
					$(RTLDIR)/hub75_display.sv \
					$(RTLDIR)/hub75_driver.sv
				
# use VHDL_SOURCES for VHDL files

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = hub75_driver

# MODULE is the basename of the Python test file
MODULE = test_hub75_driver

EXTRA_ARGS += --trace-fst --trace-structs -Wno-WIDTH
# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim