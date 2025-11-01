module tape_playback #(
    parameter CLK_FREQ        = 27000000,
    parameter PILOT_LONG_MS   = 2000,    // lengte eerste pilot in ms
    parameter PILOT_SHORT_MS  = 1000,    // lengte tweede pilot in ms
    parameter HEADER_BYTES    = 17,      // aantal bytes in header
    parameter PAUSE_MS        = 1000,     // pauze tussen header en data
    parameter BIT0_PERIOD     = CLK_FREQ / (2 * 240), // halve golf 0
    parameter BIT1_PERIOD     = CLK_FREQ / (2 * 120)  // halve golf 1
)(
    input  wire        clk,
    input  wire        reset_n,
    input  wire        play_start,
    output reg         aud_out,
    output reg         playing,
    output reg [12:0]  rd_addr,
    input  wire [7:0]  mem_rdata
);

    // States
    localparam STATE_IDLE        = 4'd0;
    localparam STATE_PILOT_LONG  = 4'd1;
    localparam STATE_SYNC1       = 4'd2;
    localparam STATE_HEADER      = 4'd3;
    localparam STATE_PAUSE       = 4'd4;
    localparam STATE_PILOT_SHORT = 4'd5;
    localparam STATE_SYNC2       = 4'd6;
    localparam STATE_DATA        = 4'd7;
    localparam STATE_DONE        = 4'd8;

    reg [3:0] state;
    reg [35:0] clk_cnt;
    reg phase;
    reg [2:0] bit_idx;
    reg [12:0] byte_ptr;

    // pilot half-periods
    localparam integer PILOT_LONG_CYCLES  = (CLK_FREQ/1000) * PILOT_LONG_MS/(2);
    localparam integer PILOT_SHORT_CYCLES = (CLK_FREQ/1000) * PILOT_SHORT_MS/(2);

    reg [15:0] pilot_cnt;
    reg [7:0] cur_byte;

    reg [15:0] period;

    // pauze teller
    localparam integer PAUSE_CYCLES = (CLK_FREQ / 1000) * PAUSE_MS;
    reg [31:0] pause_cnt;

    always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            state <= STATE_IDLE;
            aud_out <= 1'b1;
            playing <= 0;
            clk_cnt <= 0;
            pilot_cnt <= 0;
            phase <= 0;
            bit_idx <= 0;
            byte_ptr <= 0;
            rd_addr <= 0;
            cur_byte <= 0;
            pause_cnt <= 0;
        end else begin
            case(state)
                STATE_IDLE: begin
                    if(play_start) begin
                        playing <= 1;
                        state <= STATE_PILOT_LONG;
                        clk_cnt <= 0;
                        pilot_cnt <= 0;
                        phase <= 0;
                        aud_out <= 1'b1;
                    end
                end

                STATE_PILOT_LONG: begin
                    clk_cnt <= clk_cnt + 1;
                    if(clk_cnt >= BIT1_PERIOD) begin
                        clk_cnt <= 0;
                        aud_out <= ~aud_out;
                        phase <= ~phase;
                        if(phase) pilot_cnt <= pilot_cnt + 1;
                        if(pilot_cnt >= PILOT_LONG_CYCLES) begin
                            state <= STATE_SYNC1;
                            clk_cnt <= 0;
                            phase <= 0;
                            aud_out <= 1'b0;
                        end
                    end
                end

                STATE_SYNC1: begin
                    clk_cnt <= clk_cnt + 1;
                    if(clk_cnt >= BIT0_PERIOD) begin
                        clk_cnt <= 0;
                        aud_out <= ~aud_out;
                        phase <= ~phase;
                        if(phase) begin
                            state <= STATE_HEADER;
                            byte_ptr <= 0;
                            rd_addr <= 0;
                            cur_byte <= mem_rdata;
                            bit_idx <= 0;
                        end
                    end
                end

                STATE_HEADER: begin
                    clk_cnt <= clk_cnt + 1;
                    period = (cur_byte[bit_idx]) ? BIT1_PERIOD : BIT0_PERIOD;
                    if(clk_cnt >= period) begin
                        clk_cnt <= 0;
                        aud_out <= ~aud_out;
                        phase <= ~phase;
                        if(phase) begin
                            if(bit_idx == 7) begin
                                bit_idx <= 0;
                                byte_ptr <= byte_ptr + 1;
                                rd_addr <= rd_addr + 1;
                                cur_byte <= mem_rdata;
                                if(byte_ptr >= HEADER_BYTES-1) begin
                                    state <= STATE_PAUSE;
                                    pause_cnt <= 0;
                                end
                            end else begin
                                bit_idx <= bit_idx + 1;
                            end
                        end
                    end
                end

                STATE_PAUSE: begin
                    pause_cnt <= pause_cnt + 1;
                    if(pause_cnt >= PAUSE_CYCLES) begin
                        state <= STATE_PILOT_SHORT;
                        clk_cnt <= 0;
                        pilot_cnt <= 0;
                        aud_out <= 1'b1;
                        phase <= 0;
                    end
                end

                STATE_PILOT_SHORT: begin
                    clk_cnt <= clk_cnt + 1;
                    if(clk_cnt >= BIT1_PERIOD) begin
                        clk_cnt <= 0;
                        aud_out <= ~aud_out;
                        phase <= ~phase;
                        if(phase) pilot_cnt <= pilot_cnt + 1;
                        if(pilot_cnt >= PILOT_SHORT_CYCLES) begin
                            state <= STATE_SYNC2;
                            clk_cnt <= 0;
                            aud_out <= 1'b0;
                            phase <= 0;
                        end
                    end
                end

                STATE_SYNC2: begin
                    clk_cnt <= clk_cnt + 1;
                    if(clk_cnt >= BIT0_PERIOD) begin
                        clk_cnt <= 0;
                        aud_out <= ~aud_out;
                        phase <= ~phase;
                        if(phase) begin
                            state <= STATE_DATA;
                            bit_idx <= 0;
                            byte_ptr <= HEADER_BYTES;
                            rd_addr <= HEADER_BYTES;
                            cur_byte <= mem_rdata;
                        end
                    end
                end

                STATE_DATA: begin
                    clk_cnt <= clk_cnt + 1;
                    period = (cur_byte[bit_idx]) ? BIT1_PERIOD : BIT0_PERIOD;
                    if(clk_cnt >= period) begin
                        clk_cnt <= 0;
                        aud_out <= ~aud_out;
                        phase <= ~phase;
                        if(phase) begin
                            if(bit_idx == 7) begin
                                bit_idx <= 0;
                                byte_ptr <= byte_ptr + 1;
                                rd_addr <= rd_addr + 1;
                                cur_byte <= mem_rdata;
                                if(byte_ptr >= 8191) begin
                                    state <= STATE_DONE;
                                    aud_out <= 1'b1;
                                end
                            end else begin
                                bit_idx <= bit_idx + 1;
                            end
                        end
                    end
                end

                STATE_DONE: begin
                    playing <= 0;
                    state <= STATE_IDLE;
                end
            endcase
        end
    end
endmodule
