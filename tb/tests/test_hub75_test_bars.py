import cocotb
from cocotb.triggers import Timer,ClockCycles,RisingEdge,FallingEdge,First
from cocotb.clock import Clock

import logging

CLK_PER = 10
HLINES = 64
VLINES = 64
BPP = 8
FRAME_SIZE = HLINES*VLINES

class HUB75_monitor():
    def __init__ (self, dut, hpixels, vpixels):
        self.dut = dut
        self.log = logging.getLogger('cocotb_tb')
        self.log.setLevel(logging.DEBUG)
        self.log.info("Hello from the HUB75 monitor!")
        self.hpixels = hpixels
        self.vpixels = vpixels
        self.sreg = [0 for x in range(self.hpixels)]
        self.sreg_ptr = 0
        self.latch = [0 for x in range(self.hpixels)]
        self.display = [[0 for x in range(self.vpixels)] for y in range(self.hpixels)]
      
    async def sregMon(self):
        while True:
            print("Hola")
            await RisingEdge(self.dut.O_CLK)
            self.sreg = [self.dut.R1.value] + self.sreg[:-1] # Shift list and append new value at beginning
            self.log.debug("New sreg value: %s", self.dut.R1.value)
            self.log.debug("Shift register status: %s", self.sreg)

    async def start_monitor(self):
        self.log.info("Starting Shift register monitor")
        sreg_thread = cocotb.start(self.sregMon)
        # watchdog = Timer(500,units='ms')
        # self.log.info("Waiting for watchdog or monitor to finish")
        # await First(sreg_thread, watchdog)
    
@cocotb.test()
async def test_hub75_test_bars(dut):
    log = logging.getLogger('cocotb_tb')
    mon = HUB75_monitor(dut,HLINES,VLINES)
    log.info("Starting clock...")
    clock = cocotb.start_soon(Clock(dut.clk, CLK_PER, 'ns').start())

    # Initialize inputs and reset DUT
    dut.rst_n.value = 0
    dut.i_framebuf_wr_addr.value = 0
    dut.i_framebuf_wr_data.value = 0
    dut.i_framebuf_wr_en.value = 0
    dut.i_enable.value = 0
    dut.i_clk_div.value = 0
    await Timer(2*CLK_PER, units='ns')
    dut.rst_n.value = 1
    await Timer(2*CLK_PER, units='ns')
    dut.i_enable.value = 1
    dut.i_clk_div.value = 2

    await mon.start_monitor()