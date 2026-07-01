`timescale 1ns/1ps

module tb_request_fifo;

    logic clk;
    logic rst;

    logic push;
    logic pop;

    logic rw_in;
    logic [21:0] addr_in;
    logic [15:0] wdata_in;

    logic rw_out;
    logic [21:0] addr_out;
    logic [15:0] wdata_out;

    logic full;
    logic empty;

    //-------------------------------------------------
    // DUT
    //-------------------------------------------------
    request_fifo dut (
        .clk       (clk),
        .rst       (rst),

        .push      (push),
        .pop       (pop),

        .rw_in     (rw_in),
        .addr_in   (addr_in),
        .wdata_in  (wdata_in),

        .rw_out    (rw_out),
        .addr_out  (addr_out),
        .wdata_out (wdata_out),

        .full      (full),
        .empty     (empty)
    );

    //-------------------------------------------------
    // Clock
    //-------------------------------------------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    //-------------------------------------------------
    // Test Sequence
    //-------------------------------------------------
    initial begin

        rst       = 1;
        push      = 0;
        pop       = 0;
        rw_in     = 0;
        addr_in   = 0;
        wdata_in  = 0;

        //-------------------------------------------------
        // Reset
        //-------------------------------------------------
        repeat (2)
            @(posedge clk);

        rst = 0;

        //-------------------------------------------------
        // Push one request
        //-------------------------------------------------
        @(negedge clk);

        rw_in     = 1'b1;
        addr_in   = 22'h123456;
        wdata_in  = 16'hABCD;
        push      = 1'b1;

        @(posedge clk);

        #1;
        push = 1'b0;

        if (!empty)
            $display("[PASS] Push operation successful");
        else
            $fatal(1, "[FAIL] FIFO still empty");

        //-------------------------------------------------
        // Verify front entry
        //-------------------------------------------------
        if (rw_out    == 1'b1 &&
            addr_out  == 22'h123456 &&
            wdata_out == 16'hABCD)
        begin
            $display("[PASS] FIFO data verified");
        end
        else
        begin
            $fatal(
                1,
                "[FAIL] Data mismatch rw=%0b addr=%h data=%h",
                rw_out,
                addr_out,
                wdata_out
            );
        end

        //-------------------------------------------------
        // Pop request
        //-------------------------------------------------
        @(negedge clk);

        pop = 1'b1;

        @(posedge clk);

        #1;
        pop = 1'b0;

        if (empty)
            $display("[PASS] Pop operation successful");
        else
            $fatal(1, "[FAIL] FIFO not empty");

        //-------------------------------------------------
        // Done
        //-------------------------------------------------
        $display("\nAll request FIFO tests passed.\n");
        $finish;

    end

endmodule