`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/03/2026 01:14:46 AM
// Design Name: 
// Module Name: CLA_tb
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


module CLA_tb();
reg clk;
reg enable;
reg [3:0] A,B;
reg Cin;
wire [4:0] Q;
wire enable_led;
CLA_4bits CLA(.clk(clk), .enable(enable), .A(A), .B(B), .Cin(Cin), .Q(Q), .enable_led(enable_led));

initial begin
    clk = 0;
end
always #10 clk = ~clk;

initial begin
enable  = 1;
A = 4'b0000;
B = 4'b0101;
Cin = 0;
#20;

A = 4'b0101;
B = 4'b0111;
Cin = 0;
#20;

A = 4'b1000;
B = 4'b0111;
Cin = 1;
#20;

A = 4'b1001;
B = 4'b0100;
Cin = 0;
#20;

A = 4'b1000;
B = 4'b1000;
Cin = 1;
#20;

A = 4'b1101;
B = 4'b1010;
Cin = 1;
#20;

A = 4'b1110;
B = 4'b1111;
Cin = 0;
#20;

end


endmodule
