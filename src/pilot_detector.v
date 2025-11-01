// pilot_detector.v
// Detect a sustained tone ("pilot"/leader) on aud signal and assert detected.
// Simple edge timer + consecutive-good-count algorithm.

module pilot_detector #(
    parameter integer CLK_FREQ    = 3375000, // clock frequency used to measure (Hz). Gebruik clk_spectrum of sysclk)
    parameter integer PILOT_FREQ  = 1200,    // expected pilot tone frequency (Hz) (default 1200 Hz)
    parameter integer TOLERANCE_PCT = 25,    // allowed +/- percent tolerance on measured period
    parameter integer MIN_EDGES = 40        // how many consecutive good edges to consider a pilot present
)(
    input  wire clk,        // measurement clock (bijv. clk_spectrum)
    input  wire reset_n,
    input  wire aud,        // audio input (signal from audio_io aud_out)
    output reg detected     // asserted when pilot is detected
);

    // expected ticks between rising edges (one period)
    localparam integer EXPECTED_TICKS = CLK_FREQ / PILOT_FREQ;
    // compute tolerance in ticks
    localparam integer TOL = (EXPECTED_TICKS * TOLERANCE_PCT) / 100;
    localparam integer MIN_TICKS = (EXPECTED_TICKS > TOL) ? (EXPECTED_TICKS - TOL) : 1;
    localparam integer MAX_TICKS = EXPECTED_TICKS + TOL;

    // registers
    reg aud_d;                       // delayed aud for edge detect
    reg [31:0] tick_cnt;             // counts clk ticks since last rising edge
    reg [31:0] last_period;          // last measured period
    reg [15:0] good_count;           // number of consecutive good periods

    // edge detection and timing
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            aud_d <= 1'b0;
            tick_cnt <= 0;
            last_period <= 0;
            good_count <= 0;
            detected <= 1'b0;
        end else begin
            aud_d <= aud;
            // increment tick counter every clk
            tick_cnt <= tick_cnt + 1;

            // rising edge?
            if (~aud_d & aud) begin
                // capture period
                last_period <= tick_cnt;
                tick_cnt <= 0;

                // check if within tolerance
                if ((tick_cnt >= MIN_TICKS) && (tick_cnt <= MAX_TICKS)) begin
                    good_count <= good_count + 1;
                end else begin
                    // not match -> reset
                    good_count <= 0;
                end

                // if many good edges in a row -> detected
                if (good_count >= MIN_EDGES) begin
                    detected <= 1'b1;
                end
            end

            // if aud stays idle for long, clear detection
            if (tick_cnt > (EXPECTED_TICKS * 10)) begin
                detected <= 1'b0;
                good_count <= 0;
            end
        end
    end

endmodule
