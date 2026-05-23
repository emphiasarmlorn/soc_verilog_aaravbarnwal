module mux2to1(input a, input b, input sel, output y);
    assign y = sel ? b : a;
endmodule

`timescale 1ns/1ns

module mux2to1_tb;
    reg a, b, sel;
    wire y;

    mux2to1 uut(.a(a), .b(b), .sel(sel), .y(y));

    initial begin
      $dumpfile("wave.vcd");
      $dumpvars(0, mux2to1_tb);

        a=0; b=1; sel=0; #10;  // expect y=0
        a=0; b=1; sel=1; #10;  // expect y=1
        a=1; b=0; sel=0; #10;  // expect y=1
        a=1; b=0; sel=1; #10;  // expect y=0

        $display("Done");
        $finish;
    end

    initial $monitor("t=%0t | sel=%b a=%b b=%b | y=%b", $time, sel, a, b, y);
endmodule
