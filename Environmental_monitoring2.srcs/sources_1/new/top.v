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
    input CLK, //65Mhzʱ��
    input In_rst, //�����ź�
    
    input rst_time,         //ʱ�临λ
    
    //�¶ȴ�����
    output temp_SCL,//������IIC�ӿ�
    inout temp_SDA ,//������IIC�ӿ�
    
    //VGA
    output vga_hs,
    output vga_vs,
    output [11:0] vga_rgb//RGB
    );
    //����
    wire clk_whole; //ȫ��ʱ��
    wire rst_whole; //ȫ�ֿ���
    wire locked_whole; //��
    
    //�¶ȴ�����
    wire sda_dir;                   // direction of SDA signal - to or from master
    wire w_200kHz;                  // 200kHz SCL
    wire [15:0] w_data;              // 8 bits of temperature data
    
    //VGA
    wire [11:0] vga_data;
    wire [9:0] vga_xpos;
    wire [9:0] vga_ypos;

    //ip�˷�Ƶ��
    clk_wiz_0 my_clk(.clk_in1(CLK) , .clk_out1(clk_whole) , .clk_out2(w_200kHz) , .resetn(In_rst) , .locked(locked_whole));//���
    
    //�¶ȴ�����
    wire  [7:0]read_data ;
    wire  [7:0]read_data1;
    
    temperature temp (w_200kHz , In_rst ,temp_SCL ,temp_SDA , read_data , read_data1);
    
    assign w_data = {read_data , read_data1};
       
       //��Ϊ�ֶ����Զ�ʱ����������
       wire [3:0] L_sec;
       wire [3:0] H_sec;
       wire [3:0] L_min;
       wire [3:0] H_min;
       wire [3:0] L_hour;
       wire [3:0] H_hour;    
       
       //����ʱ��
    clock clock_display(CLK ,rst_time , L_sec , H_sec ,  L_min , H_min ,  L_hour , H_hour);
       
    //VGA
    VGA_RGB_Control vga_control(clk_whole , In_rst , vga_data , vga_rgb , vga_hs , vga_vs , vga_xpos ,vga_ypos);
    
    //display
    display dis(clk_whole , In_rst , w_data , L_sec ,H_sec ,L_min , H_min , L_hour , H_hour  , vga_xpos , vga_ypos ,vga_data);
    
endmodule