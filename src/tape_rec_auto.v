module tape_recorder_auto (
    input  wire        clk,        // bijv. clk_spectrum of sysclk
    input  wire        reset_n,
    input  wire        aud_out,    // van Spectrum (MIC / SAVE)
    output reg         aud_in,     // naar Spectrum (EAR / LOAD)
    input  wire        btn_rec,
    input  wire        btn_play
);

    // parameters
    parameter integer SAMPLE_RATE = 8000;     // in Hz
    parameter integer CLK_FREQ    = 27000000;  // frequentie van clk in Hz
    localparam integer DIVIDER    = CLK_FREQ / SAMPLE_RATE;

    // geheugen (8 KB, elk 8 samples packed = 65536 samples)
    reg [7:0] tape_mem [0:8191];
    reg [12:0] byte_addr;  // 0..8191
    reg [2:0]  bit_idx;    // 0..7
    reg [7:0]  cur_byte;
    reg [1:0]  state;
    localparam IDLE=2'd0, RECORD=2'd1, PLAY=2'd2;

    // sample tick generator
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

    // hoofdtoestand
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= IDLE;
            aud_in <= 1'b1;
            byte_addr <= 0;
            bit_idx <= 0;
            cur_byte <= 8'h00;
        end else begin
            case (state)
                // wacht op knop
                IDLE: begin
                    aud_in <= 1'b1;
                    if (btn_rec) begin
                        // start opname
                        byte_addr <= 0;
                        bit_idx <= 0;
                        cur_byte <= 8'h00;
                        state <= RECORD;
                    end else if (btn_play) begin
                        // start afspelen
                        byte_addr <= 0;
                        bit_idx <= 0;
                        state <= PLAY;
                    end
                end

                // opnemen tot geheugen vol
                RECORD: begin
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
                                state <= IDLE;
                            end
                        end
                    end
                end

                // afspelen tot geheugen vol
                PLAY: begin
                    if (sample_tick) begin
                        aud_in <= tape_mem[byte_addr][bit_idx];
                        bit_idx <= bit_idx + 1;
                        if (bit_idx == 3'd7) begin
                            bit_idx <= 0;
                            byte_addr <= byte_addr + 1;
                            if (byte_addr == 13'd8191) begin
                                // einde tape
                                state <= IDLE;
                                aud_in <= 1'b1;
                            end
                        end
                    end
                end
            endcase
        end
    end
endmodule
