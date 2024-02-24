import cocotb
from cocotb.triggers import Timer, RisingEdge, FallingEdge, First
from cocotb.clock import Clock
import numpy as np

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
    timer = Timer(2*FRAME_SIZE*BPP*CLK_PER, units='ns')
    sreg = cocotb.start_soon(sreg_model(dut))
    result = await First(sreg,timer)
    if result == timer:
        print("TIMEOUT!!")
    else:
        # print("Sreg line completed")
        pass



async def sreg_model(dut):
    size = 64
    col_cnt = 0
    row_cnt = 0
    sreg1 = size*[(0,0,0)] # [max..0]
    sreg2 = size*[(0,0,0)] # [max..0]
    while True:
        await RisingEdge(dut.O_CLK)
        pix = (dut.R1.value, dut.G1.value, dut.B1.value)
        sreg1 = sreg1[1:] + [pix]
        print(f'Col: {col_cnt} Row: {row_cnt} Val: {pix}')
        if (col_cnt-1) < (size-1):
            col_cnt += 1
        else:
            print(f"Finished line {row_cnt}")
            col_cnt = 0
            row_cnt += 1
            if (row_cnt-1) == (size-1):
                print("Frame finished")
                break
            
            

    

    