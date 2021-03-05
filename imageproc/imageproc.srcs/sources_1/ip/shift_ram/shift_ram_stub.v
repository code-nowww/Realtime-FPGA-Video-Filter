// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
// Date        : Sat Feb 27 20:55:05 2021
// Host        : DESKTOP-7DS5362 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               E:/VIVADOcode/imageproc/imageproc.srcs/sources_1/ip/shift_ram/shift_ram_stub.v
// Design      : shift_ram
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "c_shift_ram_v12_0_13,Vivado 2019.1" *)
module shift_ram(D, CLK, CE, SCLR, Q)
/* synthesis syn_black_box black_box_pad_pin="D[11:0],CLK,CE,SCLR,Q[11:0]" */;
  input [11:0]D;
  input CLK;
  input CE;
  input SCLR;
  output [11:0]Q;
endmodule
