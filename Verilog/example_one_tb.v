`include "example.v"


module example_tb;
reg A,B,C,D,E,F;
wire Y;
example example_1(Y,A,B,C,D,E,F);

initial
begin
    $dumpfile("example_tb_one.vcd");
    $dumpvars(0, example_tb);
    $monitor($time,"A=%b,B=%b,C=%b,D=%b,E=%b,F=%b",A,B,C,D,E,F,Y);
    A=0;B=0;C=0;D=0;E=0;F=0;
    #5 A=1;B=0;C=0;D=1;E=0;F=0;
    #5 A=0;B=0;C=1;D=1;E=0;F=0;
    #5 A=1;C=0;
    #5 F=1;
    #5 $finish;
end
endmodule
