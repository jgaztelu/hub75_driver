import cocotb
from cocotb.triggers import Timer
from cocotb.clock import Clock

CLK_PER = 10
HLINES = 64
VLINES = 64
BPP = 8
FRAME_SIZE = HLINES*VLINES

@cocotb.test()
async def test_hub75_driver(dut):
    # Start clock
    c = Clock(dut.clk, CLK_PER, 'ns')
    await cocotb.start(c.start())

    # Initialize inputs and reset DUT
    dut.rst_n.value = 0
    dut.i_framebuf_wr_addr.value = 0
    dut.i_framebuf_wr_data.value = 0
    dut.i_framebuf_wr_en.value = 0
    dut.i_enable.value = 0
    await Timer(2*CLK_PER, units='ns')
    dut.rst_n.value = 1
    await Timer(2*CLK_PER, units='ns')
    dut.i_enable.value = 1
    await Timer(2*FRAME_SIZE*BPP*CLK_PER, units='ns')