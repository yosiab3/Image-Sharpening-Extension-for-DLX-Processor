`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:21:17 11/24/2024 
// Design Name: 
// Module Name:    logic_analyzer_a_datapath 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module logic_analyzer_a_datapath(

    input clk,
	 input reset,
	 input [31:0] DATA_IN_RAM,
	 input la_we,
	 input sts_ce,
	 input [4:0] AI,
	 output [31:0] DATA_OUT_RAM,
	 output  [7:0] sts,
	 output [4:0] cnt_s
	 );
	 
	 wire [4:0] mux_output;
	 reg [7:0] sts_reg;
	 
	 
	 
	 always@(posedge clk) begin
			if (reset)
			    sts_reg <= 8'b0;
			else if (sts_ce) 
				sts_reg <= {3'b0,cnt_s};
				else sts_reg <=sts_reg;
			end
				
	 assign sts = sts_reg;
    
	 
	 CNT5 counter (.CLK(clk),.RST(sts_ce),.CE(la_we),.CNT(cnt_s));
	 MUX5bit mux (.A(AI),.B(cnt_s),.sel(la_we),.O(mux_output));
	 RAM32x32 RAM (.CLK(clk),.WE(la_we),.ADDR(mux_output),.DI(DATA_IN_RAM),.DO(DATA_OUT_RAM));
	 
	 
endmodule
