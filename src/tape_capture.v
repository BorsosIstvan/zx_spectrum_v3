// tape_capture.v
// Assemble bits (LSB-first) into bytes and store into 8KB RAM.
// Inputs:
//   clk, reset_n
//   start         : go = sync_detected (starts capture; module can capture continuously after start)
//   data_bit      : single decoded bit (0/1)
//   data_valid    : 1-clock pulse when data_bit is valid
//
// Outputs:
//   byte_written  : 1-clock pulse when a byte written to RAM
//   mem_full      : high when mem full (8192 bytes written)
//   wr_ptr_out    : current write pointer (for debug)
//   led_bit       : toggles on each received bit (debug)

module tape_capture (
    input  wire        clk,
    input  wire        reset_n,
    input  wire        start,        // sync_detected → begin capture
    input  wire        data_bit,     // bit value from tape_bit_reader
    input  wire        data_valid,   // 1 cycle pulse when data_bit valid

    // interface met tape_mem
    output wire        mem_we,
    output wire [12:0] mem_waddr,
    output wire [7:0]  mem_wdata,

    output reg         byte_written, // 1 cycle pulse when a byte written
    output reg         mem_full,     // becomes 1 when memory full
    output reg [12:0]  wr_ptr_out,   // write pointer (0..8191)
    output reg         led_bit       // toggles each time a bit is processed (debug)
);

    // interne registers
    reg [12:0] wr_ptr;   // write pointer
    reg [2:0]  bit_idx;  // 0..7 (LSB-first)
    reg [7:0]  shift_reg;
    reg        active;   // capturing state

    // lokale temp
    reg [7:0] next_shift;

    assign mem_we    = active && data_valid && !mem_full && (bit_idx == 3'd7);
    assign mem_waddr = wr_ptr;
    assign mem_wdata = next_shift;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            wr_ptr    <= 13'd0;
            bit_idx   <= 3'd0;
            shift_reg <= 8'd0;
            active    <= 1'b0;
            byte_written <= 1'b0;
            mem_full  <= 1'b0;
            wr_ptr_out <= 13'd0;
            led_bit <= 1'b0;
            next_shift <= 8'd0;
        end else begin
            byte_written <= 1'b0; // default low

            if (start)
                active <= 1'b1;

            if (mem_full)
                active <= 1'b0;

            if (active && data_valid && !mem_full) begin
                next_shift = shift_reg;
                next_shift[bit_idx] = data_bit;

                // debug toggle
                led_bit <= ~led_bit;

                if (bit_idx == 3'd7) begin
                    byte_written <= 1'b1;
                    wr_ptr <= wr_ptr + 1;
                    wr_ptr_out <= wr_ptr + 1;
                    shift_reg <= 8'd0;
                    bit_idx <= 3'd0;

                    if (wr_ptr == 13'd8191) begin
                        mem_full <= 1'b1;
                        active <= 1'b0;
                    end
                end else begin
                    shift_reg <= next_shift;
                    bit_idx <= bit_idx + 1;
                end
            end
        end
    end

endmodule
