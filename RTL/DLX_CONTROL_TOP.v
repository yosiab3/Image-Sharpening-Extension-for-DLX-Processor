`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:29:16 01/05/2025 
// Design Name: 
// Module Name:    DLX_CONTROL_TOP 
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
module DLX_CONTROL_TOP(
    input clk,
    input reset,
    input AEQZ,
    input step_en,
    input [31:0] IR,
    input ACK_N,

	 output in_init,
	 output add,
	 output A_en,
	 output B_en,
	 output C_en,
	 output A_sel,
	 output AS_N,
	 output WR_N,
	 output busy,
	 output DINT_sel,
	 output GPR_WE,
	 output IR_en,
	 output MAR_en,
	 output MDR_en,
	 output MDR_sel,
	 output PC_en,
	 output Itype,
	 output jlink,
	 output mr,
	 output mw,
	 output right,
	 output [1:0] S1_sel,
	 output [1:0] S2_sel,
 	 output shift,
	 output stop_n,
	 output test,
	 output [4:0] DLX_STATE_OUT,
	 output [1:0] MAC_STATE_OUT, 
 
 	 output E_en,
	 output SHARPEN_sel
	 
    );
	
	wire stop_wire;
	reg stop_reg;
	wire IR_en_wire ;
	
	MAC_STATE_MACHINE MAC_STATE_MACHINE_1 (
	.clk(clk),
	.reset(reset),
	.ACK_N(ACK_N),
	.mr(mr),
	.mw(mw),
	.stop_n(stop_wire),
	.AS_N(AS_N),
	.WR_N(WR_N),
	.busy(busy),
	.MAC_STATE_OUT(MAC_STATE_OUT)
	);


	DLX_CONTROL_STATE_MACHINE DLX_CONTROL_STATE_MACHINE_1 ( 
	  .clk(clk),
    .reset(reset),
    .AEQZ(AEQZ),
    .step_en(step_en),
    .busy(busy),
    .IR(IR),
    .in_init(in_init),
    .mr(mr),
    .mw(mw),
    .add(add),
    .A_en(A_en),
    .B_en(B_en),
    .C_en(C_en),
    .IR_en(IR_en_wire),
    .PC_en(PC_en),
    .MDR_en(MDR_en),
    .MAR_en(MAR_en),
    .MDR_sel(MDR_sel),
    .A_sel(A_sel),
    .DINT_sel(DINT_sel),
    .test(test),
    .Itype(Itype),
    .shift(shift),
    .right(right),
    .jlink(jlink),
    .GPR_WE(GPR_WE),
    .S1_sel(S1_sel),
    .S2_sel(S2_sel),
    .DLX_STATE_OUT(DLX_STATE_OUT),
	 .E_en (E_en),
	 .SHARPEN_sel (SHARPEN_sel)	  
	);
 
	assign IR_en = IR_en_wire &&(~ACK_N) ;
	 
	always @(posedge clk)
	stop_reg <= stop_wire ;
	
	assign stop_n = (stop_reg || stop_wire) || (~ACK_N) ;  

endmodule



