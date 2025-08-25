`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    01:35:05 12/04/2024 
// Design Name: 
// Module Name:    monitor_new 
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
module monitor_new(

	 // Slave //

    // input [31:0] mux_in_0 --- LA_RAM [31:0]    // inputs for slave mux
    // input [31:0] mux_in_1 --- ID[15:8] * STATUS [7:0]
    input [31:0] mux_in_2, // MASTER_RAM_OUT [31:0]
    input [31:0] mux_in_3,  // step_counter_master 
    input clk,
    input CARDSEL,
    input WR_N,
    input [9:0]  AI,
	 
	 // Logic Analyzer // 
	 
    input step_en,
    input in_init,
	 input stop_n,
	 input [31:0] Monitored_Signals,
	 input reset,
	 // input [4:0] AI,
	 
	 output SACK_N,
	 output [4:0] reg_address,
	 output [31:0] SDO
	 	
    );
	 

	 wire [31:0] mux_in_1;
	 
	 wire [31:0] LA_RAM; 
	 wire [7:0] sts;
	 wire [7:0] ID_NUM;
	 
	 Logic_Analyzer_Top_Level logic_analyzer_1(.clk(clk),.step_en(step_en),.Monitored_Signals(Monitored_Signals),
	 .in_init(in_init),.stop_n(stop_n),.reset(reset),.AI(AI[4:0]),.DOUT(LA_RAM),.STATUS(sts));
	 

	 ID_num ID_1 (.ID_number(ID_NUM));
	 
	 assign mux_in_1[7:0] = sts;
	 assign mux_in_1[15:8] = ID_NUM;
	 assign mux_in_1[31:16] = 16'b0;
	 
	 slave_top slave_1 (.clk(clk),.CARDSEL(CARDSEL),.WR_N(WR_N),.reset(reset),.AI(AI)
	 ,.slave_in_mux_0(LA_RAM),.slave_in_mux_1(mux_in_1),.slave_in_mux_2(mux_in_2),
	 .slave_in_mux_3(mux_in_3),.slave_out_mux_out(SDO),
	 .reg_address(reg_address[4:0]),.SACK_N(SACK_N));
	  
	 
	 
	 
endmodule
