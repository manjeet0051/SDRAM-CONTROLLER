module init_fsm
(
    input  logic       clk,
    input  logic       rst,
    input  logic       timer_done,

    output logic [2:0] cmd,
    output logic       timer_start,
    output logic [7:0] timer_cycles,
    output logic       init_done
);

    localparam CMD_NOP        = 3'd0;
    localparam CMD_PRECHARGE  = 3'd4;
    localparam CMD_REFRESH    = 3'd5;
    localparam CMD_LOAD_MODE  = 3'd6;

    typedef enum logic [2:0]
    {
        WAIT_100US,
        PRECHARGE,
        REFRESH1,
        REFRESH2,
        LOAD_MODE,
        DONE
    } state_t;

    state_t state;

    always_ff @(posedge clk or posedge rst)
    begin
        if (rst)
            state <= WAIT_100US;
        else
        begin
            case(state)

                WAIT_100US:
                    if (timer_done)
                        state <= PRECHARGE;

                PRECHARGE:
                    state <= REFRESH1;

                REFRESH1:
                    state <= REFRESH2;

                REFRESH2:
                    state <= LOAD_MODE;

                LOAD_MODE:
                    state <= DONE;

                DONE:
                    state <= DONE;

            endcase
        end
    end


    // Outputs
    always_comb
    begin

        cmd          = CMD_NOP;
        timer_start  = 0;
        timer_cycles = 0;
        init_done    = 0;

        case(state)

            WAIT_100US:
            begin
                cmd          = CMD_NOP;
                timer_start  = 1;
                timer_cycles = 100;
            end

            PRECHARGE:
                cmd = CMD_PRECHARGE;

            REFRESH1:
                cmd = CMD_REFRESH;

            REFRESH2:
                cmd = CMD_REFRESH;

            LOAD_MODE:
                cmd = CMD_LOAD_MODE;

            DONE:
                init_done = 1;

        endcase
    end

endmodule