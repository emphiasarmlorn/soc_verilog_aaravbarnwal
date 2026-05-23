module tb_regfile;
    reg clk, we;
    reg [1:0] raddr0, raddr1, waddr;
    reg [7:0] wdata;
    wire [7:0] rdata0, rdata1;
    integer fail = 0;

    regfile uut(.clk(clk),.we(we),.raddr0(raddr0),.raddr1(raddr1),
                .waddr(waddr),.wdata(wdata),.rdata0(rdata0),.rdata1(rdata1));

    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave_regfile.vcd"); $dumpvars(0,tb_regfile);
        clk=0; we=0;

        // Write 0xAA to register A (00)
        we=1; waddr=2'b00; wdata=8'hAA; #10;
        // Write 0xBB to register B (01)
        waddr=2'b01; wdata=8'hBB; #10;
        // Write 0xCC to register C (10)
        waddr=2'b10; wdata=8'hCC; #10;
        we=0;

        // Read A and B simultaneously
        raddr0=2'b00; raddr1=2'b01; #2;
        if(rdata0!==8'hAA) begin $display("FAIL: reg A=%h exp AA", rdata0); fail=fail+1; end
        if(rdata1!==8'hBB) begin $display("FAIL: reg B=%h exp BB", rdata1); fail=fail+1; end

        // Read C and B
        raddr0=2'b10; raddr1=2'b01; #2;
        if(rdata0!==8'hCC) begin $display("FAIL: reg C=%h exp CC", rdata0); fail=fail+1; end

        // Write disable — D should still be 0
        raddr0=2'b11; #2;
        if(rdata0!==8'h00) begin $display("FAIL: reg D=%h exp 00 (unwritten)", rdata0); fail=fail+1; end

        if(fail==0) $display("PASS — all register file checks passed.");
        else        $display("FAIL — %0d check(s) failed.", fail);
        $finish;
    end
endmodule
