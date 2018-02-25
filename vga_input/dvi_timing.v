`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Wenting Zhang
// 
// Create Date:    18:10:40 02/05/2018 
// Design Name: 
// Module Name:    dvi_timing 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module dvi_timing(
    input clk,
    input rst,
    output reg hs,
    output reg vs,
    input vsi,
    output [10:0] x,
    output [10:0] y,
    output [7:0] gb_x,
    output [7:0] gb_y,
    output gb_en,
    output enable,
    output [19:0] address
    );

//ˮƽ
parameter H_FRONT = 16; //ǰ��
parameter H_SYNC  = 96; //ͬ��
parameter H_BACK  = 48; //���
parameter H_ACT   = 640;//��Ч����
parameter H_BLANK = H_FRONT+H_SYNC+H_BACK; //�ܿհ�
parameter H_TOTAL = H_FRONT+H_SYNC+H_BACK+H_ACT; //���г�

//��ֱ
parameter V_FRONT = 9;  //ǰ�� 
parameter V_SYNC  = 2;  //ͬ��
parameter V_BACK  = 30; //���
parameter V_ACT   = 480;//��Ч����
parameter V_BLANK = V_FRONT+V_SYNC+V_BACK; //�ܿհ�
parameter V_TOTAL = V_FRONT+V_SYNC+V_BACK+V_ACT; //�ܳ���

reg [10:0] h_count;
reg [10:0] v_count;

reg [2:0] h_div;
reg [2:0] v_div;

reg [7:0] gb_x_count;
reg [7:0] gb_y_count;

always @(posedge clk or posedge rst)
begin
  if(rst)
  begin
    h_count <= 0;
    h_div <= 0;
    gb_x_count <= 0;
    hs <= 1;
  end
  else
  begin
    if(h_count < H_TOTAL) begin
      h_count <= h_count + 1'b1;
      if (h_div == 2'b10) begin
        h_div <= 2'b00;
        gb_x_count <= gb_x_count + 1'b1;
      end
      else begin
        h_div <= h_div + 1'b1;
      end
    end else begin
      h_count <= 0;
      gb_x_count <= 0;
      h_div <= 2'b00;
    end
    if(h_count == H_FRONT - 1)
      hs <= 1'b0;
    if(h_count == H_FRONT + H_SYNC - 1)
      hs <= 1'b1;
  end 
end

always@(posedge hs or posedge rst)
begin
  if(rst)
  begin
    v_count <= 0;
    v_div <= 0;
    gb_y_count <= 0;
    vs <= 1;
  end
  else
  begin
    if(v_count < V_TOTAL) begin
      v_count <= v_count + 1'b1;
      if (v_div == 2'b10) begin
        v_div <= 2'b00;
        gb_y_count <= gb_y_count + 1'b1;
      end
      else begin
        v_div <= v_div + 1'b1;
      end
    end else begin
      v_count <= 0;
      gb_y_count <= 0;
      v_div <= 2'b01;
    end
    if((v_count >= V_FRONT - 1))
      vs <= 1'b0;
    if((v_count >= V_FRONT + V_SYNC - 1))
      vs <= 1'b1;
  end
end

assign x = (h_count >= H_BLANK) ? (h_count - H_BLANK) : 11'h0;
assign y = (v_count >= V_BLANK) ? (v_count - V_BLANK) : 11'h0;
assign gb_en = (x >= 11'd80)&&(x < 11'd560)&&(y >= 11'd24)&&(y <= 11'd456);
assign gb_x = (gb_en) ? (gb_x_count - 8'd80) : (8'h0);
assign gb_y = (gb_en) ? (gb_y_count - 8'd23) : (8'h0);
assign address = y * H_ACT + x;
assign enable = (((h_count > H_BLANK + 1) && (h_count <= H_TOTAL + 1))&&
                 ((v_count >= V_BLANK) && (v_count < V_TOTAL)));  //One pixel shift


endmodule
