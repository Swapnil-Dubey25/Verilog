module simpleAnd(f,a,b); //single level combination circuits
input a,b;
output f;
assign f = a & b; 
endmodule

module two_level(f,a,b,c,d); //2-level combination circuits
input a,b,c,d;
output f;
wire t1,t2;
assign t1 = a & b;
assign t2 = ~(c|d);//LHS updates immediately whenever the value on the RHS changes including the delay for the gate.
assign f = ~(t1 & t2); //asssign is used for behavioural design style and used to model combination circuits
endmodule

//there are 2 type variable on the LHS side 'net' and 'register'
/*
"net"
1.must be a continuously driven
2.cannot be used to store a value
3.used to model connection between continuous assignment and instantiations.
4.net represnts connection between hardware elements.
5.nets are continuous driven by the outputs of the devices they are connected to.
6.nets are 1 bit values by default unless they are declared explicitly as vectors
---->default values of a net is "z"(hign impedence).
7.wire,wor,wand,tri,supply0,supply1,etc.
8."wire" and "tri" are equivalent:when there are multiple driving thme,the driver outputs are shorted together
9."wor" and "wand" inserts an OR and AND respectively at the connection.
10."supply0" and "supply1" model power supply connections.
*/
module use_wire(f,a,b,c,d);
input a,b,c,d;
wand f;//here wire will give inderterministic result in hardware modelling.
assign f = a & b ;
assign f = c OR d ;
endmodule

module using_supply_wire(f,a,b,c,d);
input a,b,c;
output f;
supply0 gnd;
supply1 vdd;
nand g1(t1,vdd,a,b);
xor g2(t2);
and g3(t3,t1,t2);
endmodule

/*
value elevel:
0 logic 0 state
1 logic 1 state
x Unknown logic state(all register variable set to "x")
z high impedence state(all unconnected states are set to "Z")


strength - type          ^
supply - driving         |
strong - driving         |
pull -   driving         |
large -  storage         | strength increases
weak -   driving         |
medium - storage         |
small -  storage         |
highz -  high impedence  |

1.if 2 signals of unequal strngth set driven on a wire,the stronger signal will prevail.
2.these are particularly useful for mos level circuits,e.g. dynamic mos.

---------------------------------------------------------------------------------------

"register"

1.retains the last value assigned to it.
2.often used to represnt storage element,but sometimes it can translate to combinations circuits.
3.In verilog "register" is available which can hold a value.
4.unlike a"net that is continuosly driven and cannot hold avalue
5.doesnot necessary means that it will map to a hardware register during synthesis.
6.combination circuits specifications can also use register type variable.

-->>types of register used in verilog:

1.reg : most widly used register
2.integer : used for loop counting(typically used)
3.real : used t store floating point numbers
4.time : keep track of simulation time(not used for synthesis).
--------------------------------------------------------------------------------------
1.) "reg" data type:

>> default value of  reg data type is "x"
>> it can be assigned a value in synchronism with a clock or even otherwise
>> the declaration explicitly specifies the size (defaut is 1 bit)
 

reg x,y; //single register variables
reg[15:0] bus; // A 16-bit bus of reg datatype


>> treated as an unsigned number in arithmetic expressions
>> must be used when we model sequential hardware elements like counters,shift registers, etc.
*/

//code of 32 bit counter with synchronous reset.

//it count increases at the positive edge of the clock.
//if rst is high then the counter is reset at the positive edge of the clock.

//synchronous reset.
module simple_counter(clk,rst,count);
input clk,rst;
output[31:0] count; //it is 32 bit counter
reg[31:0] count; //since LHS Should always be a reg type so we have to declare count a reg type.
always @(posedge clk) //always at the positive edge of the clock
begin
    if(rst)
    count =32'b0; //LHS should always be a "reg" type as we declared above.
    else 
    count =count +1;
end
endmodule

//typical example of asynchronous reset.
module simple_counters(clk,rst,count);
input clk,rst;
output[31:0] count; //it is 32 bit counter
reg[31:0] count; //since LHS Should always be a reg type so we have to declare count a reg type.
always @(posedge clk  or posedge rst) //always at the positive edge of the clock or at postive edge of reset.
begin
    if(rst)
    count =32'b0; //LHS should always be a "reg" type as we declared above.
    else 
    count =count +1;
