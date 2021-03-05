`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/02/25 12:38:40
// Design Name: 
// Module Name: proj_top_mit
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


module proj_top_mit(
    input CLK_100MHZ,
    input RST,
    input capture,
    input [7:0] D,
    output XLK,
    input HS,
    inout SDA,
    output PWDN,
    input PLK,
    input VS,
    output SCL,
    output RET,
    output [3:0]VGA_R,
    output [3:0]VGA_G,
    output [3:0]VGA_B,
    output VGA_HS,
    output VGA_VS,
    input [15:0]SW,
    output [15:0]LED
    );
    wire pclk;   // 25MHz
    wire vsync;
    wire href;
    wire write_en;
    wire [7:0]data;
    wire [11:0]data_sram;
    wire [18:0]addr;
    wire [18:0]addr_sram;
    reg [18:0]r_addr;
    wire [23:0]data_capture;
    wire [11:0]sram_out;
    wire start, done;
    wire pixel_valid;
    wire frame_done;
    
    // generate a 25 MHz clk
    reg [15:0] cnt1 = 0;
    reg CLK_25MHZ;
    always @(posedge CLK_100MHZ)
        {CLK_25MHZ, cnt1} <= cnt1 + 16'h4000;
        
    // generate a 384 KHz clk
    reg [15:0] cnt2 = 0;
    reg sccb_clk;   // 384 KHz
    always @(posedge CLK_100MHZ)
        begin
            cnt2 <= (cnt2 >= 250) ? 16'h0000 : cnt2 + 1;
            sccb_clk <= (cnt2 == 16'h0000) ? ~sccb_clk : sccb_clk;
        end
        
    // generate a 12.5 MHz clk
    reg [15:0] cnt3 = 0;
    reg CLK_12_5MHZ;
    always @(posedge CLK_100MHZ)
//        {CLK_12_5MHZ, cnt3} <= cnt3 + 16'h2000;
        begin
            cnt3 <= (cnt3 >= 4) ? 16'h0000 : cnt3 + 1;
            CLK_12_5MHZ <= (cnt3 == 16'h0000) ? ~CLK_12_5MHZ : CLK_12_5MHZ;
        end
        
    assign vsync = VS;
    assign href = HS;
    assign pclk = PLK;
    assign XLK = CLK_25MHZ;
    assign start = SW[0];
    assign RET = ~RST;
    
    assign PWDN = 1'b0;
    assign data = D;
    
    // write enable
//    reg capture_done = 0;
//    always @(posedge CLK_100MHZ) begin
//        // write_en
//        if (~SW[1]) begin
//            write_en <= 1'b1;
//        end
//        else if (RST) write_en <= 1'b0;
//        else if (capture && ~capture_done) write_en <= 1'b1;
//        else write_en <= 1'b0;
//        // capture_done
//        if (~capture_done && frame_done && capture) capture_done = 1'b1;
//        else capture_done = 1'b0;
//    end

/*********************************************************************************/
// camera control
    camera_config #(.CLK_FREQ(25000000)) camera_config(
        .clk(CLK_25MHZ),
        .start(start),
        .sioc(SCL),
        .siod(SDA),
        .done(done)
        );
        
    camera_capture camera_capture(
        .p_clock(pclk),
        .vsync(vsync),
        .href(href),
        .p_data(data),
        .address(addr),
        .pixel_data(data_capture),
        .pixel_valid(pixel_valid),
        .frame_done(frame_done)
        );
/*********************************************************************************/
          
/*********************************************************************************/
// VGA control
    wire active;
    wire [9:0] x;
    wire [8:0] y;
    vga640x480 display (
                 .clk(CLK_100MHZ),
                 .clk_vga(CLK_25MHZ),
                 .rst(RST),
                 .hs(VGA_HS),
                 .vs(VGA_VS),
                 .x(x),
                 .y(y),
                 .active(active)
               );
    
    always @(posedge CLK_100MHZ)
      begin
        r_addr <= y * 640 + x;
      end
      
    assign {VGA_R, VGA_G, VGA_B} = active ? sram_out : 12'h000;
    assign LED[15:4] = {VGA_R, VGA_G, VGA_B};
/*********************************************************************************/
// data path control
    wire [11:0] test_data_out;
    wire [18:0] test_addr_out;
    wire test_valid_out;
    wire [11:0] mean_data_out;
    wire [18:0] mean_addr_out;
    wire mean_valid_out;
    wire [11:0] mid_data_out;
    wire [18:0] mid_addr_out;
    wire mid_valid_out;
    wire [11:0] grey_data_out;
    wire [18:0] grey_addr_out;
    wire grey_valid_out;
    wire [11:0] sobel_data_out;
    wire [18:0] sobel_addr_out;
    wire sobel_valid_out;
    wire [11:0] data_1;
    wire [18:0] addr_1;
    wire valid_1;
    wire [11:0] data_2;
    wire [18:0] addr_2;
    wire valid_2;
    wire [11:0] data_3;
    wire [18:0] addr_3;
    wire valid_3;
    wire [11:0] data_5;
    wire [18:0] addr_5;
    wire valid_5;
    
    // camera / test
    //// addr
    mux #(.WIDTH(19)) mux_0_addr(
                        .data_1(addr),  // default select
                        .data_2(test_addr_out),
                        .sel(SW[1]),
                        .data_out(addr_1)
                        );
    //// data
    mux #(.WIDTH(12)) mux_0_data(
                        .data_1({data_capture[11:8], data_capture[7:4], data_capture[3:0]}),
                        .data_2(test_data_out),
                        .sel(SW[1]),
                        .data_out(data_1)
                        );
    //// valid
    mux #(.WIDTH(1)) mux_0_valid(
                        .data_1(pixel_valid),
                        .data_2(test_valid_out),
                        .sel(SW[1]),
                        .data_out(valid_1)
                        );
                        
    // mean filter
    //// addr
    mux #(.WIDTH(19)) mux_1_addr(
                        .data_1(addr_1),  // default select
                        .data_2(mean_addr_out),
                        .sel(SW[2]),
                        .data_out(addr_2)
                        );
    //// data
    mux #(.WIDTH(12)) mux_1_data(
                        .data_1(data_1),
                        .data_2(mean_data_out),
                        .sel(SW[2]),
                        .data_out(data_2)
                        );
    //// valid
    mux #(.WIDTH(1)) mux_1_valid(
                        .data_1(valid_1),
                        .data_2(mean_valid_out),
                        .sel(SW[2]),
                        .data_out(valid_2)
                        );
    
    // mid filter
    //// addr
    mux #(.WIDTH(19)) mux_2_addr(
                        .data_1(addr_2),  // default select
                        .data_2(mid_addr_out),
                        .sel(SW[3]),
                        .data_out(addr_3)
                        );
    //// data
    mux #(.WIDTH(12)) mux_2_data(
                        .data_1(data_2),
                        .data_2(mid_data_out),
                        .sel(SW[3]),
                        .data_out(data_3)
                        );
    //// valid
    mux #(.WIDTH(1)) mux_2_valid(
                        .data_1(valid_2),
                        .data_2(mid_valid_out),
                        .sel(SW[3]),
                        .data_out(valid_3)
                        );
                        
    // grey
    //// addr
    mux #(.WIDTH(19)) mux_3_addr(
                        .data_1(addr_3),  // default select
                        .data_2(grey_addr_out),
                        .sel(SW[4]),
                        .data_out(addr_5)
                        );
    //// data
    mux #(.WIDTH(12)) mux_3_data(
                        .data_1(data_3),
                        .data_2(grey_data_out),
                        .sel(SW[4]),
                        .data_out(data_5)
                        );
    //// valid
    mux #(.WIDTH(1)) mux_3_valid(
                        .data_1(valid_3),
                        .data_2(grey_valid_out),
                        .sel(SW[4]),
                        .data_out(valid_5)
                        );
                        
    // sobel
    //// addr
    mux #(.WIDTH(19)) mux_5_addr(
                        .data_1(addr_5),
                        .data_2(sobel_addr_out),
                        .sel(SW[6]),
                        .data_out(addr_sram)
                        );
    //// data
    mux #(.WIDTH(12)) mux_5_data(
                        .data_1(data_5),
                        .data_2(sobel_data_out),
                        .sel(SW[6]),
                        .data_out(data_sram)
                        );
    //// valid
    mux #(.WIDTH(1)) mux_5_valid(
                        .data_1(valid_5),
                        .data_2(sobel_valid_out),
                        .sel(SW[6]),
                        .data_out(write_en)
                        );
/*********************************************************************************/

/*********************************************************************************/
// test image
    test_image_outer test_image_outer(
        .p_clock(CLK_12_5MHZ),
        .rst(RST),
        .addr_out(test_addr_out),
        .data_out(test_data_out),
        .valid(test_valid_out)
        );
/*********************************************************************************/

/*********************************************************************************/
// mean filter
    mean_filter mean_filter(
            .CLK_100MHZ(CLK_100MHZ),
            .RST(RST),
            .addr(addr_1),
            .data(data_1),
            .valid(valid_1),
            .data_out(mean_data_out),
            .addr_out(mean_addr_out),
            .valid_out(mean_valid_out)
            );
/*********************************************************************************/

/*********************************************************************************/
// mid filter
    mid_filter mid_filter(
            .CLK_100MHZ(CLK_100MHZ),
            .RST(RST),
            .addr(addr_2),
            .data(data_2),
            .valid(valid_2),
            .data_out(mid_data_out),
            .addr_out(mid_addr_out),
            .valid_out(mid_valid_out)
            );
/*********************************************************************************/

/*********************************************************************************/
// grey filter
//    wire [11:0] gray_pixel;
//    wire [11:0] gray_pixel_dark;
    rgb444_to_gray rgb444_to_gray(
                                .CLK_100MHZ(CLK_100MHZ),
                                .RST(RST),
                                .addr(addr_3),
                                .data(data_3),
                                .valid(valid_3),
                                .mode(SW[5]),
                                .data_out(grey_data_out),
                                .addr_out(grey_addr_out),
                                .valid_out(grey_valid_out)
//                                .pixel(sram_out), 
//                                .gray_pixel(gray_pixel), 
//                                .gray_pixel_dark(gray_pixel_dark)
                                );
/*********************************************************************************/

/*********************************************************************************/
// sobel filter
    sobel sobel(
            .CLK_100MHZ(CLK_100MHZ),
            .RST(RST),
            .addr(addr_5),
            .data(data_5),
            .valid(valid_5),
            .threshold(SW[15:8]),
            .data_out(sobel_data_out),
            .addr_out(sobel_addr_out),
            .valid_out(sobel_valid_out)
            );
/*********************************************************************************/
    
/*********************************************************************************/
// SRAM
    wire [107:0] data_3x3;
    sram #(.ADDR_WIDTH(19), .DATA_WIDTH(12), .DEPTH(307200), .MEMFILE()) sram1(
        .i_clk(CLK_100MHZ),
        .i_addr(addr_sram),
        .i_addr_1(r_addr),
        .i_write(write_en),
        // 565 to 444: 四舍五入
//        .i_data({data_capture[11] ? data_capture[15:12] + 4'h1 : data_capture[15:12],
//                 data_capture[6] ? data_capture[10:7] + 4'h1 : data_capture[10:7],
//                 data_capture[0] ? data_capture[4:1] + 4'h1 : data_capture[4:1]}),
        // 565 to 444: 直接右移
//        .i_data({data_capture[15:12], data_capture[10:7], data_capture[4:1]}),
        // 直接 444
        .i_data(data_sram),
        .o_data_1(sram_out)
//        .i_addr_3x3(r_addr),
//        .o_data_3x3(data_3x3)
        );
/*********************************************************************************/

endmodule

