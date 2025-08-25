`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:36:24 12/07/2024 
// Design Name: 
// Module Name:    WRITE_MACHINE_TOP_LEVEL 
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
		module WRITE_MACHINE_TOP_LEVEL  (
			 input clk,
			 input reset,
			 input ACK_N,
			 input step_en,
			 output AS_N,
			 output WR_N,
			 output in_init,
			 output [1:0] current_write_state_out,
			 output stop_n_monitor,
			 output [31:0] WDO,
			 output [31:0] AO
		);

		wire counter_ce;
		wire [7:0] id_num;
		wire stop_n;
		wire DIN;
		wire Q_OUT;
		

		WRITE_MACHINE WRITE_MACHINE_1 (
			 .clk(clk),
			 .reset(reset),
			 .step_en(step_en),
			 .ACK_N(ACK_N),
			 .stop_n(stop_n),
			 .AS_N(AS_N),
			 .WR_N(WR_N),
			 .in_init(in_init),
			 .counter_ce(counter_ce),
			 .current_write_state_out(current_write_state_out)
		);

		CNT32 Counter32 (
			 .CLK(clk),
			 .RST(reset),
			 .CE(counter_ce),
			 .CNT(AO)
		);

		ID_num ID_num_1 (
			 .ID_number(id_num)
		);

		assign WDO = {24'b0, id_num};
		assign DIN = (current_write_state_out == 2'h2 );
		assign stop_n_monitor = ~(Q_OUT && DIN && ACK_N); 

		MY_DFF MY_DFF_1 (
			 .clk(clk),
			 .reset(reset),
			 .D(DIN),
			 .Q(Q_OUT)
		);
		endmodule