end
endmodule
/*
--------------------------------------------------------------------------

2.) "integer" data type:

>> it is a general-purpose register datatype used for manipulating quantities.
>> more convenient to use in situations like loop counting rhan "reg".
>> it is trated as a 2's complement signed interger in arithmetic expression.
>> default size is 32-bits,however the synthesis tries to determine the size using data flow analysis.
ex:
wire[15:0] x,y;
integer z;
z= x+y;
size of z can be deduced to be a 17(16its plus a carry).

-------------------------------------------------------------------------

3.)"real" datatype

>>used to store floating-point numbers
>>when a real value is assigned to an integer,the real number is rounded off to the nearest integer
ex:

real e,pi;                 
initial                       
begin  
    e = 2.718;
    pi =314.159e-2;
end

integer x;
initial
x=pi; this will get value 3

--------------------------------------------------------------------------

4.)"time" data type:

in verilog simulation is carried out with respect to a logical clock called simulation time.
the "time" datatype can be used to store simulation time.
the system functioin "$time" gives th current simulation time.
ex:
time curr_time;
initial
--
--
curr_time = $time;

-----------------------------------------------------------------------------------

"vectors":

>>nets or reg type variables can be declared as vectors of multiple bit widths
---if bit width is not specified,default size is 1-bits
>>vectors are declared by specifying a range [range1:range2],where range1 is always the most significant bit and range 2 is least significant  bits
ex:
wire x,y,z;
wire[7:0] sum;  here msb is sum[7] and lsb is sum[0]
reg[31:0] MDR;
reg[1:10] data; here msb is data[1] and lsb is data[10]
reg clock;

>>part of a vector can be addressed and used in an expression
ex:
a 32 bit instruction register,that contains a 6-bit opcode ,threee register operands of 5 bits each, and an 11-bit offset.

reg[31:0] IR;  
reg[5:0] opcode;
reg[4:0] reg1,reg2,reg3;
reg[10:0] offset;

or(Using IR register and  part of vectors for addressing different regsiters )

reg[31:0] IR; 
opcode =IR[31:26];
reg1 = IR[25:21];
reg2 = IR[20:16];
reg3 = IR[15:11];
offset = IR[0:10];
--------------------------------------------------------------------------

Multi-dimentional array and memories:

ex:
reg[31:0] register_bank[15:0];  >> 16 32-bit register
integer matrix[7:0][15:0];

>>>>>Momories can be modeled in verilog in 1-d array of regiaters
-->each element of an array can be addressed by a single array index
ex:
reg mem_bit[0:2047]; >>2k words and each word is 1-bit words
reg[15:0] mem_word[0:1023];  >>1k words and each word is 16-bit words
---------------------------------------------------------------------------

specifying constant values:

a constant values may be specified either the size of the unsized form
syntax:
<size>'<base><number>
ex:
4'b0101
1'b0
12'hB3C
12'h8xF
25
----------------------------------------------------------------------------

"parameters"(use to define a valriable to a value)

 A Parameter is a constant with a given name.
 >> we cannot specify the size of the parameter
 >>the size os being specifed by the constant value itself:it not specified it is taken to be 32 bits.
 ex:
 parameter HI=25,LO=25;
 parameter up =2b'00,down =2b'01,steady =2b'10;
 parameter red =3b'100,yellow = 3b'101, green =3b'001;

*/

//parametrized design::an N bit counter.

module counter(clear,clock,count);
parameter N=7; //we can easily manipulate value to N to design the type of counter desired.
input clear,clock;
output [0:N]count;
reg [0:N]count;
always @(negedge clock)
begin
    if(clear)
    count<=0;
    else
    count<=count+1;
