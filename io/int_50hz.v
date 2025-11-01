module int50hz (
    input  wire clk,        // clk_spectrum (~3.375 MHz)
    input  wire reset_n,
    output reg  int_n       // actief laag
);
    // parameters voor 50 Hz interrupt
    localparam integer PERIOD_TICKS = 67500;  // 20 ms bij 3.375 MHz
    localparam integer PULSE_TICKS  = 33;    // ~100 µs pulsbreedte

    reg [15:0] counter; // genoeg bits voor 67,500 (17 bits)
    reg pulse_active;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            counter <= 0;
            pulse_active <= 1'b0;
            int_n <= 1'b1; // hoog = geen interrupt
        end else begin
            if (counter < PERIOD_TICKS - 1)
                counter <= counter + 1;
            else
                counter <= 0;

            // begin van periode → active low pulse
            if (counter == 0) begin
                pulse_active <= 1'b1;
            end else if (counter >= PULSE_TICKS) begin
                pulse_active <= 1'b0;
            end

            int_n <= ~pulse_active; // actief laag
        end
    end
endmodule
