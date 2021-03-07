`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/26/2021 09:46:39 PM
// Design Name: 
// Module Name: soble
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


module sobel(
    input CLK_100MHZ,
    input RST,
    input [18:0]addr,
    input [11:0]data,
    input valid,
    input [7:0]threshold,
    output reg [11:0]data_out,
    output reg [18:0]addr_out,
    output reg valid_out
    );

    reg processing = 0;
    reg [11:0] martix_00, martix_01, martix_02, martix_10, martix_11, martix_12, martix_20, martix_21, martix_22;
    wire [11:0] line1, line2, line3;
    wire [18:0] addr_pixel;
    wire valid_pause;
    pulse pulse(
         .clk(CLK_100MHZ),
         .button(valid),
         .button_redge(valid_pause)
       );
    
    always@(posedge valid_pause)
    begin
        martix_02 <= line1;
        martix_01 <= martix_02;
        martix_00 <= martix_01;
        martix_12 <= line2;
        martix_11 <= martix_12;
        martix_10 <= martix_11;
        martix_22 <= line3;
        martix_21 <= martix_22;
        martix_20 <= martix_21;
    end
    
    line_cache(
            .CLK_100MHZ(CLK_100MHZ),
            .RST(RST),
            .valid(valid_pause),
            .data(data),
            .address(addr),
            .line1(line1),
            .line2(line2),
            .line3(line3),
            .addr_out(addr_pixel)
            );
    
    reg [18:0] stage1_addr, stage2_addr, stage3_addr;
    reg [5:0] stage1_data_line1_x, stage1_data_line2_x, stage1_data_line3_x, stage1_data_line1_y, stage1_data_line2_y, stage1_data_line3_y;
    reg [6:0] stage2_data_x, stage2_data_y;
    wire [7:0] final_data;
    
    
    always@(posedge CLK_100MHZ)
    begin
//        stage1_data_line1_x <= martix_02[3:0] + (martix_12[3:0] << 1) + martix_22[3:0];
//        stage1_data_line2_x <= martix_00[3:0] + (martix_10[3:0] << 1) + martix_20[3:0];
//        stage1_data_line1_y <= martix_00[3:0] + (martix_01[3:0] << 1) + martix_02[3:0];
//        stage1_data_line2_y <= martix_20[3:0] + (martix_02[3:0] << 1) + martix_22[3:0];
    
        stage1_data_line1_x <= martix_02[3:0] - martix_00[3:0];
        stage1_data_line2_x <= (martix_12[3:0] - martix_10[3:0]) << 1;
        stage1_data_line3_x <= martix_22[3:0] - martix_20[3:0];
        stage1_data_line1_y <= martix_00[3:0] - martix_20[3:0];
        stage1_data_line2_y <= (martix_01[3:0] - martix_02[3:0]) << 1;
        stage1_data_line3_y <= martix_02[3:0] - martix_22[3:0];
        stage1_addr <= addr_pixel;
        
        stage2_data_x <= stage1_data_line1_x + stage1_data_line2_x + stage1_data_line3_x;
        stage2_data_y <= stage1_data_line1_y + stage1_data_line2_y + stage1_data_line3_y;
        stage2_addr <= stage1_addr;
        
    end
    
    assign final_data = (stage2_data_x > 0 ? stage2_data_x : -stage2_data_x) + 
                        (stage2_data_y > 0 ? stage2_data_y : -stage2_data_y);

    always@(posedge CLK_100MHZ or posedge RST)
    begin
        if(RST)
            valid_out <= 1'b0;
        else if(valid_pause)
        begin
            data_out <= (final_data > threshold[7:0]) ? 12'h000 : 12'hfff;
            addr_out <= stage2_addr;
            valid_out <= 1'b1;
        end
        else
        begin
            valid_out <= 1'b0;
        end
    end
    
endmodule