end
endmodule
/*
--------------------------------------------------------------------------------
/*
predefined logic gates in verilog:

verilog provides predefined logic gates.
-->>can be instantiated with a module to create a structural design.
--->> the gates responds to logic values(0,1,,x,z) in a logical way. 
"2-input AND"
0&0=0
0&1=0
1&1=1
1&X=X
0&X=0
1&Z=X
0&Z=X

"2-input OR"
0|0=0
0|1=1
1|1=1
1|X=1
0|X=X
1|Z=X
0|Z=X

"2-input XOR"
0^0=0
0^1=1
1^1=0
1^X=X
0^X=X
1^Z=X
0^Z=X

"LIST OF PRIMITIVES GATES"

and g(out,in1,in2);
nand g(out,in1,in2);
or g(out,in1,in2);
nor g(out,in1,in2);
xor g(out,in1,in2);
xnor g(out,in1,in2);
not g(out,in);
buf g(out,in);

there are few with tristate controls.
bufif1 g(out,in,ctrl);
bufif0 g(out,in,ctrl);
notif1 g(out,in,ctrl);
notif0 g(out,in,ctrl);

--->>some restrictions when instantiating primative gates.

1.)the output port must be a connected to "net"(eg. a wire).
2.)the output signal is a wire by default, explicitly declared a register
3.)the input may be connected to nets or register type variable
4.)they have a single output but can have many inputs(expect not and buffer)
5.)when instatiating a gate an optional delay may be specified.(used for simulation,logic synthesis tools ignore the delays)

ex(for dalays):

module exclusive_or(f,a,b)
input a,b;
ouptut f;
wor t1;
wire t3,t2;
nand #5 m1(t1,a,b);
and #5 m2(t2,a,t1);
and #5 m3(t3,t1,b);
nor #5 m4(f,t2,t3);
end module.
-------------------------------------------------------------------------

"the `timescale directive"

1.)often in a single module,a delay value in one module need to be specified in terms
of some time unit,while those in some other module need to be specified in terms of some other time unit.
3.)the `timesccale directive can be used.
syntax:
`timescale <reference_time_unit>/<time precision>

4.)<reference_time_unit> specifies the unit of measurement for time.
5.)<time precision> specifies the precision to which the delays are rounded off during simulations(means th time period upto which simulation is accurate).
---->>valid values for specifying time unit and time precision are 1,10,100.
ex:
`timescale 10ns/1ns.
>> reference time unit is 10ns and simulation time is 1 ns.
>> if we specify #5 as delay, it means in actual it is 50ns delay
>> the time units can be specified in ns(nanosec),s(sec),ms(millisec),us(microsec),ps(picosec) and fs(femtosec).
-----------------------------------------------------------------------------
"specifying connectivity of module within other module."

>> when a module is instantiated within another module,there are two ways
to specify the connectivity of the signals lines  between the two modules.

a) positional association:

>> the parameters of the module being instantiated are listed in the same order as the original module description.
*/
module example(A,B,C,D,E,F,Y);
wire t1,t2,t3,Y;
nand #1 g1(t1,A,B);
and #2 g2(t2,C,~B,D);
or #1 g3(t3,E,F);
nand #1 g4(Y,t1,t2,t3);
endmodule

//"testbench":

module testbench;
reg x1,x2,x3,x4,x5,x6,out;
example DUT(x1,x2,x3,x4,x5,x6,out); //instatiating module "example" in module "testbench".--->>IMPLICITLY.
initial
begin
    $monitor($time,"x1=%b,x2=%b,x3=%b,x4=%b,x5=%b,x6=%b",x1,x2,x3,x4,x5,x6,out);
    x1=0;x2=0;x3=0;x4=0;x5=0;x6=0;
    #5 x1=1;x2=0,x3=0,x4=1,x5=0,x6=0;
    #5 x1=0;x3=1;
    #5 x1=1;x3=0;
    #5 x6=1;
    #$finish;
end
endmodule

/*
b.)explicit association:

>> the parameters of the module being instantiated are listed in arbitary order
>> the chances of errors are less
*/
module example(A,B,C,D,E,F,Y);
wire t1,t2,t3,Y;
nand #1 g1(t1,A,B);
and #2 g2(t2,C,~B,D);
or #1 g3(t3,E,F);
nand #1 g4(Y,t1,t2,t3);
endmodule

//"testbench":

module testbench;
reg x1,x2,x3,x4,x5,x6,out;
example DUT(.out(Y),.x1(A),.x2(B),.x3(C),.x4(D),.x5(E),.x6(F)); //instatiating module "example" in module "testbench".-->>EXPLICITLY
initial
begin
    $monitor($time,"x1=%b,x2=%b,x3=%b,x4=%b,x5=%b,x6=%b",x1,x2,x3,x4,x5,x6,out);
    x1=0;x2=0;x3=0;x4=0;x5=0;x6=0;
    #5 x1=1;x2=0,x3=0,x4=1,x5=0,x6=0;
    #5 x1=0;x3=1;
    #5 x1=1;x3=0;
    #5 x6=1;
    # $finish;
end
endmodule
/*
----------------------------------------------------------------------------------------------

 "HARDWARE MODELING ISSUES"
>>>>> In terms of hardware modeling reliazation,the value computed xan be assigned to:
-"wire"
-"flip-flop"(edge triggered storage cell).
-"latch"(level triggered storage cell).
>>>>> A variable in verilof can either be "wire" or a "register".
-a "net" datatype can be either a "net" or "register".
-A "register" datatype maps either toa "wire" or a "storage cell" depending upon the context under which a value is assigned.

("register can be mapped to wire or storage cell")
*/
//(ex.1)
module reg_maps_to_wire(A,B,F1,F2);
input A,B,C;
output F1,F2;
wire A,B,C;
reg ; F1,F2; 
always @(A or B or C)
begin
    F1 = ~(A & B);//the synthesis system will generate a wire for F1 and F2 both
    F2 = F1^C;
end
endmodule
    
//(ex.2)
module reg_maps_to_wire(A,B,F1,F2);
input A,B,C;
output F1,F2;
wire A,B,C;
reg ; F1,F2; 
always @(A or B or C)
begin
    F2 = F1^F2; //F2 should always be "reg" datatype as value if F2 needed to be stored as latch  and during synthesis it will treated as a "gister" only
    F1 = ~(A & B); //F1 can be declared as a "wire" or "reg" datatype , but during synthesis it will treated as a "wire" only.
    
