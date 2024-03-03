import cocotb
from cocotb.triggers import Timer,ClockCycles,RisingEdge, FallingEdge, First
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

    async def mon_coro(self, max, clk):
        cocotb.log.info(f"Starting mon_coro with max count {max}")
        count = 0
        while True:
            cocotb.log.info(count)
            count += 1    
            if count == max:
                return count
            await RisingEdge(clk)

      
    async def start_monitor(self):
        self.log.info("Starting Shift register monitor")
        c1 = cocotb.start_soon(self.mon_coro(100, self.dut.clk))
        c2 = cocotb.start_soon(self.mon_coro(200, self.dut.clk))

        res = await First(c1,c2)
        print(f"Returned after {res} cc")
        


@cocotb.test()
async def test_hub75_driver(dut):
    mon = HUB75_monitor(dut, HLINES, VLINES)

    # Start clock
    c = Clock(dut.clk, CLK_PER, 'ns')
    await cocotb.start(c.start())

    await mon.start_monitor()
    print("Monitor started")
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
    await FallingEdge(dut.A)
    await RisingEdge(dut.D)