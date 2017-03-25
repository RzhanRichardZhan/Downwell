module vga_demux(
								 input 						clk,
								 input 						resetn,
								 input 						busy, 
								 input [7:0] 			player_x_out,
								 input [6:0] 			player_y_out,
								 input [2:0] 			player_color_out,
								 output reg [7:0] x_out,
								 output reg [6:0] y_out,
														 output reg [2:0] color_out
								 );
	 /*
		Takes in all of the objects' coordinates, and determines
		which one to output to the VGA display
		
		busy - whether the VGA is busy
		*/

	 wire 																			go;
	 
	 time_counter vga_counter(
														.clk(clk),
														.resetn(resetn),
														.enable(~busy),
														.count(26'd1), //26'd834000
														.out(go)
														);

	 localparam
		 S_PLAYER = 5'd0,
		 S_WALL = 5'd1;

	 reg [4:0] 																	cs, ns;

	 always @(*) begin : state
			if (cs == S_PLAYER) begin
				 ns = go ? S_WALL : S_PLAYER;
				 x_out = player_x_out;
				 y_out = player_y_out;
				 color_out = player_color_out;
			end
			else if (cs == S_WALL)
				ns = go ? S_PLAYER : S_WALL;
	 end

	 always @(posedge clk) begin
			if (!resetn)
				begin
					 cs <= S_PLAYER; 
				end
			else
				begin
					 cs <= ns;
				end 
	 end
endmodule
