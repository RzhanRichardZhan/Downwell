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
								 input [7:0] 			bullet_x_out,
								 input [6:0] 			bullet_y_out,
								 input [2:0] 			bullet_color_out,
								 input 						bullet_busy,
								 input [7:0] 			enemy_x_out,
								 input [6:0] 			enemy_y_out,
								 input [2:0] 			enemy_color_out,
								 input 						enemy_busy,
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
			else if (bullet_busy) begin
				 x_out = bullet_x_out;
				 y_out = bullet_y_out;
				 color_out = bullet_color_out;
			end
			else if (enemy_busy) begin
				 x_out = enemy_x_out;
				 y_out = enemy_y_out;
				 color_out = enemy_color_out;
			end
	 end

endmodule
