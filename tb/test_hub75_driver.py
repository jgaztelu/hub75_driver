import cocotb
from cocotb.triggers import Timer, RisingEdge, FallingEdge, First
from cocotb.clock import Clock
import numpy as np

CLK_PER = 10
HLINES = 64
VLINES = 64
BPP = 8
FRAME_SIZE = HLINES*VLINES
BASE_WAIT = 128

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
    # timer = Timer(2*FRAME_SIZE*BPP*CLK_PER, units='ns')
    # timer = Timer(HLINES*(BASE_WAIT*2**BPP)+HLINES*16, units='ns')
    # sreg = cocotb.start_soon(sreg_model(dut))
    for i in range(8):
        await RisingEdge(dut.hub75_control_i.new_row)
        print(f'Row {i}')
    # await RisingEdge(dut.hub75_control_i.new_frame)
    # await timer
    # result = await First(sreg,timer)
    # if result == timer:
    #     print("TIMEOUT!!")
    # else:
    #     await FallingEdge(dut.O_CLK)
        



async def sreg_model(dut):
    size = 64
    col_cnt = 0
    row_cnt = 0
    sreg1 = size*[(0,0,0)] # [max..0]
    sreg2 = size*[(0,0,0)] # [max..0]
    while True:
        await First(RisingEdge(dut.O_CLK), RisingEdge(dut.STB))
        if dut.STB.value:
            print(f"OE Received after {col_cnt} clock cycles")
            break
        else:
            pix = (dut.R1.value, dut.G1.value, dut.B1.value)
            sreg1 = sreg1[1:] + [pix]
            col_cnt += 1
            if col_cnt > (size-1):
                print("Overflow detected")
        



            
            

    

    