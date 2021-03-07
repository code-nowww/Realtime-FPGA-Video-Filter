-- Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
-- Date        : Sun Mar  7 11:50:33 2021
-- Host        : DESKTOP-9B3M4L5 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               f:/Data/USTC-CS-Resources/CS/Embedded-System-Design/Realtime-FPGA-Video-Filter/imageproc/imageproc.srcs/sources_1/ip/shift_ram_addr/shift_ram_addr_stub.vhdl
-- Design      : shift_ram_addr
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a100tcsg324-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity shift_ram_addr is
  Port ( 
    D : in STD_LOGIC_VECTOR ( 18 downto 0 );
    CLK : in STD_LOGIC;
    CE : in STD_LOGIC;
    SCLR : in STD_LOGIC;
    Q : out STD_LOGIC_VECTOR ( 18 downto 0 )
  );

end shift_ram_addr;

architecture stub of shift_ram_addr is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "D[18:0],CLK,CE,SCLR,Q[18:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "c_shift_ram_v12_0_13,Vivado 2019.1";
begin
end;
