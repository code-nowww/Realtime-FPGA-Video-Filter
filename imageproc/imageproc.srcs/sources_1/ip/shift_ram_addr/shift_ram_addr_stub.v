// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
// Date        : Sun Mar  7 11:50:33 2021
// Host        : DESKTOP-9B3M4L5 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               f:/Data/USTC-CS-Resources/CS/Embedded-System-Design/Realtime-FPGA-Video-Filter/imageproc/imageproc.srcs/sources_1/ip/shift_ram_addr/shift_ram_addr_stub.v
// Design      : shift_ram_addr
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "c_shift_ram_v12_0_13,Vivado 2019.1" *)
module shift_ram_addr(D, CLK, CE, SCLR, Q)
/* synthesis syn_black_box black_box_pad_pin="D[18:0],CLK,CE,SCLR,Q[18:0]" */;
  input [18:0]D;
  input CLK;
  input CE;
  input SCLR;
  output [18:0]Q;
endmodule
