module sram #(parameter ADDR_WIDTH=8, DATA_WIDTH=8, DEPTH=256, MEMFILE="") (
         input wire i_clk,
         input wire [ADDR_WIDTH-1:0] i_addr, i_addr_1, //i_addr_3x3,
         input wire i_write,
         input wire [DATA_WIDTH-1:0] i_data,
         output reg [DATA_WIDTH-1:0] o_data_1
//         output reg [DATA_WIDTH * 9 - 1:0] o_data_3x3
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
  
always @(posedge i_clk)  //Ð´
    if (i_write) 
        memory_array[i_addr] <= i_data;

always @(posedge i_clk) begin
    o_data_1 <= memory_array[i_addr_1];  //¶Á
end

//always @(posedge i_clk) begin
//    if (i_addr_3x3 % 640 == 0 || i_addr_3x3 % 640 == 639 || i_addr_3x3 / 480 == 0 || i_addr_3x3 / 480 == 479) begin
//        o_data_3x3 = {9{o_data_3x3}};
//    end
//    else begin
//        o_data_3x3 = {memory_array[o_data_3x3 - 19'h641], memory_array[o_data_3x3 - 19'h640], memory_array[o_data_3x3 - 19'h639],
//                      memory_array[o_data_3x3 - 19'h1], memory_array[o_data_3x3], memory_array[o_data_3x3 + 19'h1],
//                      memory_array[o_data_3x3 + 19'h639], memory_array[o_data_3x3 + 19'h640], memory_array[o_data_3x3 + 19'h641]};
//    end
//end
//always @ (posedge i_clk)
//  begin
//    if(i_write)
//      begin
//        memory_array[i_addr_a] <= i_data;
//      end
//    else
//      begin
//        o_data <= memory_array[i_addr];
//      end
//  end
endmodule
