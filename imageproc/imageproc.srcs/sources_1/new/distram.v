`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/02/27 16:16:34
// Design Name: 
// Module Name: distram
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


module distram #(parameter ADDR_WIDTH=8, DATA_WIDTH=8, DEPTH=256, MEMFILE="") (
         input wire i_clk,
         input wire [ADDR_WIDTH-1:0] i_addr, i_addr_1,
         input wire i_write,
         input wire [DATA_WIDTH-1:0] i_data,
         output [DATA_WIDTH-1:0] o_data_1
       );

    reg [DATA_WIDTH-1:0] memory_array [0:DEPTH-1];
    
    initial
      begin
        if (MEMFILE > 0)
          begin
            $display("Loading memory init file '" + MEMFILE + "' into array.");
            $readmemh(MEMFILE, memory_array);
          end
      end
      
    always @(posedge i_clk)  //
        if (i_write) 
            memory_array[i_addr] <= i_data;
    
    assign o_data_1 = memory_array[i_addr_1];

endmodule

