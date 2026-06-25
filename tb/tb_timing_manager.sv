`timescale 1ns/1ps

module tb_timing_manager;

    logic clk;
    logic rst;

    logic start;
    logic [7:0] cycles;

    logic busy;
    logic done;

 
    // DUT
    timing_manager dut
    (
        .clk    (clk),
        .rst    (rst),
        .start  (start),
        .cycles (cycles),
        .busy   (busy),
        .done   (done)
    );

    // Clock
    initial
    begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    
    // Task
    task automatic run_timer(input [7:0] delay_cycles);
        integer i;
        begin

            cycles = delay_cycles;

            @(posedge clk);
            start = 1;

            @(posedge clk);
            start = 0;

           
            // Check busy stays high
            for (i = 0; i < delay_cycles; i = i + 1)
            begin
                @(posedge clk);

                if (i != delay_cycles-1 && !busy)
                begin
                    $display(
                        "[FAIL] busy deasserted early"
                    );
                    $finish;
                end
            end

          
            // Check done pulse
            if (!done)
            begin
                $display(
                    "[FAIL] done not asserted"
                );
                $finish;
            end

            $display(
                "[PASS] Timer delay = %0d cycles",
                delay_cycles
            );

        end
    endtask


    // Test Sequence
    initial
    begin

        rst    = 1;
        start  = 0;
        cycles = 0;

        repeat(2)
            @(posedge clk);

        rst = 0;

        run_timer(2);
        run_timer(5);
        run_timer(8);

        $display(
            "\nAll timing manager tests passed.\n"
        );

        $finish;
    end

endmodule