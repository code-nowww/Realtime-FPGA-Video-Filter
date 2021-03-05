`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/24/2021 10:42:13 PM
// Design Name: 
// Module Name: proj_top
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


module proj_top(
    input CLK_100MHZ,
    input RST,
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
    wire [18:0]addr;
    reg [18:0]r_addr;
    wire [23:0]data_capture;
    wire [11:0]sram_out;
    wire start, done;
    
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
            cnt2 <= (cnt2 >= 260) ? 16'h0000 : cnt2 + 1;
            sccb_clk <= (cnt2 == 16'h0000) ? ~sccb_clk : sccb_clk;
        end
    
    assign vsync = VS;
    assign href = HS;
    assign pclk = PLK;
    assign XLK = CLK_25MHZ;
    assign start = SW[0];
    assign RET = SW[1];
    assign LED[0] = done;
    assign LED[15] = 1;
    assign data = D;
    
    ov_7670_init init(
        .clk(CLK_25MHZ),       // System clock for state transitions
        .clk_sccb(sccb_clk),  // Clock for SCCB protocol (100kHz to 400kHz)
        .reset(~RST),     // Async reset signal
        .pwdn(PWDN),
        .sio_d(SDA),
        .sio_c(SCL),
        .start(start),
        .done(done)
    );
    
    ov_7670_capture capture(
        .pclk(pclk),
        .vsync(vsync),
        .href(href),
        .data(data),
        .addr(addr),
        .data_out(data_capture),
        .write_en(write_en)
    );
    
    sram #(.ADDR_WIDTH(19), .DATA_WIDTH(12), .DEPTH(307200), .MEMFILE()) sram1(
         .i_clk(CLK_100MHZ),
         .i_addr_a(addr),
         .i_addr_b(r_addr),
         .i_write(write_en),
         .i_data({data_capture[23:20], data_capture[15:12], data_capture[7:4]}),
         .o_data(sram_out)
       );
       
    wire active;
//    wire [11:0]RGB;
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
//                 .animate(animate),
                 .active(active)
               );
    
    always @(posedge CLK_100MHZ)
      begin
        r_addr <= y * 640 + x;
      end
    
//    assign {VGA_R, VGA_G, VGA_B} = active ? SW[12:1] : 12'h000;
    assign {VGA_R, VGA_G, VGA_B} = active ? sram_out : 12'h000;
//    assign LED[14:3] =  {VGA_R, VGA_G, VGA_B};
    assign LED[14:3] = {VGA_R, VGA_G, VGA_B};
endmodule
