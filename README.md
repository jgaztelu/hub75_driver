# hub75_driver
The goal of this project is to create a HUB75 Display driver using a MYIR Z-Turn board based on a Xilinx Zynq FPGA. Initially, I want to implement a simple frame buffer where I can write a static image from the Zynq's CPU and have it shown in the display. In the future, more advanced features can be added, like in-hardware gamma correction and double-buffering for video display.

HUB75 displays are cheap LED matrices which can be obtained, for example, from Aliexpress. However, they are "dumb" displays, meaning that we must control them manually by applying PWM to eaech pixel. In order to simplify the connections, the displays are line multiplexed, meaning we shift in one line worth of on/off RGB data at a time, and select the corresponding horizontal line by using the select pins. The protocol handling this is called the HUB75 protocol.

This is a learning project to help me explore the world of open source simulation with CocoTB, as well as get actual experience using real hardware.

## TODO

- [ ] Refine To-Do list
- [ ] Implement output driver
- [ ] Implement test pattern
- [ ] Implement framebuffer with AXI access
- [ ] Test with "fixed" ROM image
- [ ] Write to framebuffer from SW
