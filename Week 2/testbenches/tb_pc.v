module tb_pc;
    reg clk, rst, inc, load;
    reg [5:0] load_val;
    wire [5:0] pc_out;
    integer fail = 0;

    pc uut(.clk(clk),.rst(rst),.inc(inc),.load(load),.load_val(load_val),.pc_out(pc_out));

    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave_pc.vcd"); $dumpvars(0,tb_pc);
        clk=0; rst=1; inc=0; load=0; load_val=0; #12;
        if(pc_out!==0) begin $display("FAIL: PC should be 0 after reset, got %0d", pc_out); fail=fail+1; end

        rst=0; inc=1; #10;
        if(pc_out!==1) begin $display("FAIL: PC should be 1 after inc, got %0d", pc_out); fail=fail+1; end
        #10;
        if(pc_out!==2) begin $display("FAIL: PC should be 2, got %0d", pc_out); fail=fail+1; end

        // Load a value
        inc=0; load=1; load_val=6'd20; #10;
        if(pc_out!==20) begin $display("FAIL: PC should be 20 after load, got %0d", pc_out); fail=fail+1; end

        // Increment from 20
        load=0; inc=1; #10;
        if(pc_out!==21) begin $display("FAIL: PC should be 21, got %0d", pc_out); fail=fail+1; end

        // Reset takes priority over inc
        rst=1; #10;
        if(pc_out!==0) begin $display("FAIL: rst should override inc, got %0d", pc_out); fail=fail+1; end

        if(fail==0) $display("PASS — all PC checks passed.");
        else        $display("FAIL — %0d check(s) failed.", fail);
        $finish;
    end
endmodule