end
endmodule

//A LATCH GET INFERRED HERE:

module simple_latch(data,load,d_out);
input data,load;
output d_out;
wire t;
always @(load or data)
begin
    if(!load)
    t= data;// the else oart is missing.so a latch will be generated for "t"
    dout = !it;
end
endmodule
/*
--------------------------------------------------------------------------------------------------------------------
"various operators in verilog:"

1.)Arithmertic operators:

a.)Unary operators(+,-)
+A,-A,-(A+B).
b.)Binary operaters(+,-,**,*,/,%)
A+B,A-B,A**3.
----------------------------------------------------------------------
2.)Logical opeartors:

(!(not),&&(and),||(or))
the value 0 is treated as false whiel an non zero is treated as true 
logical operators are either 0 or 1.
-----------------------------------------------------------------------
3.)Relational operators:

(!=,==,>=,>,<)
relational operators operate on numbers and return a booloean value(true or false).
-------------------------------------------------------------------------
4.)Bitwise operartors:(used mostly along with "assign" )

~ bitwise NOT
& bitwise AND
| bitwise OR
^ bitwise XOR(high for odd numvber of 1`s)
~^ bitwise xNOR(high for even numvber of 1`s)
----------------------------------------------------------------------------
5.)Reduction operators :(Unary operator)--->>models a gate with multiple input and produce single outptut

& bitwise AND
| bitwise OR
~& bitwise NAND
~| bitwise NOR
^ bitwise XOR
~^ bitwise XNOR

It Accepts a single word operand and produce single bit as output.

ex:
wire[3:0],a,b,c;
assign a = 4b`0111;
assign b= 4b`1100;
assign c= 4`b0100;
assign f1 = ^a; --->OUTPUT = 1
assign f2 =&(a^b);---->OUTPUT = 0
assign f3 = ^a & ~^b; ----->OUTPUT = 1;

------------------------------------------------------------------------------

6.)SHIFT OPERATORS:(shift right(divide by 2),shift left(multiply by 2))

<< -->shift right(insert 0 to the right with each shift)
>> --->shift left(insert 0 to the left wit each shift)
>>> -->arithmetic shift right(shift the MSB bit again and again )

ex:
wire[15:0] data,target;
assign target = target>>3;
assign target =target>>>2;

------------------------------------------------------------------------------
7.) conditional shift:
syntax:cond_exp ? true_exp:fal_exp;

ex:
wire a,b,c,x,y,z;
wire[7;0] x,y,z;
assign a = (b>c) ? b : c ;
assign z = (x==y) ? x+2 : x-2;

------------------------------------------------------------------------------
8.) concatenation operators and replication operators:

concatenation operators: joins together bit from two or more comma-seperated expression.
ex:
{....,...,....}
replication operatos: joins together n copies of an expression m ,where n is constant.
ex:
{n{m}}

ex:
assign f ={a,b};
assign f  = {a,3`b101,b};
assign f ={x[2],y[0],a};
assign f ={2`b10,3{3`b110},x};
-------------------------------------------------------------------------------

ex1.)
module operator_example(x,y,f1,f2);
input x,y;
output f1,f2;
wire[9:0]x,y;
wire[4:0] f1;
wire f2;
assign f1 = x[4:0] & y[4:0]; 
assign f2 = x[2] | ~f1[3];
assign f3 = ~& x;
assign f1  = f2  ? x[9:5] : x[4:0];
endmodule

--------------------------------------------------------------------------------
behavioural description of a 8-bit adder:
*/
module parallel_adder(sum,carry,cin,in1,in2);
input [7:0]in1,[7:0]in2;
input cin;
output carry;
output [7:0]sum;
assign #20{carry,sum} = in1 + in2 +cin;
endmodule
/*
--------------------------------------------------------------------------------

operators precedence:(all operators associate are left to right in a expression,except ?: )

decresing order of precedence
+,-!~
**
*,/,%
<< >> >>>
< <= > >=
== , != , === , !==(== , !=  :they are used to check equality and  === , !== :they are used to check exact equality)
& ~&
^ ~^
| ~|
&&
||              
?:
----------------------------------------------------------------------------------
some points:

1.)the presence of x and z in a reg and wire being used in an arithmetic expression results in while expression bing unknow
2.)The logical operatoes (!,&&,||) all evaluate toa 1-bit result.
3.)the relational operators (>,<,<=,>=,~=,==) also evaluate to a 1-bit result(0 or 1).
4.) boolean false is equiavant to 1`b0 and the boolean true is equivant to 1`b1.

--------------------------------------------------------------------------------









