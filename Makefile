all:
	mkdir -p build
	yosys  -q -p "synth_ice40 -top top -blif build/top_icestick.blif" top_icestick.v timing_generator.v frame_buffer.v dvi_encoder.v ddr_serializer.v clk_divider.v
	arachne-pnr -d 1k -o build/top_icestick.asc -p top_icestick.pcf build/top_icestick.blif
	icepack build/top_icestick.asc build/top_icestick.bin
	icetime -d hx1k -mt build/top_icestick.asc
	
prog:
	iceprog build/top_icestick.bin
	
clean:
	rm -rf build
	