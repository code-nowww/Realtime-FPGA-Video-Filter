`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/26/2021 09:09:27 PM
// Design Name: 
// Module Name: mux_2
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


    module mux #(parameter WIDTH=1)(
    input [WIDTH-1:0]data_1,
    input [WIDTH-1:0]data_2,
    input sel,
    output [WIDTH-1:0]data_out
    );
    assign data_out = sel ? data_2 : data_1;
endmodule
