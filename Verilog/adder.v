/*
v1.)behavioral description of a 16-bit adder:

generation of a status flag:

sign : whether sum is negative or positive
zero : whether sum is zero.
carry : whether is carry out of the last stage
parity : whether the sum of 1`in the sum is even or odd.
overflow : whether the sum cannot fit in 16 bits.
*/

module ALU(x,y,z,sign,zero,carry,parity,overflow);
input [15:0]x,y;
output [15:0]z;
output sign,zero,carry,parity,overflow;

assign {carry,sum} = x+y;

assign sign = z[15];//msb signifies the flag.
assign zero = ~|z;//perform nor of all the bits of the sum.
assign parity = ~^z;//perform xnor(high for even number of 1`s) of all the bits of the sum.
assign overflow = (x[15]&y[15]&~z[15])|(~x[15]&~y[15]&z[15]);
endmodule

//testbench:

module alutest
reg [15:0]x,y;
wire [15:0]z;
wire s,zr,cy,p,v;
ALU alu_test(x,y,z,s,zr,cy,p,v);
initial 
begin
    $dumpfile("alu.vcd");
    $dumpvars(0,alutest);
    $monitor($time,"x=%h,y=%h,z=%h,s=%b,zr=%b,cy=%b,p=%b,v=%b",x,y,z,s,zr,cy,p,v);
    #5 x = 16`h8fff;y = 16`h8000;
    #5 x = 16`hfffe;y = 16`h0002;
    #5 x = 16`hAAA;y = 16`h5555;
    #5 finish;
end
endmodule

//v.2) structural description of 16-bit adder using 4-bit adder(with ripple carry between blocks):
module adder4(s,cout,A,B,cin);
input [3:0]A,B;
input [3:0]s;
assign {cout,s} = A+B+cin; 
endmodule


module adder16bit(x,y,z,sign,zero,carry,parity,overflow)
input [15:0]x,y;
output [15:0]z;

output sign,zero,carry,parity,overflow;
wire c[2:0];

adder a0(z[3:0],c[1],x[3:0],y[3:0],1`b0);
adder a1(z[7:4],c[2],x[3:0],y[3:0],c[1]);
adder a2(z[11:8],c[3],x[3:0],y[3:0],c[2]);
adder a2(z[15:12],c[4],x[3:0],y[3:0],c[3]);

assign sign = z[15];//msb signifies the flag.
assign zero = ~|z;//perform nor of all the bits of the sum.
assign parity = ~^z;//perform xnor(high for even number of 1`s) of all the bits of the sum.
assign overflow = (x[15]&y[15]&~z[15])|(~x[15]&~y[15]&z[15]);
endmodule

//v3.)structural modelling of 4-bit ripple carry adder.

module adder4(x,y,cin);
input [3:0]x,y;
input cin;
output sum;
output cout
wire c1,c2,c3;

fulladder a0(sum,c1,x[0],y[0],cin);
fulladder a0(sum,c2,x[1],y[1],c1);
fulladder a0(sum,c3,x[2],y[2],c2);
fulladder a0(sum,cout,x[3],y[3],c3);
endmodule

module fulladder(sum,carry,x,y,cin)
input a,b,c;
ouptut sum, carry;
wire c1,c2,s1;
xor g1(s1,a,b);
and g3(c1,a,b);
xor g2(sum,s1,cin);
and g3(c2,s1,cin);
xor g4(carry,c1,c2);
endmodule

/*v4.)structure modeling iof lookahead adder.
1.)the propagational delay is equal to proportional to n.
2.)one possible way to speed up the addition.
>>>generate the carry signals for the various stages in parallel
>>>time complexity reduces from 0(n) to o(1).
>>>hardware complexity increases significant with n.

module adder4_lookahead(s,cout,a,b,cin)
input [3:0]a,b;
input cin;
output [3:0]s;
output cout;
wire p0,go,p1,g1,p2,g2,p3,g3;
wire c1,c2,c3;
assign p0 = a[0]^b[0];
assign g0 = a[0]&b[0];
assign p1 = a[1]^b[1];
assign g1 = a[1]&b[1];
assign p2 = a[2]^b[2];
assign g2 = a[2]&b[2];
assign p3 = a[3]^b[3];
assign g3 = a[3]&b[3];

