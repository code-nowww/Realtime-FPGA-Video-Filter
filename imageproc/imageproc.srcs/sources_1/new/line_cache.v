`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/26/2021 10:53:52 PM
// Design Name: 
// Module Name: line_cache
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


module line_cache(
    input CLK_100MHZ,
    input valid,
    input RST,
    input [11:0]data,
    input [18:0]address,
    output [11:0]line1,
    output [11:0]line2,
    output [11:0]line3,
    output [18:0]addr_out
    );
    wire [11:0] ram1_out, ram2_out, ram3_out;
    wire [18:0] addr1_out, addr2_out;
    
    assign line1 = ram3_out;
    assign line2 = ram2_out;
    assign line3 = ram1_out;
    assign addr_out = addr2_out;
    
    shift_ram ram_1(
                .D(data),
                .CLK(CLK_100MHZ),
                .CE(valid),
                .SCLR(RST),
                .Q(ram1_out)
                );
    shift_ram ram_2(
                .D(ram1_out),
                .CLK(CLK_100MHZ),
                .CE(valid),
                .SCLR(RST),
                .Q(ram2_out)
                );
    shift_ram ram_3(
                .D(ram2_out),
                .CLK(CLK_100MHZ),
                .CE(valid),
                .SCLR(RST),
                .Q(ram3_out)
                );
    shift_ram_addr ram_addr1(
                .D(address - 19'd2),
                .CLK(CLK_100MHZ),
                .CE(valid),
                .SCLR(RST),
                .Q(addr1_out)
                );
    shift_ram_addr ram_addr2(
                .D(addr1_out),
                .CLK(CLK_100MHZ),
                .CE(valid),
                .SCLR(RST),
                .Q(addr2_out)
                );
endmodule
