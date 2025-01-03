`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/13 13:58:57
// Design Name: 
// Module Name: top
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


module top(
    //Main
    input CLK, //65Mhz时钟
    input In_rst, //重置信号
    
    input rst_time,         //时间复位
    
    //温度传感器
    output temp_SCL,//传感器IIC接口
    inout temp_SDA ,//传感器IIC接口
    
    //VGA
    output vga_hs,
    output vga_vs,
    output [11:0] vga_rgb//RGB
    );
    //控制
    wire clk_whole; //全局时钟
    wire rst_whole; //全局控制
    wire locked_whole; //锁
    
    //温度传感器
    wire sda_dir;                   // direction of SDA signal - to or from master
    wire w_200kHz;                  // 200kHz SCL
    wire [15:0] w_data;              // 8 bits of temperature data
    
    //VGA
    wire [11:0] vga_data;
    wire [9:0] vga_xpos;
    wire [9:0] vga_ypos;

    //ip核分频器
    clk_wiz_0 my_clk(.clk_in1(CLK) , .clk_out1(clk_whole) , .clk_out2(w_200kHz) , .resetn(In_rst) , .locked(locked_whole));//完成
    
    //温度传感器
    wire  [7:0]read_data ;
    wire  [7:0]read_data1;
    
    temperature temp (w_200kHz , In_rst ,temp_SCL ,temp_SDA , read_data , read_data1);
    
    assign w_data = {read_data , read_data1};
       
       //作为手动与自动时间的最终输出
       wire [3:0] L_sec;
       wire [3:0] H_sec;
       wire [3:0] L_min;
       wire [3:0] H_min;
       wire [3:0] L_hour;
       wire [3:0] H_hour;    
       
       //计算时间
    clock clock_display(CLK ,rst_time , L_sec , H_sec ,  L_min , H_min ,  L_hour , H_hour);
       
    //VGA
    VGA_RGB_Control vga_control(clk_whole , In_rst , vga_data , vga_rgb , vga_hs , vga_vs , vga_xpos ,vga_ypos);
    
    //display
    display dis(clk_whole , In_rst , w_data , L_sec ,H_sec ,L_min , H_min , L_hour , H_hour  , vga_xpos , vga_ypos ,vga_data);
    
endmodule