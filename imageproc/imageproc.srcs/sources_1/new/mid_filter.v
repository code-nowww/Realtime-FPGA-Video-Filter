`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/02/27 03:14:09
// Design Name: 
// Module Name: mid_filter
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


module mid_filter(
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
    
    task get_max_mid_min (
        input [7:0] data1,
        input [7:0] data2,
        input [7:0] data3,
        output reg [7:0] max,
        output reg [7:0] mid,
        output reg [7:0] min
        );
        if (data1 < data2)
        begin
            if (data2 < data3)
            begin
                max <= data3;
                mid <= data2;
                min <= data1;
            end
            else
            begin
                // data2 > data1,data3
                if (data1 < data3)
                begin
                    max <= data2;
                    mid <= data3;
                    min <= data1;
                end
                else
                begin
                    max <= data2;
                    mid <= data1;
                    min <= data3;
                end
            end
        end
        else
        begin
            // data1 > data2
            if (data2 > data3)
            begin
                max <= data1;
                mid <= data2;
                min <= data3;
            end
            else
            begin
                // data1, data3 > data2
                if (data1 > data3)
                begin
                    max <= data1;
                    mid <= data3;
                    min <= data2;
                end
                else
                begin
                    max <= data3;
                    mid <= data1;
                    min <= data2;
                end
            end
        end
    endtask
    
    task get_max (
        input [7:0] data1,
        input [7:0] data2,
        input [7:0] data3,
        output reg [7:0] max
        );
        max <= data1 > data2 ? (data1 > data3 ? data1 : data3) : (data2 > data3 ? data2 : data3);
    endtask
    
    task get_mid (
        input [7:0] data1,
        input [7:0] data2,
        input [7:0] data3,
        output reg [7:0] mid
        );
        if (data1 < data2)
        begin
            if (data2 < data3)
            begin
                mid <= data2;
            end
            else
            begin
                // data2 > data1,data3
                if (data1 < data3)
                begin
                    mid <= data3;
                end
                else
                begin
                    mid <= data1;
                end
            end
        end
        else
        begin
            // data1 > data2
            if (data2 > data3)
            begin
                mid <= data2;
            end
            else
            begin
                // data1, data3 > data2
                if (data1 > data3)
                begin
                    mid <= data3;
                end
                else
                begin
                    mid <= data1;
                end
            end
        end
    endtask
    
    task get_min (
        input [7:0] data1,
        input [7:0] data2,
        input [7:0] data3,
        output reg [7:0] max
        );
        max <= data1 < data2 ? (data1 < data3 ? data1 : data3) : (data2 < data3 ? data2 : data3);
    endtask
    
    //stage1
    reg [18:0] stage1_addr;
    reg [3:0] stage1_data_r_maxh0, stage1_data_r_maxh1, stage1_data_r_maxh2;
    reg [3:0] stage1_data_r_midh0, stage1_data_r_midh1, stage1_data_r_midh2;
    reg [3:0] stage1_data_r_minh0, stage1_data_r_minh1, stage1_data_r_minh2;
    reg [3:0] stage1_data_g_maxh0, stage1_data_g_maxh1, stage1_data_g_maxh2;
    reg [3:0] stage1_data_g_midh0, stage1_data_g_midh1, stage1_data_g_midh2;
    reg [3:0] stage1_data_g_minh0, stage1_data_g_minh1, stage1_data_g_minh2;
    reg [3:0] stage1_data_b_maxh0, stage1_data_b_maxh1, stage1_data_b_maxh2;
    reg [3:0] stage1_data_b_midh0, stage1_data_b_midh1, stage1_data_b_midh2;
    reg [3:0] stage1_data_b_minh0, stage1_data_b_minh1, stage1_data_b_minh2;
    // stage2
    reg [3:0] stage2_r_minmax, stage2_r_midmid, stage2_r_maxmin;
    reg [3:0] stage2_g_minmax, stage2_g_midmid, stage2_g_maxmin;
    reg [3:0] stage2_b_minmax, stage2_b_midmid, stage2_b_maxmin;
    reg [18:0] stage2_addr;
    // stage3
    reg [18:0] stage3_addr;
    reg [3:0] stage3_data_r, stage3_data_g, stage3_data_b;
    
    always@(posedge CLK_100MHZ)
    begin
        get_max_mid_min(matrix_00[11:8], matrix_01[11:8], matrix_02[11:8], stage1_data_r_maxh0, stage1_data_r_midh0, stage1_data_r_minh0);
        get_max_mid_min(matrix_10[11:8], matrix_11[11:8], matrix_12[11:8], stage1_data_r_maxh1, stage1_data_r_midh1, stage1_data_r_minh1);
        get_max_mid_min(matrix_20[11:8], matrix_21[11:8], matrix_22[11:8], stage1_data_r_maxh2, stage1_data_r_midh2, stage1_data_r_minh2);
        get_max_mid_min(matrix_00[7:4], matrix_01[7:4], matrix_02[7:4], stage1_data_g_maxh0, stage1_data_g_midh0, stage1_data_g_minh0);
        get_max_mid_min(matrix_10[7:4], matrix_11[7:4], matrix_12[7:4], stage1_data_g_maxh1, stage1_data_g_midh1, stage1_data_g_minh1);
        get_max_mid_min(matrix_20[7:4], matrix_21[7:4], matrix_22[7:4], stage1_data_g_maxh2, stage1_data_g_midh2, stage1_data_g_minh2);
        get_max_mid_min(matrix_00[3:0], matrix_01[3:0], matrix_02[3:0], stage1_data_b_maxh0, stage1_data_b_midh0, stage1_data_b_minh0);
        get_max_mid_min(matrix_10[3:0], matrix_11[3:0], matrix_12[3:0], stage1_data_b_maxh1, stage1_data_b_midh1, stage1_data_b_minh1);
        get_max_mid_min(matrix_20[3:0], matrix_21[3:0], matrix_22[3:0], stage1_data_b_maxh2, stage1_data_b_midh2, stage1_data_b_minh2);
        stage1_addr <= addr_pixel;
        
        // min of the maxes in each line
        get_min(stage1_data_r_maxh0, stage1_data_r_maxh1, stage1_data_r_maxh2, stage2_r_minmax);
        get_min(stage1_data_g_maxh0, stage1_data_g_maxh1, stage1_data_g_maxh2, stage2_g_minmax);
        get_min(stage1_data_b_maxh0, stage1_data_b_maxh1, stage1_data_b_maxh2, stage2_b_minmax);
        // mid of the mids in each lin
        get_min(stage1_data_r_midh0, stage1_data_r_midh1, stage1_data_r_midh2, stage2_r_midmid);
        get_min(stage1_data_g_midh0, stage1_data_g_midh1, stage1_data_g_midh2, stage2_g_midmid);
        get_min(stage1_data_b_midh0, stage1_data_b_midh1, stage1_data_b_midh2, stage2_b_midmid);
        // max of the mins in each line
        get_max(stage1_data_r_minh0, stage1_data_r_minh1, stage1_data_r_minh2, stage2_r_maxmin);
        get_max(stage1_data_g_minh0, stage1_data_g_minh1, stage1_data_g_minh2, stage2_g_maxmin);
        get_max(stage1_data_b_minh0, stage1_data_b_minh1, stage1_data_b_minh2, stage2_b_maxmin);
        stage2_addr <= stage1_addr;
        
        // mid of minmax, midmid, maxmin
        get_mid(stage2_r_minmax, stage2_r_midmid, stage2_r_maxmin, stage3_data_r);
        get_mid(stage2_g_minmax, stage2_g_midmid, stage2_g_maxmin, stage3_data_g);
        get_mid(stage2_b_minmax, stage2_b_midmid, stage2_b_maxmin, stage3_data_b);
        stage3_addr <= stage2_addr;
    end
    
    always@(posedge CLK_100MHZ or posedge RST)
    begin
        if(RST)
        begin
            valid_out <= 1'b0;
        end
        else if(valid_pulse)
        begin
            data_out <= {stage3_data_r, stage3_data_g, stage3_data_b};
            addr_out <= stage3_addr;
            valid_out <= 1'b1;
        end
        else
        begin
            valid_out <= 1'b0;
        end
    end
    
endmodule
