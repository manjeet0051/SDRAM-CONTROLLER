`timescale 1ns/1ps

module tb_init_fsm;

    logic clk;
    logic rst;
    logic timer_done;

    logic [2:0] cmd;
    logic timer_start;
    logic [7:0] timer_cycles;
    logic init_done;

    init_fsm dut
    (
        .clk(clk),
        .rst(rst),
        .timer_done(timer_done),
        .cmd(cmd),
        .timer_start(timer_start),
        .timer_cycles(timer_cycles),
        .init_done(init_done)
    );

    
    // Clock
    initial
    begin
        clk = 0;
        forever #5 clk = ~clk;
    end


    // Monitor
    initial
    begin
        $monitor(
            "t=%0t cmd=%0d start=%0b cycles=%0d init_done=%0b",
            $time,
            cmd,
            timer_start,
            timer_cycles,
            init_done
        );
    end

    
    // Test
    initial
    begin

        rst = 1;
        timer_done = 0;

        repeat(2)
            @(posedge clk);

        rst = 0;

        
        // Finish wait period
        repeat(3)
            @(posedge clk);

        timer_done = 1;
        @(posedge clk);
        timer_done = 0;

       
        // Wait until initialization completes
        wait(init_done);

        if (init_done)
            $display("\n[PASS] Initialization Completed\n");
        else
            $display("\n[FAIL]\n");

        $finish;

    end

endmodule