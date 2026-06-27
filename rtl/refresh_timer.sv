module refresh_timer
#(
    parameter REFRESH_PERIOD = 100
)
(
    input  logic clk,
    input  logic rst,
    input  logic refresh_ack,

    output logic refresh_req
);

    logic [$clog2(REFRESH_PERIOD):0] counter;

    always_ff @(posedge clk or posedge rst)
    begin
        if (rst)
        begin
            counter     <= 0;
            refresh_req <= 0;
        end
        else
        begin
          
            // Waiting for acknowledgement
            if (refresh_req)
            begin
                if (refresh_ack)
                begin
                    refresh_req <= 0;
                    counter      <= 0;
                end
            end

            
            // Counting refresh interval
            else
            begin
                if (counter == REFRESH_PERIOD - 1)
                begin
                    refresh_req <= 1;
                end
                else
                begin
                    counter <= counter + 1;
                end
            end
        end
    end

endmodule