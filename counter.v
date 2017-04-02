module time_counter(
										input 			 clk,
										input 			 resetn,
										input 			 enable,
										input [25:0] count,
										output reg 	 out
										);
	 /*
		clk - clock
		resetn - active low reset
		enable - enables this to start counting
		count - the maximum value this can count to
		out - signal
		*/
	 reg [25:0] 									 clock_counter;
	 
	 always @(posedge clk) begin
			out <= 1'b0; 
			if (!resetn)
				clock_counter <= 26'b0;
			else if (enable == 1'b1)
				begin
					 if (clock_counter >= count) begin
							out <= 1'b1;
							clock_counter <= 26'b0; 
					 end
					 else if (clock_counter < count)
						 clock_counter <= clock_counter + 1;
					 else
						 clock_counter <= 26'b0;
				end
	 end 
endmodule 

module coordinate_counter(
													input 					 clk,
													input 					 resetn,
													input 					 enable,
													input [7:0] 		 start,
													input [2:0] 		 step,
													input 					 step_sign, 
													output reg [7:0] out
													);
	 /*
		clk - clock
		resetn - active low reset
		enable - enables this to start counting
		start - the inital coordinate
		step - how fast we are moving
		step_sign - in what direction we are moving
		out - the new coordinate
		*/	
	 always @(posedge clk) begin
			if (!resetn)
				out <= start;
			else if (enable == 1)
				out <= step_sign ? out - step : out + step;
	 end 
endmodule

module acceleration_counter(
										input 			 clk,
										input 			 resetn,
										input 			 enable,
										input [25:0] count,
										input [25:0] terminal_velocity,
										output reg [25:0]	 out
										);
	 /*
		clk - clock
		resetn - active low reset
		enable - enables this to start counting
		count - the maximum value this can count to
		out - signal
		*/
	 reg [25:0] 									 clock_counter;
	 
	 always @(posedge clk) begin 
			if (!resetn) begin
				clock_counter <= 26'b0;
				out <= 26'd25000000;
			end
			else if (enable == 1'b1)
				begin
					 if (clock_counter == count) begin
							clock_counter <= 26'b0;
							if (out >= terminal_velocity)
								out <= out - 26'd300000;
					 end
					 else if (clock_counter < count)
						 clock_counter <= clock_counter + 1;
					 else
						 clock_counter <= 26'b0;
				end
	 end 
endmodule