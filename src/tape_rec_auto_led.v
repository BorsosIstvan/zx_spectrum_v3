module tape_recorder_auto_led (
    input  wire        clk,        // systeemklok (bijv. 3.375 MHz)
    input  wire        reset_n,
    input  wire        aud_out,    // van Spectrum (MIC / SAVE)
    output reg         aud_in,     // naar Spectrum (EAR / LOAD)
    input  wire        btn_rec,
    input  wire        btn_play,
    output reg         rec_led,    // brandt tijdens opname
    output reg         play_led    // brandt tijdens afspelen
);

    // ===== Parameters =====
    parameter integer SAMPLE_RATE = 8000;     // Hz
    parameter integer CLK_FREQ    = 3375000;  // frequentie van clk in Hz
    localparam integer DIVIDER    = CLK_FREQ / SAMPLE_RATE;

    // ===== Tape geheugen (8 KB, elk 8 samples = 65536 bits) =====
    reg [7:0] tape_mem [0:8191];
    reg [12:0] byte_addr;  // 0..8191
    reg [2:0]  bit_idx;
    reg [7:0]  cur_byte;

    // ===== Toestand =====
    reg [1:0] state;
    localparam IDLE=2'd0, RECORD=2'd1, PLAY=2'd2;

    // ===== Sample tick generator =====
    reg [31:0] cnt;
    wire sample_tick = (cnt >= DIVIDER-1);

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            cnt <= 0;
        else if (sample_tick)
            cnt <= 0;
        else
            cnt <= cnt + 1;
    end

    // ===== Hoofdtoestandmachine =====
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= IDLE;
            aud_in <= 1'b1;
            rec_led <= 1'b1;
            play_led <= 1'b1;
            byte_addr <= 0;
            bit_idx <= 0;
            cur_byte <= 8'h00;
        end else begin
            case (state)
                // ----------------------
                // Idle toestand
                // ----------------------
                IDLE: begin
                    aud_in <= 1'b1;
                    rec_led <= 1'b1;
                    play_led <= 1'b1;

                    if (btn_rec) begin
                        // start opname
                        byte_addr <= 0;
                        bit_idx <= 0;
                        cur_byte <= 8'h00;
                        rec_led <= 1'b0;
                        state <= RECORD;
                    end else if (btn_play) begin
                        // start afspelen
                        byte_addr <= 0;
                        bit_idx <= 0;
                        play_led <= 1'b0;
                        state <= PLAY;
                    end
                end

                // ----------------------
                // Opnemen
                // ----------------------
                RECORD: begin
                    rec_led <= 1'b0;
                    if (sample_tick) begin
                        cur_byte[bit_idx] <= aud_out;
                        bit_idx <= bit_idx + 1;
                        if (bit_idx == 3'd7) begin
                            tape_mem[byte_addr] <= cur_byte;
                            byte_addr <= byte_addr + 1;
                            cur_byte <= 8'h00;
                            bit_idx <= 0;
                            if (byte_addr == 13'd8191) begin
                                // einde tape
                                rec_led <= 1'b1;
                                state <= IDLE;
                            end
                        end
                    end
                end

                // ----------------------
                // Afspelen
                // ----------------------
                PLAY: begin
                    play_led <= 1'b0;
                    if (sample_tick) begin
                        aud_in <= tape_mem[byte_addr][bit_idx];
                        bit_idx <= bit_idx + 1;
                        if (bit_idx == 3'd7) begin
                            bit_idx <= 0;
                            byte_addr <= byte_addr + 1;
                            if (byte_addr == 13'd8191) begin
                                // einde tape
                                play_led <= 1'b1;
                                aud_in <= 1'b1;
                                state <= IDLE;
                            end
                        end
                    end
                end
            endcase
        end
    end
endmodule
