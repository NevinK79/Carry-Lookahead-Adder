`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/03/2026 01:00:25 AM
// Design Name: 
// Module Name: CLA_4bits
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


module CLA_4bits(
input clk,
input enable,
input [3:0] A,B,
input Cin,
output [4:0] Q,
output enable_led
);

wire [3:0] G,P,S;
wire [4:0] C;
wire [3:0] Sum;
wire Cout;
wire [4:0] data;

assign P = A^B;
assign G = A&B;

assign C[0] = Cin;
assign C[1] = G[0] | (P[0] &C[0]);
assign C[2] = G[1] | (P[1] & G[0]) |(P[1] & P[0] & C[0]);
assign C[3] = G[2] | (P[2] & G[1]) | (P[2] &P[1] &G[0]) | (P[2] &P[1] & P[0] &C[0]);
assign C[4] = G[3] | (P[3] & G[2])| (P[3] & P[2] & G[1]) | (P[3] &P[2] &P[1] &G[0]) |(P[3] & P[2] &P[1] &P[0] &C[0]);

assign Sum = P ^C[3:0];
assign Cout = C[4];
assign data = {Cout, Sum};
assign enable_led = enable;
look_register register_logic(.clk(clk), .data(data),.Q(Q), .enable(enable));
endmodule
