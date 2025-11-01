module zx_keyboard (
    input clk,
    input reset_n,
    input rxd,
    output reg [5:0] led
);

    // ============================
    // UART RX (Alex Forencich)
    // ============================
    wire [7:0] rx_data;
    wire       rx_valid;

    localparam  clkRate    = 27000000;
    localparam  baudrate   = 115200;
    localparam  uartPreScale = (clkRate)/(baudrate*8);

    uart_rx uart_rx_inst (
        .clk(clk),
        .rst(!reset_n),
        .rxd(rxd),
        .m_axis_tdata(rx_data),
        .m_axis_tvalid(rx_valid),
        .m_axis_tready(1'b1),
        .busy(),
        .overrun_error(),
        .frame_error(),
        .prescale(uartPreScale)
    );

    // ============================
    // Key matrix 40 toetsen
    // ============================
    reg [39:0] key_matrix;

    always @(posedge clk or negedge reset_n) begin
        if(!reset_n)
            key_matrix <= 40'b0;
        else if(rx_valid) begin
            case(rx_data)
                // Eerste rij (bijvoorbeeld QWERT)
                8'h15: key_matrix[0]  <= ~key_matrix[0];  // Q
                8'h1D: key_matrix[1]  <= ~key_matrix[1];  // W
                8'h24: key_matrix[2]  <= ~key_matrix[2];  // E
                8'h2D: key_matrix[3]  <= ~key_matrix[3];  // R
                8'h2C: key_matrix[4]  <= ~key_matrix[4];  // T

                // Tweede rij (A S D F G)
                8'h1C: key_matrix[5]  <= ~key_matrix[5];  // A
                8'h1B: key_matrix[6]  <= ~key_matrix[6];  // S
                8'h23: key_matrix[7]  <= ~key_matrix[7];  // D
                8'h2B: key_matrix[8]  <= ~key_matrix[8];  // F
                8'h34: key_matrix[9]  <= ~key_matrix[9];  // G

                // Derde rij (Z X C V B)
                8'h1A: key_matrix[10] <= ~key_matrix[10]; // Z
                8'h22: key_matrix[11] <= ~key_matrix[11]; // X
                8'h21: key_matrix[12] <= ~key_matrix[12]; // C
                8'h2A: key_matrix[13] <= ~key_matrix[13]; // V
                8'h32: key_matrix[14] <= ~key_matrix[14]; // B

                // Vierde rij (1 2 3 4 5)
                8'h16: key_matrix[15] <= ~key_matrix[15]; // 1
                8'h1E: key_matrix[16] <= ~key_matrix[16]; // 2
                8'h26: key_matrix[17] <= ~key_matrix[17]; // 3
                8'h25: key_matrix[18] <= ~key_matrix[18]; // 4
                8'h2E: key_matrix[19] <= ~key_matrix[19]; // 5

                // Vijfde rij (6 7 8 9 0)
                8'h36: key_matrix[20] <= ~key_matrix[20]; // 6
                8'h3D: key_matrix[21] <= ~key_matrix[21]; // 7
                8'h3E: key_matrix[22] <= ~key_matrix[22]; // 8
                8'h46: key_matrix[23] <= ~key_matrix[23]; // 9
                8'h45: key_matrix[24] <= ~key_matrix[24]; // 0

                // Special keys (SHIFT, CTRL, SPACE, ENTER)
                8'h12: key_matrix[25] <= ~key_matrix[25]; // LShift
                8'h59: key_matrix[26] <= ~key_matrix[26]; // RShift
                8'h14: key_matrix[27] <= ~key_matrix[27]; // LCtrl
                8'h11: key_matrix[28] <= ~key_matrix[28]; // Alt / Option
                8'h29: key_matrix[29] <= ~key_matrix[29]; // Space
                8'h5A: key_matrix[30] <= ~key_matrix[30]; // Enter

                // Overige toetsen (tot 40)
                // Voeg toe afhankelijk van je mapping
                default: ;
            endcase
        end
    end

    // ============================
    // LED debug (eerste 6 toetsen)
    // ============================
    always @(*) begin
        led = ~key_matrix[5:0]; // active low LEDs
    end

endmodule
