module test_image_outer(
	input wire p_clock,
	input wire rst,
    output reg [18:0] addr_out,
	output reg [11:0] data_out,
	output reg valid
    );
    
    // ROM for test image
    wire [18:0] local_addr;
    wire [11:0] local_data;
    reg [9:0] x_count, y_count;
//    test_image test_image(.addra(local_addr), .clka(p_clock), .douta(data), .ena(1'b1));
//    sram #(.ADDR_WIDTH(19), .DATA_WIDTH(12), .DEPTH(16384), .MEMFILE("test.mem")) sram1(
//        .i_clk(p_clock),
//        .i_addr(0),
//        .i_addr_1(local_addr),
//        .i_write(0),
//        .i_data(0),
//        .o_data_1(local_data)
//        );

    distram #(.ADDR_WIDTH(19), .DATA_WIDTH(12), .DEPTH(46656), .MEMFILE("test.mem")) distram(
        .i_clk(p_clock),
        .i_addr(0),
        .i_addr_1(local_addr),
        .i_write(0),
        .i_data(0),
        .o_data_1(local_data)
        );

    
//    assign local_addr = addr_out % 640 + addr_out / 640 * 216;
//	assign data_out = (addr_out % 640 < 216) && (addr_out / 640 < 216) ? local_data : 12'h000;
    assign local_addr = y_count * 216 + x_count;
//    assign 
    
	reg FSM_state = 0;
	always@(posedge p_clock)
	begin
        if (rst)
        begin
            addr_out <= 0;
            x_count <= 0;
            y_count <= 0;
        end
        else
        begin
            if (FSM_state == 1'b0)
            begin
                FSM_state <= 1'b1;
                valid <= 1'b0;
            end
            else
            begin
                FSM_state <= 1'b0;
                addr_out <= (addr_out >= 307199) ? 19'd0 : addr_out + 1'b1;
                data_out = ((x_count < 216) && (y_count < 216)) ? local_data : 12'h000;	
                valid <= 1'b1;
                x_count <= (x_count >= 639) ? 9'b0 : x_count + 1;
                if(x_count == 639 && y_count >= 479)
                    y_count <= 0;
                else if(x_count == 639 && y_count < 479)
                    y_count <= y_count + 1;
                else
                    y_count <= y_count;
            end
        end
	end
	
endmodule
