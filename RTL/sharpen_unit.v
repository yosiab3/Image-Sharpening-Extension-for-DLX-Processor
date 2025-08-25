`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:21:08 08/19/2025 
// Design Name: 
// Module Name:    sharpen_unit 
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
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:29:06 08/17/2025 
// Design Name: 
// Module Name:    sharpen_unit 
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
module sharpen_unit(

    input [31:0] rs1,      
    input [31:0] rs2,      
    input [31:0] up_row,   
    output [31:0] rd        
);
    
    // Split current row word into bytes
    wire [7:0] m0 = rs1[31:24];
    wire [7:0] m1 = rs1[23:16];
    wire [7:0] m2 = rs1[15:8];
    wire [7:0] m3 = rs1[7:0];

    wire [7:0] up_of_m0 = up_row[31:24];
    wire [7:0] up_of_m1 = up_row[23:16];
    wire [7:0] up_of_m2 = up_row[15:8];
    wire [7:0] up_of_m3 = up_row[7:0];

    // Down row = rs2
    wire [7:0] down_of_m0 = rs2[31:24];
    wire [7:0] down_of_m1 = rs2[23:16];
    wire [7:0] down_of_m2 = rs2[15:8];
    wire [7:0] down_of_m3 = rs2[7:0];

    // Horizontal neighbors with reflection
    wire [7:0] left_of_m0_reflect = m1;
    wire [7:0] left_of_m1         = m0;
    wire [7:0] left_of_m2         = m1;
    wire [7:0] left_of_m3         = m2;

    wire [7:0] right_of_m0         = m1;
    wire [7:0] right_of_m1         = m2;
    wire [7:0] right_of_m2         = m3;
    wire [7:0] right_of_m3_reflect = m2;

    // Per-byte sharpen (combinational)
    function automatic [7:0] sharpen_byte;
        input [7:0] mid, leftn, rightn, upn, downn;
        reg   signed [11:0] acc;
        begin
            acc =  $signed({4'd0, mid}) <<< 2;  // *4
            acc =  acc + $signed({4'd0, mid});  // +1 => *5
            acc =  acc
                 - $signed({4'd0, leftn})
                 - $signed({4'd0, rightn})
                 - $signed({4'd0, upn})
                 - $signed({4'd0, downn});

            if (acc < 0)             sharpen_byte = 8'd0;
            else if (acc > 12'sd255) sharpen_byte = 8'd255;
            else                     sharpen_byte = acc[7:0];
        end
    endfunction

    // Compute outputs as wires
    wire [7:0] y0 = sharpen_byte(m0, left_of_m0_reflect, right_of_m0,         up_of_m0, down_of_m0);
    wire [7:0] y1 = sharpen_byte(m1, left_of_m1,         right_of_m1,         up_of_m1, down_of_m1);
    wire [7:0] y2 = sharpen_byte(m2, left_of_m2,         right_of_m2,         up_of_m2, down_of_m2);
    wire [7:0] y3 = sharpen_byte(m3, left_of_m3,         right_of_m3_reflect, up_of_m3, down_of_m3);

    assign rd = {y0, y1, y2, y3};

endmodule
