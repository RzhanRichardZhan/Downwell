module processor(
								 input 				clk,
								 input 				resetn,
								 input [2:0] 	color_in,
								 input space,
								 input left,
								 input right,
								 output [7:0] x_out,
								 output [6:0] y_out,
								 output [2:0] color_out,
								 output 			writeEn
								 );
	 /*
		clk - clock
		resetn - active low reset
		color_in - what color we want to draw
		x_out - x coordinate of what we are drawing
		y_out - y coordinate of what we are drawing
		color_out - color of what we are drawing (may be black or color_in)
		writeEn - enables writing
		*/
	 // Prevents everything from drawing when one unit is drawing
	 reg 												busy;
	 reg 												stop;
	 assign writeEn = busy;
	 // All switches controlled by the c that will enables muxes in d	 
	 wire 											player_ld_x,player_ld_y,player_ld_alu_out,player_alu_select,player_alu_op,player_is_color;
	 // The counter that redraws the player
	 wire 											player_delay;
	 // Enables coordinate counters and loads in the new player coordinates 
	 wire 											player_ld_next;
	 // Coordinate counters update and the d reads them in
	 wire [7:0] 								player_x_in;
	 wire [7:0] 								player_y_buffer; 
	 wire [6:0] 								player_y_in;
	 // Player is currently drawing
	 wire 											player_busy;
	 // Outputs of the player, to be fed into the demux
	 wire [7:0] 								player_x_out;
	 wire [6:0] 								player_y_out;
	 wire [2:0] 								player_color_out;


	 wire 											wall_ld_x,wall_ld_y,wall_ld_alu_out,wall_alu_select,wall_alu_op,wall_is_color;
	 wire 											wall_delay;
	 wire 											wall_ld_next;
	 wire [7:0] 								wall_x_in;
	 wire [7:0] 								wall_y_buffer; 
	 wire [6:0] 								wall_y_in;
	 wire 											wall_busy;
	 wire [7:0] 								wall_x_out;
	 wire [6:0] 								wall_y_out;
	 wire [2:0] 								wall_color_out;
	 wire [25:0]								wall_velocity;
	 
	 wire 											bullet_ld_x,bullet_ld_y,bullet_ld_alu_out,bullet_alu_select,bullet_alu_op,bullet_is_color;
	 // The counter that redraws the bullet
	 wire 											bullet_delay;
	 // Enables coordinate counters and loads in the new bullet coordinates 
	 wire 											bullet_ld_next;
	 // Coordinate counters update and the d reads them in
	 wire [7:0] 								bullet_x_in;
	 wire [7:0] 								bullet_y_buffer; 
	 wire [6:0] 								bullet_y_in;
	 // bullet is currently drawing
	 wire 											bullet_busy;
	 // Outputs of the bullet, to be fed into the demux
	 wire [7:0] 								bullet_x_out;
	 wire [6:0] 								bullet_y_out;
	 wire [2:0] 								bullet_color_out;
	 wire bullet_enable;
	 reg isbullet = 1'b0;
	 reg bullet_stop;

	 wire enemy_ld_x,enemy_ld_y,enemy_ld_alu_out,enemy_alu_select,enemy_alu_op,enemy_is_color;
	 // The counter that redraws the enemy
	 wire enemy_delay;
	 // Enables coordinate counters and loads in the new enemy coordinates 
	 wire enemy_ld_next;
	 // Coordinate counters update and the d reads them in
	 wire [7:0] enemy_x_in;
	 wire [7:0] enemy_y_buffer; 
	 wire [6:0] enemy_y_in;
	 reg [7:0] 	enemy_x_start; 	
	 // enemy is currently drawing
	 wire 			enemy_busy;
	 // Outputs of the enemy, to be fed into the demux
	 wire [7:0] enemy_x_out;
	 wire [6:0] enemy_y_out;
	 wire [2:0] enemy_color_out;
	 wire 			enemy_alive;
	 wire [6:0] enemy_x_part_one;
	 wire [4:0] enemy_x_part_two;
			

	 reg 				player_direction;
	 reg 				player_step;
	 
	 // Busy is defined as anything wanting to draw
	 always @(*) begin
			busy = player_busy || wall_busy || bullet_busy;
			stop = resetn && space;
			bullet_stop = (resetn && space) || (bullet_enable && isbullet);
			enemy_x_start = enemy_x_part_one + enemy_x_part_two; 
			if (!space) isbullet <= 1'b1;
			if ((~left && player_x_out >= 8'd2) || (~right && player_x_out <= 8'd158))
				player_step = 3'b1;
			else
				player_step = 3'b0;
			if (~left)
				player_direction = 1'b0;
			else if (~right)
				player_direction = 1'b1;
	 
	 end

	 vga_demux vga_d(
									 .clk(clk),
									 .resetn(resetn),
									 .busy(busy),
									 .player_x_out(player_x_out),
									 .player_y_out(player_y_out),
									 .player_color_out(player_color_out),
									 .player_busy(player_busy),
									 .wall_x_out(wall_x_out),
									 .wall_y_out(wall_y_out),
									 .wall_color_out(wall_color_out),
									 .wall_busy(wall_busy),
									 .bullet_x_out(bullet_x_out),
									 .bullet_y_out(bullet_y_out),
									 .bullet_color_out(bullet_color_out),
									 .bullet_busy(bullet_busy),
									 .enemy_x_out(enemy_x_out),
									 .enemy_y_out(enemy_y_out),
									 .enemy_color_out(enemy_color_out),
									 .enemy_busy(enemy_busy),
									 .x_out(x_out),
									 .y_out(y_out),
									 .color_out(color_out)
									 );
	 // For the player
	 time_counter delay_counter(
															.clk(clk),
															.resetn(resetn),
															.enable(~busy),
															.count(26'd10000000),
															.out(player_delay)
															);
	 coordinate_counter x_counter(
																.clk(clk),
																.resetn(resetn),
																.enable(player_ld_next),
																.start(8'b11),
																.step(player_step),
																.step_sign(player_direction),
																.out(player_x_in)
																);
	 coordinate_counter y_counter(
																.clk(clk),
																.resetn(resetn),
																.enable(player_ld_next),
																.start(8'b11),
																.step(3'b0),
																.step_sign(1'b0),
																.out(player_y_buffer)
																);
	 time_counter bullet_counter(
															 .clk(clk),
															 .resetn(resetn),
															 .enable(~busy),
															 .count(26'd400000),
															 .out(bullet_delay)
															 );
	 coordinate_counter bullet_x_counter(
																			 .clk(clk),
																			 .resetn(bullet_stop),
																			 .enable(bullet_ld_next),
																			 .start(player_x_out),
																			 .step(3'b0),
																			 .step_sign(1'b0),
																			 .out(bullet_x_in)
																			 );
	 coordinate_counter bullet_y_counter(
																			 .clk(clk),
																			 .resetn(bullet_stop),
																			 .enable(bullet_ld_next),
																			 .start(player_y_out + 7'd4),
																			 .step(3'b1),
																			 .step_sign(1'b0),
																			 .out(bullet_y_buffer)
																			 );

	 seven_shifter randomizer_one(
																.clk(clk),
																.resetn(resetn),
																.enable(1'b1),
																.load_all(7'b1001101),
																.out_all(enemy_x_part_one)
																);
	 five_shifter randomizer_two(
															 .clk(clk),
															 .resetn(resetn),
															 .enable(1'b1),
															 .load_all(5'b11100),
															 .out_all(enemy_x_part_two)
															 );
	 
	 
	 time_counter enemy_counter(
															.clk(clk),
															.resetn(resetn),
															.enable(~busy),
															.count(wall_velocity),
															.out(enemy_delay)
															);
	 
	 coordinate_counter enemy_x_counter(
																			.clk(clk),
																			.resetn(enemy_alive),
																			.enable(enemy_ld_next),
																			.start(enemy_x_start),
																			.step(3'b0),
																			.step_sign(1'b0),
																			.out(enemy_x_in)
																			);
	 coordinate_counter enemy_y_counter(
																			.clk(clk),
																			.resetn(enemy_alive),
																			.enable(enemy_ld_next),
																			.start(7'd110),
																			.step(3'b1),
																			.step_sign(1'b1),
																			.out(enemy_y_buffer)
																			);
	 enemy_control enemy_c(
												 .clk(clk),
												 .resetn(resetn),
												 .player_delay(enemy_delay),
												 .busy(busy),
												 .alive(enemy_alive),
												 .ld_x(enemy_ld_x),
												 .ld_y(enemy_ld_y),
												 .ld_alu_out(enemy_ld_alu_out),
												 .alu_select(enemy_alu_select),
												 .alu_op(enemy_alu_op),
												 .writeEn(enemy_busy),
												 .is_color(enemy_is_color),
												 .ld_next(enemy_ld_next)
												 );
	 enemy_datapath enemy_d(
													.clk(clk),
													.resetn(resetn),
													.x_in(enemy_x_in),
													.y_in(enemy_y_in),
													.ld_x(enemy_ld_x),
													.ld_y(enemy_ld_y),
													.ld_alu_out(enemy_ld_alu_out),
													.alu_select(enemy_alu_select),
													.alu_op(enemy_alu_op),
													.color_in(3'b100),
													.is_color(enemy_is_color),
													.bullet_x(bullet_x_out),
													.bullet_y(bullet_y_out),
													.x_out(enemy_x_out),
													.y_out(enemy_y_out),
													.color_out(enemy_color_out),
													.alive(enemy_alive)
													);
	 
	 
	 
	
	 // For the wall
	 acceleration_counter a_count(
																.clk(clk),
																.resetn(stop),
																.enable(~busy),
																.count(26'd850000),
																.terminal_velocity(26'd1000000),
																.out(wall_velocity)
																);
	 time_counter wall_counter(
														 .clk(clk),
														 .resetn(resetn),
														 .enable(~busy),
														 .count(wall_velocity),
														 .out(wall_delay)
														 );
	 wall_control wall_c(
											 .clk(clk),
											 .resetn(resetn),
											 .wall_delay(wall_delay),
											 .ld_x(wall_ld_x),
											 .ld_y(wall_ld_y),
											 .ld_alu_out(wall_ld_alu_out),
											 .alu_select(wall_alu_select),
											 .alu_op(wall_alu_op),
											 .writeEn(wall_busy),
											 .is_color(wall_is_color) 
											 );
	 
	 datapath wall_d(
									 .clk(clk),
									 .resetn(resetn),
									 .x_in(8'b1),
									 .y_in(7'b1),
									 .ld_x(wall_ld_x),
									 .ld_y(wall_ld_y),
									 .ld_alu_out(wall_ld_alu_out),
									 .alu_select(wall_alu_select),
									 .alu_op(wall_alu_op),
									 .color_in(3'b111),
									 .is_color(wall_is_color),
									 .x_out(wall_x_out),
									 .y_out(wall_y_out),
									 .color_out(wall_color_out)
									 )	;
	 
	 
	 
	 assign player_y_in = player_y_buffer[6:0]; 
	 assign bullet_y_in = bullet_y_buffer[6:0];
	 assign enemy_y_in = enemy_y_buffer[6:0];
	 

	 control player_c(
										.clk(clk),
										.resetn(resetn),
										.player_delay(player_delay),
										.busy(busy),
										.ld_x(player_ld_x),
										.ld_y(player_ld_y),
										.ld_alu_out(player_ld_alu_out),
										.alu_select(player_alu_select),
										.alu_op(player_alu_op),
										.writeEn(player_busy),
										.is_color(player_is_color),
										.ld_next(player_ld_next)
										);
	 datapath player_d(
										 .clk(clk),
										 .resetn(resetn),
										 .x_in(player_x_in),
										 .y_in(player_y_in),
										 .ld_x(player_ld_x),
										 .ld_y(player_ld_y),
										 .ld_alu_out(player_ld_alu_out),
										 .alu_select(player_alu_select),
										 .alu_op(player_alu_op),
										 .color_in(color_in),
										 .is_color(player_is_color),
										 .x_out(player_x_out),
										 .y_out(player_y_out),
										 .color_out(player_color_out)
										 );
		
	 bullet_control bullet_c(
													 .clk(clk),
													 .resetn(resetn),
													 .player_delay(bullet_delay),
													 .busy(busy),
													 .enable(bullet_enable),
													 .space(space),
													 .isbullet(isbullet),
													 .ld_x(bullet_ld_x),
													 .ld_y(bullet_ld_y),
													 .ld_alu_out(bullet_ld_alu_out),
													 .alu_select(bullet_alu_select),
													 .alu_op(bullet_alu_op),
													 .writeEn(bullet_busy),
													 .is_color(bullet_is_color),
													 .ld_next(bullet_ld_next)
													 );
	 bullet_datapath bullet_d(
														.clk(clk),
														.resetn(resetn),
														.x_in(bullet_x_in),
														.y_in(bullet_y_in),
														.ld_x(bullet_ld_x),
														.ld_y(bullet_ld_y),
														.ld_alu_out(bullet_ld_alu_out),
														.alu_select(bullet_alu_select),
														.alu_op(bullet_alu_op),
														.color_in(3'b001),
														.is_color(bullet_is_color),
														.x_out(bullet_x_out),
														.y_out(bullet_y_out),
														.color_out(bullet_color_out),
														.bullet_enable(bullet_enable)
														);
	 
	 
endmodule // processor


module control(
							 input 			clk,
							 input 			resetn,
							 input 			player_delay,
							 input 			busy,
							 output reg ld_x,
							 output reg ld_y,
							 output reg ld_alu_out,
							 output reg alu_select,
							 output reg alu_op,
							 output reg ld_next,
							 output reg writeEn,
							 output reg is_color
							 );
	 /*
		clk - clock
		resetn - active low reset
		player_delay - the delay to redraw the player
		ld_x, ld_y - tells datapath to load
		ld_alu_out - tells x and y to load from the alu
		alu_select - chooses x or y for the alu
		alu_op - chooses which operation to apply to x/y
		ld_next - enables the coordinate counters
		writeEn - enables write
		is_color - tells the datapath that we are drawing and not erasing
		*/
	 localparam
		 S_WAIT = 5'd0, // Wait for the delay
		 S_ERASE = 5'd1, // Erase said coordinates
		 S_LOAD = 5'd2, // Load in the new coordinates
		 S_DRAW = 5'd3, // Draw the new coordinates
		 S_FINAL = 5'd31;
 
	 
	 
	 reg [4:0] 							pcs, pns; // player_current_state, player_next_state,
	 reg [3:0] 							player_drawer, player_eraser = 4'b0;
	 
	 always @(*)
						 begin: state_table
								if (pcs == S_WAIT)
									pns = player_delay ? S_ERASE : S_WAIT;
								else if (pcs == S_ERASE && player_eraser < 4'd12)
									pns = S_ERASE;
								else if (pcs == S_ERASE && player_eraser == 4'd12)
									pns = S_LOAD;
								else if (pcs == S_LOAD)
									pns = S_DRAW;
								else if (pcs == S_DRAW && player_drawer < 4'd12)
									pns = S_DRAW;
								else if (pcs == S_DRAW && player_drawer == 4'd12)
									pns = S_WAIT; 
								else 
									pns = S_WAIT;
						 end // block: state_table
	 
	 always @(*) begin
			ld_x = 1'b0;
			ld_y = 1'b0;
			ld_alu_out = 1'b0;
			alu_select = 1'b0;
			alu_op = 1'b0;
			ld_next = 1'b0; 
			writeEn = 1'b0;
			is_color = 1'b0; 
			if (pcs == S_WAIT) begin
				 ld_x = 1'b1;
				 ld_y = 1'b1;
			end
			else if (pcs == S_ERASE) begin 
				 writeEn = 1'b1;
				 if (player_eraser != 4'b0000 && player_eraser < 4'd12)begin
						// Don't do anything on the first or last step
						ld_alu_out = 1'b1;
						// We are always loading a value
						if (player_eraser[1:0] == 2'b00)begin
							 // Shift right 1 bit every 4 erases
							 ld_x = 1'b1;
						end
						else if (player_eraser[2] == 1'b0)begin
							 // Shift down 1 bit every odd right shift
							 ld_y = 1'b1;
							 alu_select = 1'b1; 
						end
						else if (player_eraser[3:2] == 2'b01)begin
							 // Shift up 1 bit every even right shift
							 ld_y = 1'b1;
							 alu_select = 1'b1;
							 alu_op = 1'b1; 
						end
				 end
			end // if (pcs == S_ERASE)
			else if (pcs == S_LOAD) begin
				 writeEn = 1'b1; 
				 ld_next = 1'b1;
			end
			else if (pcs == S_DRAW) begin
				 writeEn = 1'b1;
				 is_color = 1'b1;
				 if (player_drawer == 4'b0)begin
						ld_x = 1'b1;
						ld_y = 1'b1;
				 end 
				 else if (player_drawer != 4'd12)begin
						// Don't do anything on the first or last step
						ld_alu_out = 1'b1;
						// We are always loading a value
						if (player_drawer[1:0] == 2'b00)begin
							 // Shift right 1 bit every 4 draw
							 ld_x = 1'b1;
						end
						else if (player_drawer[3:2] == 2'b00 || player_drawer[3:2] == 2'b10)begin
							 // Shift down 1 bit every odd right shift
							 ld_y = 1'b1;
							 alu_select = 1'b1; 
						end
						else if (player_drawer[3:2] == 2'b01)begin
							 // Shift up 1 bit every even right shift
							 ld_y = 1'b1;
							 alu_select = 1'b1;
							 alu_op = 1'b1; 
						end
				 end
			end // if (pcs == S_DRAW)
	 end // always @ begin
	 
	 
	 always @(posedge clk) begin
			if (!resetn)
				begin
					 pcs <= S_WAIT;
					 player_drawer <= 4'd0;
					 player_eraser <= 4'd0; 
				end
			else begin 
				 if (pcs == S_ERASE)
					 player_eraser <= player_eraser + 1;
				 else if (pcs == S_DRAW)
					 player_drawer <= player_drawer + 1;
				 else if (pcs == S_WAIT) begin
						player_eraser <= 4'd0;
						player_drawer <= 4'd0; 
				 end
				 pcs <= pns;
			end // else: !if(!resetn)
	 end
endmodule // control

module datapath(
								input 					 clk,
								input 					 resetn,
								input [7:0] 		 x_in,
								input [6:0] 		 y_in,
								input 					 ld_x, ld_y,
								input ld_alu_out, 
								input alu_select,
								input alu_op,
								input [2:0] color_in,
								input is_color,
								output reg [7:0] x_out,
								output reg [6:0] y_out,
								output [2:0] color_out
								);
	 /*
		clk - clock
		resetn - active low reset
		x_in - original x coordinate
		y_in - original y coordinate
		ld_x, ld_y - loads in the values for x and y
		ld_alu_out - loads from the alu
		alu_select - selects x/y for the alu
		alu_op - selects which operation for the alu
		color_in - the color input
		is_color - determines if we are drawing and not erasing
		x_out - new x coordinate
		y_out - new y coordinate
		color_out - the color after being filtered
		*/
	 reg [7:0] 										 alu_in;
	 reg [7:0] 										 alu_out;

	 assign color_out = is_color ? color_in : 3'b000;
	 always @(posedge clk) begin
			if (!resetn) begin
				 x_out <= x_in;
				 y_out <= y_in; 
			end
			else begin
				 if (ld_x)
					 x_out <= ld_alu_out ? alu_out : x_in;
				 if (ld_y)
					 y_out <= ld_alu_out ? alu_out : y_in; 
			end
	 end // always @ (posedge clk)
	 always @(*) begin
			if (alu_select == 1'b0)
				alu_in = x_out;
			else
				alu_in = {1'b0,y_out}; 
	 end // always @ begin

	 always @(*) begin: ALU
			case(alu_op)
				1'b0: alu_out = alu_in + 1;
				1'b1: alu_out = alu_in - 1; 
				default: alu_out = 8'd0;
			endcase // case (alu_op) 
	 end
	 
endmodule
