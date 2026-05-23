module tb_alu;
    reg  [7:0] a, b;
    reg  [2:0] op;
    wire [7:0] result;
    wire       zero, carry, overflow;
    integer fail = 0;

    alu uut(.a(a),.b(b),.op(op),.result(result),.zero(zero),.carry(carry),.overflow(overflow));

    task check_result;
        input [7:0] exp_result;
        input exp_zero, exp_carry;
        begin
            if (result !== exp_result) begin
                $display("FAIL op=%b a=%h b=%h: result got %h exp %h", op,a,b,result,exp_result);
                fail = fail+1;
            end
            if (zero !== exp_zero) begin
                $display("FAIL op=%b a=%h b=%h: zero got %b exp %b", op,a,b,zero,exp_zero);
                fail = fail+1;
            end
            if (carry !== exp_carry) begin
                $display("FAIL op=%b a=%h b=%h: carry got %b exp %b", op,a,b,carry,exp_carry);
                fail = fail+1;
            end
        end
    endtask

    initial begin
        $dumpfile("wave_alu.vcd"); $dumpvars(0,tb_alu);

        // ADD
        op=3'b000; a=8'd10;  b=8'd20;  #10; check_result(8'd30,  0, 0);
        op=3'b000; a=8'd0;   b=8'd0;   #10; check_result(8'd0,   1, 0);
        op=3'b000; a=8'hFF;  b=8'h01;  #10; check_result(8'h00,  1, 1); // carry

        // SUB
        op=3'b001; a=8'd30;  b=8'd10;  #10; check_result(8'd20,  0, 0);
        op=3'b001; a=8'd10;  b=8'd10;  #10; check_result(8'd0,   1, 0);

        // AND
        op=3'b010; a=8'hFF;  b=8'h0F;  #10; check_result(8'h0F,  0, 0);

        // OR
        op=3'b011; a=8'hF0;  b=8'h0F;  #10; check_result(8'hFF,  0, 0);

        // XOR
        op=3'b100; a=8'hFF;  b=8'hFF;  #10; check_result(8'h00,  1, 0);

        // SHIFTL
        op=3'b101; a=8'b00000001; b=8'b0; #10; check_result(8'b00000010, 0, 0);
        op=3'b101; a=8'b10000000; b=8'b0; #10; check_result(8'b00000000, 1, 1);

        // SHIFTR
        op=3'b110; a=8'b10000000; b=8'b0; #10; check_result(8'b01000000, 0, 0);

        if(fail==0) $display("PASS — all ALU checks passed.");
        else        $display("FAIL — %0d check(s) failed.", fail);
        $finish;
    end
endmodule
