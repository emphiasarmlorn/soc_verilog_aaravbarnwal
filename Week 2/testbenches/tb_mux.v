module tb_mux;
    reg [7:0] a, b, d0, d1, d2, d3;
    reg sel; reg [1:0] sel4;
    wire [7:0] y2, y4;
    integer fail = 0;

    mux2 #(.WIDTH(8)) m2(.a(a),.b(b),.sel(sel),.y(y2));
    mux4 #(.WIDTH(8)) m4(.d0(d0),.d1(d1),.d2(d2),.d3(d3),.sel(sel4),.y(y4));

    initial begin
        $dumpfile("wave_mux.vcd"); $dumpvars(0,tb_mux);

        // mux2 tests
        a=8'hAA; b=8'h55; sel=0; #10;
        if(y2!==8'hAA) begin $display("FAIL mux2 sel=0"); fail=fail+1; end
        sel=1; #10;
        if(y2!==8'h55) begin $display("FAIL mux2 sel=1"); fail=fail+1; end

        // mux4 tests
        d0=8'h11; d1=8'h22; d2=8'h33; d3=8'h44;
        sel4=2'b00; #10; if(y4!==8'h11) begin $display("FAIL mux4 sel=00"); fail=fail+1; end
        sel4=2'b01; #10; if(y4!==8'h22) begin $display("FAIL mux4 sel=01"); fail=fail+1; end
        sel4=2'b10; #10; if(y4!==8'h33) begin $display("FAIL mux4 sel=10"); fail=fail+1; end
        sel4=2'b11; #10; if(y4!==8'h44) begin $display("FAIL mux4 sel=11"); fail=fail+1; end

        if(fail==0) $display("PASS — all MUX checks passed.");
        else        $display("FAIL — %0d check(s) failed.", fail);
        $finish;
    end
endmodule
