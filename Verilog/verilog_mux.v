/*
a.) behavioural.(saying the system is working) --->starting point.
b.) structural. (more with respect to hardware implementations).--->(gates are included here)

ex1: Structural hierarichal description of 16-1 multiplxer.

1.)using pure structural modeling.
2.)structural modeling of 4-to-1 multiplexer using behavioural model.
3.)make structural modeling of 4-to-1 multiplexer, using behavioural modeling of 2-to-1 multiplexer.
4.)make structural gate-level modeling of 2-to-1 multiplexer to have a complete structural hierarchial description

v1.)using pure behavioural modeling.
*/

module mux16to1(in,sel,out);
input [15:0]in;
input [3:0]sel;
output out;
assign out = in[sel];
endmodule;

//testbench:
module muxtest;
reg [15:0]A;
reg [3:0]S;
wire F;
mux16to1 mux_ex(.in(A),.sel(S),.out(F)); //instantiating the multiplexer.
initial //execution of begin and end only once.
begin
    $dumpfile("mux16to1.vcd"); //dumping result information to a-->{ value change dump} file(.vcd).
    $dumpvars(0,muxtest);//dumping every variable in the muxtest module. 
    $monitor($time,"A=%h , S=%h , F=%b",A,S,F);//$time is system notation,to monitor execution time.print only when there is change in value of A,S,F.
    A[15:0] = 0;S[3:0] =0;f=0;
    #5 A=16`h3f0a; S= 4`h0;
    #5 S=4`h1;
    #5 S=4`h6;
    #5 S=4`hc;
    #5 $finish;
end
endmodule

//v2.)structural modeling of 16-to-1 multiplexer using 4-to-1 multiplxer behavioural model.

module mux4to1(in,sel,out);
input [3:0]in;
input [0:1]sel;
output out;

assign out=in[sel];
endmodule

module mux16to1(in,sel,out);
input [15;0]in;
input [3:0]sel;
output out;
wire [3:0]t;

mux4to1 mux0(in[3:0],sel[1:0],t[0]);
mux4to1 mux1(in[7:4],sel[1:0],t[1]);
mux4to1 mux2(in[11:8],sel[1:0],t[2]);
mux4to1 mux3(in[15:12],sel[1:0],t[3]);
mux4to1 mux4(t,sel[3:2],out);
endmodule

//v3.) behavioral modeling of 2-to-1 mux and structural modeling of 4-to-1 mux.

module mux2to1(in,sel,out);
input [0:1]in;
input sel;
output out;

assign out = in[sel];
endmodule

module mux4to1(in,sel,out);
input [3:0]in;
input [1:0]sel
output out;
wire [1:0]t;

mux2to1 m0(in[1:0],sel[0],t[0]);
mux2to1 m1(in[2:3],sel[0],t[1]);
mux2to1 m2(t,sel[1],out);

endmodule

//v4.) structural modelling of 2-to-1 mux.

module(in,sel,out);
input [1:0]in;
input sel;
output out;
wire t1,t2,t3;
not g0(t0,sel)
and g1(t1,in[0],t0);
and g2(t2,in[1],sel);
or g3(t2,t1,t2);
endmodule
