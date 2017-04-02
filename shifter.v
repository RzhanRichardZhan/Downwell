	 module seven_shifter(
												input 					 clk,
												input 					 resetn,
												input 					 enable, 
												input [6:0] 		 load_all,
												output reg [6:0] out_all		
												);
	 reg 																	 buffer;
	 
	 always @(posedge clk) begin
			if (!resetn)
				out_all <= load_all;
			else
				begin
					 if (enable) begin
							buffer <= out_all[0]; 
							out_all[0] <= out_all[1];
							out_all[1] <= out_all[2];
							out_all[2] <= out_all[3];
							out_all[3] <= out_all[4];
							out_all[4] <= out_all[5];
							out_all[5] <= out_all[6];
							out_all[6] <= ~buffer;
					 end 
				end 
	 end // always @ (posedge clk)
	 
endmodule

module five_shifter(
										input 					 clk,
										input 					 resetn,
										input 					 enable, 
										input [4:0] 		 load_all,
										output reg [4:0] out_all		
										);
	 reg 															 buffer;
	 
	 always @(posedge clk) begin
			if (!resetn)
				out_all <= load_all;
			else
				begin
					 if (enable) begin
							buffer <= out_all[0]; 
							out_all[0] <= out_all[1];
							out_all[1] <= out_all[2];
							out_all[2] <= out_all[3];
							out_all[3] <= out_all[4];
							out_all[4] <= ~buffer;
					 end
					 if (out_all > 5'd4)
						 out_all <= out_all - 4; 
				end 
	 end // always @ (posedge clk)
	 
endmodule
