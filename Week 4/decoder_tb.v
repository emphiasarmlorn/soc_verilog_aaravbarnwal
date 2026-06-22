`timescale 1ns/1ps

module decoder_tb;

    reg  [15:0] inst;

    wire  y0,y1,y2,y3,y4,y5,y6,y7,y8,y9,y10,y11,y12;
    wire  y13,y14,y15,y16,y17,y18,y19,y20,y21,y22;
    wire [1:0] rx, ry;

    decoder dut (
        .inst(inst),
        .y0(y0),.y1(y1),.y2(y2),.y3(y3),.y4(y4),
        .y5(y5),.y6(y6),.y7(y7),.y8(y8),.y9(y9),
        .y10(y10),.y11(y11),.y12(y12),.y13(y13),.y14(y14),
        .y15(y15),.y16(y16),.y17(y17),.y18(y18),.y19(y19),
        .y20(y20),.y21(y21),.y22(y22),
        .rx(rx),.ry(ry)
    );

    // 23-bit bus of y's
    wire [22:0] y_bus = {y22,y21,y20,y19,y18,y17,y16,y15,
                         y14,y13,y12,y11,y10,y9,y8,y7,
                         y6,y5,y4,y3,y2,y1,y0};

    integer pass_count, fail_count;

    // One-hot mask for a given y index
    function [22:0] ymask;
        input integer idx;
        begin ymask = 23'd1 << idx; end
    endfunction

    task check_instr;
        input [255:0] name;
        input integer  exp_y;
        input [1:0]    exp_rx;
        input [1:0]    exp_ry;
        begin
            #5;
            $write("  %-14s  y_bus=%023b  rx=%02b ry=%02b  ",
                    name, y_bus, rx, ry);
            if (y_bus === ymask(exp_y) &&
                rx    === exp_rx &&
                ry    === exp_ry) begin
                $display("PASS");
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL  (exp y%0d=%023b rx=%02b ry=%02b)",
                          exp_y, ymask(exp_y), exp_rx, exp_ry);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        pass_count = 0;
        fail_count = 0;
        $display("=== i281 OpCode Decoder Testbench ===");
        $display("");

        // NOOP  0000_????_????????
        inst = 16'b0000_00_00_00000000; #1;
        check_instr("NOOP", 0, 2'b00, 2'b00);

        // INPUTC  0001_??00_???????? (rx=00)
        inst = 16'b0001_01_00_00000000; #1;
        check_instr("INPUTC", 1, 2'b00, 2'b01);

        // INPUTCF  0001_??01_???????? (rx=01)
        inst = 16'b0001_10_01_00000000; #1;
        check_instr("INPUTCF", 2, 2'b01, 2'b10);

        // INPUTD  0001_??10_???????? (rx=10)
        inst = 16'b0001_11_10_00000000; #1;
        check_instr("INPUTD", 3, 2'b10, 2'b11);

        // INPUTDF  0001_??11_???????? (rx=11)
        inst = 16'b0001_00_11_00000000; #1;
        check_instr("INPUTDF", 4, 2'b11, 2'b00);

        // MOVE  0010_????_????????
        // MOVE = 0010
        inst = 16'b0010_01_00_00000000; #1;
        check_instr("MOVE", 5, 2'b00, 2'b01);

        // LOADI/LOADP  0011_????_????????
        inst = 16'b0011_01_00_00000000; #1;      // LOADI B, 0
        check_instr("LOADI B,0", 6, 2'b00, 2'b01);

        inst = 16'b0011_00_00_00000001; #1;      // LOADI A, 1
        check_instr("LOADI A,1", 6, 2'b00, 2'b00);

        // ADD  0100_????_????????
        inst = 16'b0100_01_00_00000000; #1;
        check_instr("ADD B,A", 7, 2'b00, 2'b01);

        // ADDI  0101_????_????????
        inst = 16'b0101_00_00_00000001; #1;
        check_instr("ADDI A,1", 8, 2'b00, 2'b00);

        // SUB  0110_????_????????
        inst = 16'b0110_10_01_00000000; #1;
        check_instr("SUB C,B", 9, 2'b01, 2'b10);

        // SUBI  0111_????_????????
        inst = 16'b0111_11_00_00000101; #1;
        check_instr("SUBI D,5", 10, 2'b00, 2'b11);

        // LOAD  1000_????_????????
        inst = 16'b1000_11_00_00000000; #1;
        check_instr("LOAD D,[N]", 11, 2'b00, 2'b11);

        // LOADF  1001_????_????????
        inst = 16'b1001_01_10_00000001; #1;
        check_instr("LOADF B,[arr+C]", 12, 2'b10, 2'b01);

        // STORE  1010_????_????????
        inst = 16'b1010_01_00_00000010; #1;
        check_instr("STORE [sum],B", 13, 2'b00, 2'b01);

        // STOREF  1011_????_????????
        inst = 16'b1011_10_01_00000000; #1;
        check_instr("STOREF [arr+B],C", 14, 2'b01, 2'b10);

        // SHIFTL  1100_???0_???????? (inst[8]=0)
        inst = 16'b1100_01_0_0_00000000; #1;
        check_instr("SHIFTL B", 15, 2'b00, 2'b01);

        // SHIFTR  1100_???1_???????? (inst[8]=1)
        inst = 16'b1100_11_0_1_00000000; #1;
        check_instr("SHIFTR D", 16, 2'b01, 2'b11);

        // CMP  1101_????_????????
        inst = 16'b1101_00_11_00000000; #1;
        check_instr("CMP A,D", 17, 2'b11, 2'b00);

        // JUMP  1110_????_????????
        inst = 16'b1110_00_00_11111011; #1;
        check_instr("JUMP Loop", 18, 2'b00, 2'b00);

        // BRE/BRZ  1111_??00_???????? (rx=00)
        inst = 16'b1111_01_00_00000101; #1;
        check_instr("BRE/BRZ", 19, 2'b00, 2'b01);

        // BRNE/BRNZ  1111_??01_???????? (rx=01)
        inst = 16'b1111_10_01_00000011; #1;
        check_instr("BRNE/BRNZ", 20, 2'b01, 2'b10);

        // BRG  1111_??10_???????? (rx=10)
        inst = 16'b1111_00_10_00000011; #1;
        check_instr("BRG End", 21, 2'b10, 2'b00);

        // BRGE  1111_??11_???????? (rx=11)
        inst = 16'b1111_11_11_00000111; #1;
        check_instr("BRGE", 22, 2'b11, 2'b11);

        // LOADI B, 0 = 0011_01_00_00000000
        inst = 16'b0011_01_00_00000000; #1;
        check_instr("LOADI B,0", 6, 2'b00, 2'b01);

        // LOADI A, 1 = 0011_00_00_00000001
        inst = 16'b0011_00_00_00000001; #1;
        check_instr("LOADI A,1", 6, 2'b00, 2'b00);

        // LOAD D, [N] = 1000_11_00_00000000
        inst = 16'b1000_11_00_00000000; #1;
        check_instr("LOAD D,[N]", 11, 2'b00, 2'b11);

        // CMP A, D = 1101_00_11_00000000
        inst = 16'b1101_00_11_00000000; #1;
        check_instr("CMP A,D", 17, 2'b11, 2'b00);

        // BRG End = 1111_00_10_00000011
        inst = 16'b1111_00_10_00000011; #1;
        check_instr("BRG End", 21, 2'b10, 2'b00);

        // ADD B, A = 0100_01_00_00000000
        inst = 16'b0100_01_00_00000000; #1;
        check_instr("ADD B,A", 7, 2'b00, 2'b01);

        // ADDI A, 1 = 0101_00_00_00000001
        inst = 16'b0101_00_00_00000001; #1;
        check_instr("ADDI A,1", 8, 2'b00, 2'b00);

        // JUMP Loop = 1110_00_00_11111011
        inst = 16'b1110_00_00_11111011; #1;
        check_instr("JUMP Loop", 18, 2'b00, 2'b00);

        // STORE [sum], B = 1010_01_00_00000010
        inst = 16'b1010_01_00_00000010; #1;
        check_instr("STORE [sum],B", 13, 2'b00, 2'b01);

        $display("");
        $display("==============================================");
        $display("  Results: %0d passed, %0d failed", pass_count, fail_count);
        $display("==============================================");
        if (fail_count == 0)
            $display("  ALL TESTS PASSED");
        else
            $display("  SOME TESTS FAILED");

        $finish;
    end

endmodule
