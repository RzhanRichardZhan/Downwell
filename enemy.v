module enemy_control(
										 input 			clk,
										 input 			resetn,
										 input 			player_delay,
										 input 			busy,
										 input 			alive ,
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
		 S_DEAD = 5'd4,
		 S_DEAD_WAIT = 5'd5, 
		 S_FINAL = 5'd31;
	 
	 
	 
	 reg [4:0] 										pcs, pns; // player_current_state, player_next_state,
	 reg [3:0] 										player_drawer, player_eraser, enemy_remover = 4'b0;
	 
	 always @(*)
		 begin: state_table
				if (alive) begin
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
				end // if (alive)
				else begin
					 if (pcs != S_DEAD_WAIT && enemy_remove < 4'd12)
						 pns = S_DEAD;
					 else
						 pns = S_DEAD_WAIT; 
				end
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
			else if (pcs == S_DEAD) begin
				 writeEn = 1'b1;
				 if (enemy_remover != 4'b0000 && enemy_remover != 4'd12)begin
						// Don't do anything on the first or last step
						ld_alu_out = 1'b1;
						// We are always loading a value
						if (enemy_remover[1:0] == 2'b00)begin
							 // Shift right 1 bit every 4 erases
							 ld_x = 1'b1;
						end
						else if (enemy_remover[3:2] == 2'b00 || enemy_remover[3:2] == 2'b10)begin
							 // Shift down 1 bit every odd right shift
							 ld_y = 1'b1;
							 alu_select = 1'b1; 
						end
						else if (enemy_remover[3:2] == 2'b01)begin
							 // Shift up 1 bit every even right shift
							 ld_y = 1'b1;
							 alu_select = 1'b1;
							 alu_op = 1'b1; 
						end
				 end
			end
	 end // always @ begin
	 
	 
	 always @(posedge clk) begin
			if (!resetn)
				begin
					 pcs <= S_WAIT;
					 player_drawer <= 4'd0;
					 player_eraser <= 4'd0;
					 enemy_remover <= 4'd0;
				end
			else begin 
				 if (pcs == S_ERASE)
					 player_eraser <= player_eraser + 1;
				 else if (pcs == S_DRAW)
					 player_drawer <= player_drawer + 1;
				 else if (pcs == S_DEAD)
					 enemy_remover <= enemy_remover + 1;	
				 else if (pcs == S_WAIT) begin
						player_eraser <= 4'd0;
						player_drawer <= 4'd0;
						enemy_remover <= 4'd0;
 
				 end
				 pcs <= pns;
			end // else: !if(!resetn)
	 end
endmodule // control



module enemy_datapath(
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
											input 					 bullet_x,
											input 					 bullet_y, 
											output reg [7:0] x_out,
											output reg [6:0] y_out,
											output [2:0] 		 color_out,
											output reg 			 alive 
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
	 reg [7:0] 													 alu_in;
	 reg [7:0] 													 alu_out;

	 assign color_out = is_color ? color_in : 3'b000;
	 always @(posedge clk) begin
			if (!resetn) begin
				 x_out <= x_in;
				 y_out <= y_in;
				 alive <= 1'b1; 
			end
			else begin
				 if (ld_x)
					 x_out <= ld_alu_out ? alu_out : x_in;
				 if (ld_y)
					 y_out <= ld_alu_out ? alu_out : y_in;
				 if (((x_out >= bullet_x && x_out <= bullet_x + 3) && (y_out >= bullet_y && y_out <= bullet_y + 4)) ||
						 (y_out < 1'b1))
					 alive <= 1'b0; 
			end
	 end // always @ (posedge clk)
	 always @(*) begin
			if (alu_select == 1'b0)
				alu_in = x_out;
			else
				alu_in = {1'b0,y_out}; 
	 end // always @ begin

	 always @(*) begin: ALU
			bullet_enable = y_out < 7'd118;
			case(alu_op)
				1'b0: alu_out = alu_in + 1;
				1'b1: alu_out = alu_in - 1; 
				default: alu_out = 8'd0;
			endcase // case (alu_op) 
	 end
	 
endmodule
