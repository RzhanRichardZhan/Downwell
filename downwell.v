module downwell(
								input 			 CLOCK_50,
								input [0:0]  KEY,

								output 			 VGA_CLK, //	VGA Clock
								output 			 VGA_HS, //	VGA H_SYNC
								output 			 VGA_VS, //	VGA V_SYNC
								output 			 VGA_BLANK_N, //	VGA BLANK
								output 			 VGA_SYNC_N, //	VGA SYNC
								output [9:0] VGA_R, //	VGA Red[9:0]
								output [9:0] VGA_G, //	VGA Green[9:0]
								output [9:0] VGA_B   						//	VGA Blue[9:0]
								);
	 wire [7:0] 							 x;
	 wire [6:0] 							 y;
	 wire [2:0] 							 color;
	 wire 										 writeEn;
	 processor p(
							 .clk(CLOCK_50),
							 .resetn(KEY[0]),
							 .color_in(3'b101),
							 .x_out(x),
							 .y_out(y),
							 .color_out(color),
							 .writeEn(writeEn)
							 );

	 vga_adapter VGA(
									 .resetn(KEY[0]),
									 .clock(CLOCK_50),
									 .colour(color),
									 .x(x),
									 .y(y),
									 .plot(writeEn),
									 /* Signals for the DAC to drive the monitor. */
									 .VGA_R(VGA_R),
									 .VGA_G(VGA_G),
									 .VGA_B(VGA_B),
									 .VGA_HS(VGA_HS),
									 .VGA_VS(VGA_VS),
									 .VGA_BLANK(VGA_BLANK_N),
									 .VGA_SYNC(VGA_SYNC_N),
									 .VGA_CLK(VGA_CLK));
	 defparam VGA.RESOLUTION = "160x120";
	 defparam VGA.MONOCHROME = "FALSE";
	 defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
	 defparam VGA.BACKGROUND_IMAGE = "black.mif";
	 
endmodule
