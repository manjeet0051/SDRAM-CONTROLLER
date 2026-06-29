module refresh_fsm
(
    input  logic       clk,
    input  logic       rst,

    input  logic       refresh_req,
    input  logic       timer_done,

    output logic [2:0] cmd,
    output logic       timer_start,
    output logic [7:0] timer_cycles,
    output logic       refresh_ack
);

    localparam CMD_NOP        = 3'd0;
    localparam CMD_PRECHARGE  = 3'd4;
    localparam CMD_REFRESH    = 3'd5;

    localparam TRFC_CYCLES = 8'd7;

    typedef enum logic [2:0]
    {
        IDLE,
        PRECHARGE,
        REFRESH,
        WAIT_TRFC,
        DONE
    } state_t;

    state_t state, next_state;

   
    // State register
    always_ff @(posedge clk or posedge rst)
    begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    
    // Next-state logic
    always_comb
    begin
        next_state = state;

        case (state)

            IDLE:
                if (refresh_req)
                    next_state = PRECHARGE;

            PRECHARGE:
                next_state = REFRESH;

            REFRESH:
                next_state = WAIT_TRFC;

            WAIT_TRFC:
                if (timer_done)
                    next_state = DONE;

            DONE:
                next_state = IDLE;

        endcase
    end

   
    // Output logic
    always_comb
    begin
        cmd          = CMD_NOP;
        timer_start  = 0;
        timer_cycles = 0;
        refresh_ack  = 0;

        case (state)

            PRECHARGE:
                cmd = CMD_PRECHARGE;

            REFRESH:
            begin
                cmd          = CMD_REFRESH;
                timer_start  = 1;
                timer_cycles = TRFC_CYCLES;
            end

            DONE:
                refresh_ack = 1;

        endcase
    end

endmodule