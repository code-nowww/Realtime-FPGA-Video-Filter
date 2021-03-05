`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/02/25 18:37:38
// Design Name: 
// Module Name: rgb444_to_gray
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


module rgb444_to_gray(
//    input [11:0] pixel,
    input CLK_100MHZ,
    input RST,
    input mode,
    input [18:0]addr,
    input [11:0]data,
    input valid,
    output reg [11:0]data_out,
    output reg [18:0]addr_out,
    output reg valid_out
//    output [11:0] gray_pixel,
//    output [11:0] gray_pixel_dark
    );
    

    // Gray = (R*1 + G*2 + B*1) >> 2
//    wire [7:0] tmp_gray;
//    wire [3:0] gray;
//    assign tmp_gray = {4'h0, pixel[11:8]} + {4'h0, pixel[7:4]} << 1 + {4'h0, pixel[3:0]} ;
//    assign gray = 4'hf - tmp_gray[5:2];
//    assign gray_pixel = {gray, gray, gray};
//    assign gray_pixel_dark = {tmp_gray[5:2], tmp_gray[5:2], tmp_gray[5:2]};
    
    // Gray = (R*2 + G*5 + B*1) >> 3
    wire [7:0] tmp_gray;
    wire [3:0] gray;
    wire [11:0] gray_pixel;
    wire [11:0] gray_pixel_dark;
    assign tmp_gray = data[11:8] * 2 + data[7:4] * 5 + data[3:0];
    assign gray = 4'hf - tmp_gray[6:3];
    assign gray_pixel = {gray, gray, gray};
    assign gray_pixel_dark = {tmp_gray[6:3], tmp_gray[6:3], tmp_gray[6:3]};
    
    always @(posedge CLK_100MHZ or posedge RST)
    begin
        if(RST)
        begin
            valid_out <= 1'b0;
        end
        else if(valid)
        begin
            data_out <= (mode == 1'b1) ? gray_pixel_dark : gray_pixel;
            addr_out <= addr;
            valid_out <= 1'b1;
        end
        else
        begin
            valid_out <= 1'b0;
        end
    end
    
endmodule
