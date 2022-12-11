import cocotb
from cocotb.triggers import Timer
from cocotb.clock import Clock

@cocotb.test()
async def test_hub75_driver(dut):
    c = Clock(dut.clk, 10, 'ns')
    await cocotb.start(c.start())
    await Timer(50, units='ns')