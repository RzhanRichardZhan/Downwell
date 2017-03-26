module vga_demux(
								 input 						clk,
								 input 						resetn,
								 input 						busy, 
								 input [7:0] 			player_x_out,
								 input [6:0] 			player_y_out,
								 input [2:0] 			player_color_out,
								 input 						player_busy, 
								 input [7:0] 			wall_x_out,
								 input [6:0] 			wall_y_out,
								 input [2:0] 			wall_color_out,
								 input 						wall_busy,
								 output reg [7:0] x_out,
								 output reg [6:0] y_out,
								 output reg [2:0] color_out
								 );
	 /*
		Takes in all of the objects' coordinates, and determines
		which one to output to the VGA display
		
		busy - whether the VGA is busy
		*/

	 wire 													go;
	 
	 time_counter vga_counter(
														.clk(clk),
														.resetn(resetn),
														.enable(~busy),
														.count(26'd100), //26'd834000
														.out(go)
														);


	 always @(*) begin : state
			if (player_busy) begin
				 x_out = player_x_out;
				 y_out = player_y_out;
				 color_out = player_color_out;
			end
			else if (wall_busy) begin
				 x_out = wall_x_out;
				 y_out = wall_y_out;
				 color_out = wall_color_out; 
			end
	 end

endmodule
