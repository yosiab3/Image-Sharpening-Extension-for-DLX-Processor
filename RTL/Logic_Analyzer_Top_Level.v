`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:47:34 11/24/2024 
// Design Name: 
// Module Name:    Logic_Analyzer_Top_Level 
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
module Logic_Analyzer_Top_Level(

	 input clk,
    input step_en,
	 input [31:0] Monitored_Signals,
    input in_init,
	 input stop_n,
	 
	 input reset,
	 input [4:0] AI,
	 output [31:0] DOUT,
	 output [7:0] STATUS
	 
    );

	 wire 		la_run;
	 wire 		la_we;
	 wire 		sts_ce;
	 wire [4:0]	cnt_s;
	 
	 
	 logic_analyzer_a_datapath datapath_1(.clk(clk),.reset(reset),.DATA_IN_RAM(Monitored_Signals),.la_we(la_we),.sts_ce(sts_ce),.AI(AI),.DATA_OUT_RAM(DOUT),.sts(STATUS), .cnt_s (cnt_s));
	 Logic_Analyzer_Control control_1 (.clk(clk),.reset(reset),.step_en(step_en),.in_init(in_init),.stop_n(stop_n),.la_run(la_run),.la_we(la_we),.sts_ce(sts_ce));
	 

endmodule
