`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/13 13:59:49
// Design Name: 
// Module Name: VGA_RGB_Control
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

module VGA_RGB_Control
(  	
        input            clk_vga,    // VGA时钟信号
        input            rst_n,         // 复位信号
        input    [11:0]    vga_data,   //未经处理的RGB信号
        output    [11:0]    vga_rgb,    // 处理后的RGB信号
        output    reg        vga_hs,        // VGA水平同步信号
        output    reg        vga_vs,        // VGA竖直同步新哈
        output    [9:0]    vga_xpos,    // 下一个x值
        output    [9:0]    vga_ypos    // 下一个y值
    );    
    
        parameter	H_DISP 	=	11'd1024;
        parameter    H_FRONT    =    11'd24;     
        parameter    H_SYNC     =    11'd136;  
        parameter    H_BACK     =    11'd160;   
        parameter    H_TOTAL    =    11'd1344; 
        // Virtical Parameter    ( Line ) 
        parameter    V_DISP     =    10'd768;                      
        parameter    V_FRONT    =    10'd3;   
        parameter    V_SYNC     =    10'd6;    
        parameter    V_BACK     =    10'd29;   
        parameter    V_TOTAL    =    10'd806;  
    //------------------------------------------
    // 
    reg [10:0] h_counter;  //水平计数器
    always @ (posedge clk_vga or negedge rst_n)
    begin
        if (!rst_n)
            h_counter <= 0;
        else
            begin
            if (h_counter < H_TOTAL-1'b1)            
                h_counter <= h_counter + 1'b1;
            else
                h_counter <= 0;
            end
    end 
    
    always@(posedge clk_vga or negedge rst_n)
    begin
        if(!rst_n)
            vga_hs <= 1;
        else
            begin
            if( (h_counter >= H_DISP+H_FRONT-1'b1) && (h_counter < H_DISP+H_FRONT+H_SYNC-1'b1) )
                vga_hs <= 0;       
            else
                vga_hs <= 1;
            end
    end
    
    //------------------------------------------
    // 
    reg [9:0] v_conter;//垂直计数器
    always @ (posedge clk_vga or negedge rst_n)
    begin
        if (!rst_n)
            v_conter <= 0;
        else
            begin
            if(h_counter == H_DISP-1)
                begin
                if (v_conter < V_TOTAL-1'b1)            
                    v_conter <= v_conter+1'b1;
                else
                    v_conter <= 0;   
                end 
            else
                v_conter <= v_conter;
            end
    end
    
    always @ (posedge clk_vga or negedge rst_n) 
    begin
        if(!rst_n)
            vga_vs <= 1;
        else
            begin
            if( (v_conter >= V_DISP+V_FRONT-1'b1) && (v_conter < V_DISP+V_FRONT+V_SYNC-1'b1) )
                vga_vs <= 0;        
            else
                vga_vs <= 1;        
            end
    end
    
    //------------------------------------------
    //像素坐标与RGB信号生成
    
    assign    vga_xpos = (h_counter < H_DISP) ? (h_counter[9:0]+1'b1) : 10'd0;
    assign    vga_ypos = (v_conter < V_DISP) ? (v_conter[9:0]+1'b1) : 10'd0;
    assign    vga_rgb     =     ((h_counter < H_DISP) && (v_conter < V_DISP)) ? vga_data : 12'd0;
    
endmodule