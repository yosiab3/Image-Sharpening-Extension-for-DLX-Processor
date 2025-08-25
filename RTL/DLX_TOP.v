`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    03:30:10 01/11/2025 
// Design Name: 
// Module Name:    DLX_TOP 
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
module DLX_TOP(
	
	input clk,
	input reset,
	input step_en,
	input ACK_N,
	input [4:0] D_ADR,
	input [31:0] DI,
	output A_en,
	output A_sel,
	output AEQZ,
	output [2:0] ALUF,
	output [31:0] AO,
	output AS_N,
	output B_en,
	output C_en,
	output DINT_sel,
	output [31:0] DO,
	output [31:0] GPR_D,
	output GPR_WE,
	output [31:0] IR,
	output IR_en,
	output Itype,
	output MAR_en,
	output MDR_en,
	output MDR_sel,
	output OVF,
	output PC_en,
	output [1:0] S1_sel,
	output [1:0] S2_sel,
	output WR_N,
	output add,
	output busy,
	output in_init,
	output jlink,
	output mr,
	output mw,
	output shift,
	output stop_n,
	output test,
	output [4:0] DLX_STATE_OUT,
	output [1:0] MAC_STATE_OUT,
	
	output E_en,
	output SHARPEN_sel


    );
	
	wire right; 
	
	
	DLX_CONTROL_TOP DLX_CONTROL_TOP_1 (
	.clk(clk),
	.reset(reset),
	.AEQZ(AEQZ),
	.step_en(step_en),
	.IR(IR),
	.ACK_N(ACK_N),
	.in_init(in_init),
	.add(add),
	.A_en(A_en),
	.B_en(B_en),
	.C_en(C_en),
	.A_sel(A_sel),
	.AS_N(AS_N),
	.WR_N(WR_N),
	.busy(busy),
	.DINT_sel(DINT_sel),
	.GPR_WE(GPR_WE),
	.IR_en(IR_en),
	.MAR_en(MAR_en),
	.MDR_en(MDR_en),
	.MDR_sel(MDR_sel),
	.PC_en(PC_en),
	.Itype(Itype),
	.jlink(jlink),
	.mr(mr),
	.mw(mw),
	.right(right),
	.S1_sel(S1_sel),
	.S2_sel(S2_sel),
	.shift(shift),
	.stop_n(stop_n),
	.test(test),
	.DLX_STATE_OUT(DLX_STATE_OUT),
	.MAC_STATE_OUT(MAC_STATE_OUT),
 	.E_en (E_en),
	.SHARPEN_sel(SHARPEN_sel)
	);

	DLX_DATAPATH_TOP DLX_DATAPATH_TOP_1 (
	.clk(clk),
	.reset(reset),
	.IR_en(IR_en),
	.A_en(A_en),
	.B_en(B_en),
	.C_en(C_en),
	.S1_SEL(S1_sel),
	.S2_SEL(S2_sel),
	.add(add),
	.test(test),
	.right(right),
	.shift(shift),
	.DI(DI),
	.MDR_en(MDR_en),
	.MAR_en(MAR_en),
	.A_MUX_SEL(A_sel),
	.GPR_WE(GPR_WE),
	.PC_en(PC_en),
	.D_ADR(D_ADR),
	.DINT_MUX_SEL(DINT_sel),
	.MDR_MUX_SEL(MDR_sel),
	.SHARPEN_MUX_SEL(SHARPEN_sel),
	.E_en(E_en),
	.AO(AO),
	.DO(DO),
	.OVF(OVF),
	.GPR_D(GPR_D),
	.IR(IR),
	.AEQZ_OUT(AEQZ)  
	);




endmodule
