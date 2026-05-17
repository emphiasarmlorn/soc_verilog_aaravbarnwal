# Week 1 — Verilog Basics

## Objective
Get comfortable writing, simulating, and verifying Verilog code.
By the end of this week you should be able to write any combinational
or simple sequential circuit in both structural and behavioral style,
and verify it with a testbench.

---

## Concepts to Cover

### 1. What is Verilog?
Verilog is a Hardware Description Language (HDL). Unlike a programming
language where code describes *what a CPU should compute*, Verilog
describes *what hardware should exist and how it should be connected*.
Two things to internalize early:
- Verilog describes circuits, not a list of commands. Most of it runs
  "concurrently", not line by line.
- The distinction between simulation and synthesis matters. Some
  constructs are valid for simulation only (like `$display`).

### 2. Structural Modeling
Describes hardware by "instantiating" primitive gates or sub-modules
and wiring them together. Think of it as drawing a schematic, but in code.

```verilog
module and2(input a, input b, output y);
    and(y, a, b);
endmodule

module structural_mux(input a, input b, input sel, output y);
    wire na, sel_a, sel_b;
    not(na, sel);
    and(sel_a, a, na);
    and(sel_b, b, sel);
    or(y, sel_a, sel_b);
endmodule
```

<img width="1024" height="559" alt="image" src="https://github.com/user-attachments/assets/3248568e-1995-4d7c-b9da-b2eab58172b9" />


Key constructs: `module`, `endmodule`, `wire`, `input`, `output`,
primitive gates (`and`, `or`, `not`, `nand`, `nor`, `xor`),
module instantiation with named ports.

### 3. Behavioral Modeling
Describe *what* the circuit does, not *how* it is built.
In this style of describing a circuit, we use something called a process block(always @() begin end).
Inside this block, the statements are executed sequentially, like a normal computer program, but you have to keep in mind that you are describing an actual circuit and not something abstract.

```verilog
module behavioral_mux(input a, input b, input sel, output reg y);
    always @(*) begin
        if (sel)
            y = b;
        else
            y = a;
    end
endmodule
```

Key constructs: `always @(*)` for combinational logic,
`always @(posedge clk)` for sequential logic, `reg`, `begin/end`,
`if/else`, `case`.

Note the fact that we used 'output reg' and not 'output'.Declaring something as output defaults it to wire, but a variable that changes inside an always block must always be of type reg.
This distinction between reg and wire arose historically as Verilog was being developed, and it doesn't have any deep physical reason. 

### 4. Dataflow Modeling
Use `assign` statements with expressions. Good for simple combinational logic.

```verilog
module dataflow_mux1(input a, input b, input sel, output y);
    assign y = sel ? b : a;
endmodule

module dataflow_mux2(input a, input b, input sel, output y);
    assign y = ((~sel)&a)|(sel&b);
endmodule
```
Both of the above architectures are functionally the same

### 5. Testbenches
A testbench instantiates your module, drives its inputs, and checks outputs.
It can physically be thought of as a bigger circuit inside which the circuit of interest sits.

<img width="730" height="250" alt="image" src="https://github.com/user-attachments/assets/efaa2643-7503-4f22-ab86-25430284b60c" />


```verilog
module tb_mux;
    reg a, b, sel;
    wire y;

    behavioral_mux uut(.a(a), .b(b), .sel(sel), .y(y));

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_mux);

        a=0; b=1; sel=0; #10;  // expect y=0
        a=0; b=1; sel=1; #10;  // expect y=1
        a=1; b=0; sel=0; #10;  // expect y=1
        a=1; b=0; sel=1; #10;  // expect y=0

        $display("Done");
        $finish;
    end

    initial $monitor("t=%0t | sel=%b a=%b b=%b | y=%b", $time, sel, a, b, y);
endmodule
```
The method used above becomes cumbersome if you want to check many(or all) input combinations.
So, instead of manually writing each input, you can treat a,b, and sel as one number and use a for loop to go through all possible inputs

```verilog
module tb_mux;
    reg a, b, sel;
    wire y;

    // 1. Declare a loop variable (integer is standard for testbenches)
    integer i;

    behavioral_mux uut(.a(a), .b(b), .sel(sel), .y(y));

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_mux);

        // 2. Loop through all 8 combinations (0 to 7)
        for (i = 0; i < 8; i = i + 1) begin
            // 3. Slice the integer bits directly into your input registers
            {sel, a, b} = i; 
            #10;  // Wait 10 time units for each combination
        end

        $display("Done");
        $finish;
    end

    initial $monitor("t=%0t | sel=%b a=%b b=%b | y=%b", $time, sel, a, b, y);
endmodule
```

### 6. D Flip-Flop (intro to sequential logic)

```verilog
module dff(
    input clk, rst, d,
    output reg q
);
    always @(posedge clk) begin
        if (rst) q <= 0;
        else     q <= d;
    end
endmodule
```

Critical rule: Use `<=` (non-blocking, i.e., the variables are updated when they hit 'end') in clocked blocks.
Use `=` (blocking, i.e., the variables are updated then and there) in combinational always blocks.
Getting this wrong causes subtle, hard-to-debug race conditions.

---

## Textbook Reference (Brown & Vranesic, 3rd Ed.)

| Topic                          | Section      |
|-------------------------------|--------------|
| Logic gates and Boolean algebra| Ch. 2, §2.1–2.7  |
| First look at Verilog          | Ch. 2, §2.10     |
| Structural Verilog             | Ch. 2, §2.10.1   |
| Behavioral Verilog             | Ch. 2, §2.10.2   |
| Hierarchical design            | Ch. 2, §2.10.3   |
| How NOT to write Verilog       | Ch. 2, §2.10.4 ← read this |
| Flip-flops and registers       | Ch. 5, §5.1–5.3  |

Also, have a look at the Verilog cheat sheet in /resources.

---

## YT references
https://www.youtube.com/@hardwaremodelingusingveril2747/videos

---

## Tool Setup

```bash
# Ubuntu/Debian
sudo apt install iverilog gtkwave

# macOS
brew install icarus-verilog gtkwave

# Compile and simulate
iverilog mux_with_testbench.v
vvp a.out

# View waveforms
gtkwave wave.vcd
```

---

## Exercises

Work through the exercises in exercises/ in order.

Also, the problems on HDLBits will prove to be a good warmup!
https://hdlbits.01xz.net/wiki/Problem_sets

Stop before **Circuits** — that section overlaps with Week 2 and
you will get more out of it by building those circuits yourself
---
