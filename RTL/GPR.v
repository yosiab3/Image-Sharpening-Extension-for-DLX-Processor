`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:37:28 12/15/2024 
// Design Name: 
// Module Name:    GPR 
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
module GPR(
    input clk,
    input GPR_WE,
    input [31:0] C,
    input [4:0] A_ADR,
    input [4:0] B_ADR,
    input [4:0] C_ADR,
    input [4:0] D_ADR,
    output [31:0] A,
    output [31:0] B,
    output [31:0] D,
	 output [31:0] E,
    output AEQZ
    );

	wire [4:0] E_ADR;
	assign E_ADR = 5'b01010;
	
	wire GPR_EN_RAM;
	
	assign GPR_EN_RAM = (C_ADR[0] || C_ADR[1] || C_ADR[2] || C_ADR[3]
	|| C_ADR[4]) && GPR_WE;
	
	assign AEQZ = ~|A; 
	
	wire [4:0] ADR_RAM_A;
	wire [4:0] ADR_RAM_B;
	wire [4:0] ADR_RAM_D;
	wire [4:0] ADR_RAM_E;

	MUX5bit mux_a (
	.B(C_ADR),
	.A(A_ADR),
	.sel(GPR_WE),
	.O(ADR_RAM_A)
	);
	
	MUX5bit mux_b (
	.B(C_ADR),
	.A(B_ADR),
	.sel(GPR_WE),
	.O(ADR_RAM_B)
	);
	
	MUX5bit mux_d (
	.B(C_ADR),
	.A(D_ADR),
	.sel(GPR_WE),
	.O(ADR_RAM_D)
	);
	
	MUX5bit mux_e (
	.B(C_ADR),
	.A(E_ADR),
	.sel(GPR_WE),
	.O(ADR_RAM_E)
	);
	
	RAM32x32 ram_a (
	.CLK(clk),
	.ADDR(ADR_RAM_A),
	.WE(GPR_EN_RAM),
	.DI(C),
	.DO(A)
	);
	RAM32x32 ram_b (
	.CLK(clk),
	.ADDR(ADR_RAM_B),
	.WE(GPR_EN_RAM),
	.DI(C),
	.DO(B));
	
	RAM32x32 ram_d (
	.CLK(clk),
	.ADDR(ADR_RAM_D),
	.WE(GPR_EN_RAM),
	.DI(C),
	.DO(D)
	);
	
	RAM32x32 ram_e (
	.CLK(clk),
	.ADDR(ADR_RAM_E),
	.WE(GPR_EN_RAM),
	.DI(C),
	.DO(E)
	);
	
endmodule
