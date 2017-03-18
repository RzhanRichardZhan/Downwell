module processor(
								 input 				clk,
								 input 				resetn,
								 input [2:0] 	color_in,
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

	 wire 											ld_x,ld_y,ld_alu_out,alu_select,alu_op,is_color;
	 // All switches controlled by the c that will enables muxes in d
	 wire 											player_delay;
	 // The counter that redraws the player
	 wire 											ld_next;
	 // Enables coordinate counters and loads in the new player coordinates 
	 wire [7:0] 								x_in;
	 wire [6:0] 								y_in;
	 // Coordinate counters update and the d reads them in
	 
	 
	 // Change count eventually
	 time_counter delay_counter(
															.clk(clk),
															.resetn(resetn),
															.enable(~writeEn),
															.count(26'd10),
															.out(player_delay)
															);
	 x_counter coordinate_counter(
																.clk(clk),
																.resetn(resetn),
																.enable(ld_next),
																.start(2'b11),
																.step(1'b0),
																.out(x_in)
																);
	 y_counter coordinate_counter(
																.clk(clk),
																.resetn(resetn),
																.enable(ld_next),
																.start(2'b11),
																.step(1'b0),
																.out(y_in)
																);
	 
	 

	 control c(
						 .clk(clk),
						 .resetn(resetn),
						 .player_delay(player_delay),
						 .ld_x(ld_x),
						 .ld_y(ld_y),
						 .ld_alu_out(ld_alu_out),
						 .alu_select(alu_select),
						 .alu_op(alu_op),
						 .writeEn(writeEn),
						 .is_color(is_color) 
						 );
	 datapath d(
							.clk(clk),
							.resetn(resetn),
							.x_in(x_in),
							.y_in(y_in),
							.ld_x(ld_x),
							.ld_y(ld_y),
							.ld_alu_out(ld_alu_out),
							.alu_select(alu_select),
							.alu_op(alu_op),
							.color_in(color_in),
							.is_color(is_color),
							.x_out(x_out),
							.y_out(y_out),
							.color_out(color_out)
							);
	 
	 
endmodule // processor


module control(
							 input 			clk,
							 input 			resetn,
							 input 			player_delay, 
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
	 wire 									player_delay;

	 always @(*)
		 begin: state_table	
				if (pcs == S_WAIT)
					pns = player_delay ? S_ERASE : S_WAIT;
				else if (pcs == S_ERASE && player_eraser < 4'd12)
					pns = pcs;
				else if (pcs == S_ERASE && player_eraser == 4'd12)
					pns = S_LOAD;
				else if (pcs == S_LOAD)
					pns = S_DRAW;
				else if (pcs == S_DRAW && player_drawer < 4'd12)
					pns = pcs;
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
				 player_drawer = 4'b0;
				 player_eraser = 4'b0; 
			end
			else if (pcs == S_ERASE) begin 
				 writeEn = 1'b1;
				 if (player_eraser != 4'b0000 && player_eraser != 4'd12)begin
						// Don't do anything on the first or last step
						ld_alu_out = 1'b1;
						// We are always loading a value
						if (player_eraser[1:0] == 2'b00)begin
							 // Shift right 1 bit every 4 erases
							 ld_x = 1'b1;
						end
						else if (player_eraser[3:2] == 2'b00 || player_eraser[3:2] == 2'b10)begin
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
				 player_eraser = player_eraser + 1; 
			end // if (pcs == S_ERASE)
			else if (pcs == S_LOAD) begin
				 ld_next = 1'b1;
				 ld_x = 1'b1;
				 ld_y = 1'b1; 
			end
			else if (pcs == S_DRAW) begin
				 writeEn = 1'b1;
				 is_color = 1'b1; 
				 if (player_drawer != 4'b0000 && player_drawer != 4'd12)begin
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
				 player_drawer = player_drawer + 1;
			end // if (pcs == S_DRAW)
	 end // always @ begin
	 
	 
	 always @(posedge clk) begin
			if (!resetn)
				begin
					 pcs <= S_WAIT;
					 player_drawer = 4'd0;
					 player_eraser = 4'd0; 
				end
			else
				pcs <= pns;
	 end	 
endmodule // control

module datapath(
								input 					 clk,
								input 					 resetn,
								input [7:0] 		 x_in,
								input [6:0] 		 y_in,
								input 					 ld_x, ld_y,
								input 					 ld_alu_out, 
								input 					 alu_select,
								input 					 alu_op,
								input [2:0] 		 color_in,
								input 					 is_color,
								output reg [7:0] x_out,
								output reg [6:0] y_out,
								output [2:0] 		 color_out
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

	 assign color_out = is_color ? color_in, 3'b000;
	 always @(posedge clk) begin
			if (!resetn) begin
				 x <= x_in;
				 y <= y_in; 
			end
			else begin
				 if (ld_x)
					 x <= ld_alu_out ? alu_out : x_in;
				 if (ld_y)
					 y <= ld_alu_out ? alu_out : y_in; 
			end
	 end // always @ (posedge clk)
	 always @(*) begin
			if (alu_select = 1'b0)
				alu_in = x;
			else
				alu_in = {1'b0,y}; 
	 end // always @ begin

	 always @(*) begin: ALU
			case(alu_op)
				1'b0: alu_out = alu_in + 1;
				1'b1: alu_out = alu_in - 1; 
				default: alu_out = 8'd0;
			endcase // case (alu_op) 
	 end
	 
endmodule