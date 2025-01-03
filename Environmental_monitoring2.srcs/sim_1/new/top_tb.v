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

    // 实例化被测试模块
    display uut (
        .clk_vga(clk_vga), 
        .rst_n(rst_n), 
        .temp(temp), 
        .vga_xpos(vga_xpos), 
        .vga_ypos(vga_ypos), 
        .vga_data(vga_data)
    );

    // 时钟生成（模拟65MHz VGA时钟）
    initial begin
        clk_vga = 0;
        forever #7.692 clk_vga = ~clk_vga; // 65MHz时钟，周期约为15.385ns
    end

    // 模拟测试
    initial begin
        // 初始化
        rst_n = 0;
        temp = 0;
        vga_xpos = 0;
        vga_ypos = 0;

        // 重置信号
        #100;
        rst_n = 1;

        // 模拟VGA扫描过程
        for (int x = 0; x < 1024; x++) {
            for (int y = 0; y < 768; y++) {
                vga_xpos = x;
                vga_ypos = y;
                #7.692; // 等待一个时钟周期
            }
        }

        // 结束测试
        $finish;
    end
      
endmodule