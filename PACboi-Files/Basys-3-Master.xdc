## ====================================================================
## Constraints File (.xdc) for Digilent Basys 3 (Artix-7 XC7A35T)
## Project: PacBoi Interactive Game (VHDL)
## Based on: Tabel 3.1 Tugas 3 Sisdig Lanjut
## ====================================================================

## Clock signal (100 MHz oscillator)
set_property PACKAGE_PIN W5 [get_ports clk]							
	set_property IOSTANDARD LVCMOS33 [get_ports clk]
	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

## Slide Switches
## sw_reset -> SW0 (V17)
set_property PACKAGE_PIN V17 [get_ports sw_reset]					
	set_property IOSTANDARD LVCMOS33 [get_ports sw_reset]

## Push Buttons
## btn_start -> btnC (U18)
set_property PACKAGE_PIN U18 [get_ports btn_start]						
	set_property IOSTANDARD LVCMOS33 [get_ports btn_start]
## btn_up    -> btnU (T18)
set_property PACKAGE_PIN T18 [get_ports btn_up]						
	set_property IOSTANDARD LVCMOS33 [get_ports btn_up]
## btn_left  -> btnL (W19)
set_property PACKAGE_PIN W19 [get_ports btn_left]						
	set_property IOSTANDARD LVCMOS33 [get_ports btn_left]
## btn_right -> btnR (T17)
set_property PACKAGE_PIN T17 [get_ports btn_right]						
	set_property IOSTANDARD LVCMOS33 [get_ports btn_right]
## btn_down  -> btnD (U17)
set_property PACKAGE_PIN U17 [get_ports btn_down]						
	set_property IOSTANDARD LVCMOS33 [get_ports btn_down]

## VGA Connector (12-bit RGB + HSYNC + VSYNC)
## Red channel
set_property PACKAGE_PIN G19 [get_ports {vgaRed[0]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[0]}]
set_property PACKAGE_PIN H19 [get_ports {vgaRed[1]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[1]}]
set_property PACKAGE_PIN J19 [get_ports {vgaRed[2]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[2]}]
set_property PACKAGE_PIN N19 [get_ports {vgaRed[3]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[3]}]

## Green channel
set_property PACKAGE_PIN J17 [get_ports {vgaGreen[0]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[0]}]
set_property PACKAGE_PIN H17 [get_ports {vgaGreen[1]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[1]}]
set_property PACKAGE_PIN G17 [get_ports {vgaGreen[2]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[2]}]
set_property PACKAGE_PIN D17 [get_ports {vgaGreen[3]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[3]}]

## Blue channel
set_property PACKAGE_PIN N18 [get_ports {vgaBlue[0]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[0]}]
set_property PACKAGE_PIN L18 [get_ports {vgaBlue[1]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[1]}]
set_property PACKAGE_PIN K18 [get_ports {vgaBlue[2]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[2]}]
set_property PACKAGE_PIN J18 [get_ports {vgaBlue[3]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[3]}]

## Synchronization signals
set_property PACKAGE_PIN P19 [get_ports hsync]						
	set_property IOSTANDARD LVCMOS33 [get_ports hsync]
set_property PACKAGE_PIN R19 [get_ports vsync]						
	set_property IOSTANDARD LVCMOS33 [get_ports vsync]

## Configuration options
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

## Clock routing override (bila clk_25mhz dari fabric divider memicu DRC error CKLD-1/PLCK-12)
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets -hierarchical *reg_25m*]
