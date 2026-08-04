`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/03/2026 01:06:00 AM
// Design Name: 
// Module Name: look_register
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


module look_register(
input clk,
input enable,
input [4:0] data,
output reg [4:0] Q
);
always @(posedge clk) begin
if(enable)
Q<=data;
else
Q<=Q;
end
endmodule
