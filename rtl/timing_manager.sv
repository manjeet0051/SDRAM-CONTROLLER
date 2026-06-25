module timing_manager
(
    input  logic       clk,
    input  logic       rst,

    input  logic       start,
    input  logic [7:0] cycles,

    output logic       busy,
    output logic       done
);

    logic [7:0] counter;

    always_ff @(posedge clk or posedge rst)
    begin
        if (rst)
        begin
            counter <= 0;
            busy    <= 0;
            done    <= 0;
        end
        else
        begin
            done <= 0;

          
            // Start new delay
            if (start && !busy)
            begin
                counter <= cycles;
                busy    <= 1;
            end

          
            // Timer running
            else if (busy)
            begin
                if (counter > 1)
                begin
                    counter <= counter - 1;
                end
                else
                begin
                    counter <= 0;
                    busy    <= 0;
                    done    <= 1;
                end
            end
        end
    end

endmodule