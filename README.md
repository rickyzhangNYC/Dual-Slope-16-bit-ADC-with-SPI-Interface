# Dual-Slope-16-bit-ADC-with-SPI-Interface
Written in VHDL. <br />
1)Design for a controller (TC514ctrl), implemented using an FPGA, that controls the Microchip TC514 Precision Analog Front End. <br />
2)Design for a finite state machine for the TC514 which sequences the operation modes of the controller. FSM is implemented as a Moore Machine. <br />
3)Design for top level entity tc514_adc_SPI, which implements the SPI. <br />
4)Design for the serializer FSM which sequences the states in which data is available and should be output. <br />
