module wall_control(
										input 		 clk,
										input 		 resetn,
										input 		 wall_delay, 
										output reg ld_x,
										output reg ld_y,
										output reg ld_alu_out,
										output reg alu_select,
										output reg alu_op,
										output reg writeEn,
										output reg is_color
										);
	 localparam
		 S0 = 5'd0,	
		 S1 = 5'd1,
		 S2 = 5'd2,
		 S3 = 5'd3,
		 S4 = 5'd4,
		 S5 = 5'd5;
	 

	 reg [4:0] 									 cs, ns;
	 reg [6:0] 									 draw_1, draw_2, draw_3, draw_4, draw_5;

	 always @(*)
		 begin: state_table
				if (cs == S0)
					ns = wall_delay ? S1 : S0; 
				else if (cs == S1 && draw_1 < 7'd119)
					ns = S1;
				else if (cs == S1 && draw_1 == 7'd119)
					ns = S2;
				else if (cs == S2 && draw_2 < 7'd119)
					ns = S2;
				else if (cs == S2 && draw_2 == 7'd119)
					ns = S3;
				else if (cs == S3 && draw_3 < 7'd119)
					ns = S3;
				else if (cs == S3 && draw_3 == 7'd119)
					ns = S4;
				else if (cs == S4 && draw_4 < 7'd119)
					ns = S4;
				else if (cs == S4 && draw_4 == 7'd119)
					ns = S5;
				else if (cs == S5 && draw_5 < 7'd119)
					ns = S5;
				else if (cs == S5 && draw_5 == 7'd119)
					ns = S0; 
		 end // block: state_table

	 always @(*) begin
			ld_x = 1'b0;
			ld_y = 1'b0;
			ld_alu_out = 1'b0;
			alu_select = 1'b0;
			alu_op = 1'b0;
			writeEn = 1'b0;
			is_color = 1'b0; 
			if (cs == S0) begin
				 ld_x = 1'b1;
				 ld_y = 1'b1;
			end
			else if (cs == S1) begin
				 writeEn = 1'b1;
				 is_color = draw_1[2];
				 ld_y = 1'b1;
				 ld_alu_out = 1'b1;
				 alu_select = 1'b1;
			end
			else if (cs == S2) begin
				 writeEn = 1'b1;
				 is_color = (draw_2[2] && ~(draw_2[1] && draw_2[0])) || (~draw_2[2] && draw_2[1] && draw_2[0]);
				 ld_y = 1'b1;
				 ld_alu_out = 1'b1;
				 alu_select = 1'b1;
				 if (draw_2 == 7'd0) begin
						ld_x = 1'b1;
						ld_y = 1'b1;
						ld_alu_out = 1'b0; 
				 end
			end
			else if (cs == S3) begin
				 writeEn = 1'b1;
				 is_color = (draw_3[2] && ~draw_3[1]) || (~draw_3[2] && draw_3[1]);
				 ld_y = 1'b1;
				 ld_alu_out = 1'b1;
				 alu_select = 1'b1;
				 if (draw_3 == 7'd0) begin
						ld_x = 1'b1;
						ld_y = 1'b1;
						ld_alu_out = 1'b0; 
				 end
			end
			else if (cs == S4) begin
				 writeEn = 1'b1;
				 is_color = (draw_4[2] && ~draw_4[1] && ~draw_4[0]) || (~draw_4[2] && (draw_4[1] || draw_4[0]));
				 ld_y = 1'b1;
				 ld_alu_out = 1'b1;
				 alu_select = 1'b1;
				 if (draw_4 == 7'd0) begin
						ld_x = 1'b1;
						ld_y = 1'b1;
						ld_alu_out = 1'b0; 
				 end
			end
			else if (cs == S5) begin
				 writeEn = 1'b1;
				 is_color = ~draw_5[2]; 
				 ld_y = 1'b1;
				 ld_alu_out = 1'b1;
				 alu_select = 1'b1;
				 if (draw_5 == 7'd0) begin
						ld_x = 1'b1;
						ld_y = 1'b1;
						ld_alu_out = 1'b0; 
				 end
			end
	 end // always @ begin
	 always @(posedge clk) begin
			if (!resetn)
				begin
					 cs <= S0;
					 draw_1 <= 7'd0;
					 draw_2 <= 7'd0;
					 draw_3 <= 7'd0;
					 draw_4 <= 7'd0;
					 draw_5 <= 7'd0;
				end
			else begin
				 if (cs == S1)
					 draw_1 <= draw_1 + 1;
				 else if (cs == S2)
					 draw_2 <= draw_2 + 1; 
				 else if (cs == S3)
					 draw_3 <= draw_3 + 1;	
				 else if (cs == S4)
					 draw_4 <= draw_4 + 1; 
				 else if (cs == S5)
					 draw_5 <= draw_5 + 1;
				 else if (cs == S0) begin
						draw_1 <= 7'd0;
						draw_2 <= 7'd0;
						draw_3 <= 7'd0;
						draw_4 <= 7'd0;
						draw_5 <= 7'd0;
				 end
				 cs <= ns; 
			end // else: !if(!resetn)
	 end
																				 
			
			
endmodule
