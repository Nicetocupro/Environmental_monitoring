`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/13 20:06:23
// Design Name: 
// Module Name: top_tb
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

module display_tb;

    // Inputs
    reg clk_vga;
    reg rst_n;
    reg [15:0] temp;
    reg [9:0] vga_xpos;
    reg [9:0] vga_ypos;

    // Output
    wire [11:0] vga_data;

    // ʵ����������ģ��
    display uut (
        .clk_vga(clk_vga), 
        .rst_n(rst_n), 
        .temp(temp), 
        .vga_xpos(vga_xpos), 
        .vga_ypos(vga_ypos), 
        .vga_data(vga_data)
    );

    // ʱ�����ɣ�ģ��65MHz VGAʱ�ӣ�
    initial begin
        clk_vga = 0;
        forever #7.692 clk_vga = ~clk_vga; // 65MHzʱ�ӣ�����ԼΪ15.385ns
    end

    // ģ�����
    initial begin
        // ��ʼ��
        rst_n = 0;
        temp = 0;
        vga_xpos = 0;
        vga_ypos = 0;

        // �����ź�
        #100;
        rst_n = 1;

        // ģ��VGAɨ�����
        for (int x = 0; x < 1024; x++) {
            for (int y = 0; y < 768; y++) {
                vga_xpos = x;
                vga_ypos = y;
                #7.692; // �ȴ�һ��ʱ������
            }
        }

        // ��������
        $finish;
    end
      
endmodule