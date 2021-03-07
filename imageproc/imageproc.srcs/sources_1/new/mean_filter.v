`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/02/25 21:43:49
// Design Name: 
// Module Name: mean_filter
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


module mean_filter(
    input CLK_100MHZ,
    input RST,
    input [18:0]addr,
    input [11:0]data,
    input valid,
    output reg [11:0]data_out,
    output reg [18:0]addr_out,
    output reg valid_out
    );
    
    reg processing = 0;
    reg [11:0] matrix_00, matrix_01, matrix_02, matrix_10, matrix_11, matrix_12, matrix_20, matrix_21, matrix_22;
    wire [11:0] line1, line2, line3;
    wire [18:0] addr_pixel;
    wire valid_pulse;
    pulse pulse(
         .clk(CLK_100MHZ),
         .button(valid),
         .button_redge(valid_pulse)
       );
    
    always@(posedge valid_pulse)
    begin
        matrix_02 <= line1;
        matrix_01 <= matrix_02;
        matrix_00 <= matrix_01;
        matrix_12 <= line2;
        matrix_11 <= matrix_12;
        matrix_10 <= matrix_11;
        matrix_22 <= line3;
        matrix_21 <= matrix_22;
        matrix_20 <= matrix_21;
    end
    
    line_cache(
            .CLK_100MHZ(CLK_100MHZ),
            .RST(RST),
            .valid(valid_pulse),
            .data(data),
            .address(addr),
            .line1(line1),
            .line2(line2),
            .line3(line3),
            .addr_out(addr_pixel)
            );
    
    reg [18:0] stage1_addr;
    reg [7:0] stage1_data_r, stage1_data_g, stage1_data_b;
    
    always@(posedge CLK_100MHZ)
    begin
        stage1_data_r <= (matrix_00[11:8]     ) + (matrix_01[11:8] << 1) + (matrix_02[11:8]     )
                       + (matrix_10[11:8] << 1) + (matrix_11[11:8] << 2) + (matrix_12[11:8] << 1)
                       + (matrix_20[11:8]     ) + (matrix_21[11:8] << 1) + (matrix_22[11:8]     )
                          ;
                      
        stage1_data_g <= (matrix_00[7:4]     ) + (matrix_01[7:4] << 1) + (matrix_02[7:4]     )
                       + (matrix_10[7:4] << 1) + (matrix_11[7:4] << 2) + (matrix_12[7:4] << 1)
                       + (matrix_20[7:4]     ) + (matrix_21[7:4] << 1) + (matrix_22[7:4]     )
                         ;
                      
        stage1_data_b <= (matrix_00[3:0]     ) + (matrix_01[3:0] << 1) + (matrix_02[3:0]     )
                       + (matrix_10[3:0] << 1) + (matrix_11[3:0] << 2) + (matrix_12[3:0] << 1)
                       + (matrix_20[3:0]     ) + (matrix_21[3:0] << 1) + (matrix_22[3:0]     )
                        ;
                        
        stage1_addr <= addr_pixel;
    end
    
    always@(posedge CLK_100MHZ or posedge RST)
    begin
        if(RST)
        begin
            valid_out <= 1'b0;
        end
        else if(valid_pulse)
        begin
            data_out <= {stage1_data_r[7:4], stage1_data_g[7:4], stage1_data_b[7:4]};
            addr_out <= stage1_addr;
            valid_out <= 1'b1;
        end
        else
        begin
            valid_out <= 1'b0;
        end
    end
    
endmodule
