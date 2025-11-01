module sync_detector #(
    parameter integer CLK_FREQ = 27000000,
    parameter integer SYNC_MIN_US = 600,     // 0.6 ms
    parameter integer SYNC_MAX_US = 800,     // 0.8 ms
    parameter integer HOLD_MS = 200          // LED zichtbaar houden
)(
    input  wire clk,
    input  wire reset_n,
    input  wire aud,
    output reg detected
);

    reg aud_d;
    reg [31:0] edge_counter;
    reg [31:0] period;
    reg [31:0] hold_counter;

    wire [31:0] SYNC_MIN = (CLK_FREQ / 1_000_000) * SYNC_MIN_US;
    wire [31:0] SYNC_MAX = (CLK_FREQ / 1_000_000) * SYNC_MAX_US;
    wire [31:0] HOLD_COUNT = (CLK_FREQ / 1000) * HOLD_MS;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            aud_d <= 0;
            edge_counter <= 0;
            period <= 0;
            hold_counter <= 0;
            detected <= 0;
        end else begin
            aud_d <= aud;

            // LED aanhouden
            if (hold_counter > 0) begin
                hold_counter <= hold_counter - 1;
                detected <= 1;
            end else begin
                detected <= 0;
            end

            // rising edge
            if (aud && !aud_d) begin
                period <= edge_counter;
                edge_counter <= 0;

                if (period > SYNC_MIN && period < SYNC_MAX) begin
                    hold_counter <= HOLD_COUNT;  // LED 200ms aan
                end
            end else begin
                edge_counter <= edge_counter + 1;
            end
        end
    end
endmodule
