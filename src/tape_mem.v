module tape_mem (
    input  wire        clk,
    // schrijf interface
    input  wire        we,
    input  wire [12:0] waddr,
    input  wire [7:0]  wdata,
    // lees interface
    input  wire [12:0] raddr,
    output reg  [7:0]  rdata
);

    // 8 KB geheugen
    reg [7:0] mem [0:8191];

initial begin
    // Header
    mem[0]  = 8'h00;
    mem[1]  = 8'h07;
    mem[2]  = 8'h00;
    mem[3]  = 8'h00;
    mem[4]  = 8'h5B;
    mem[5]  = 8'h48; // H
    mem[6]  = 8'h45; // E
    mem[7]  = 8'h4C; // L
    mem[8]  = 8'h4C; // L
    mem[9]  = 8'h4F; // O
    mem[10] = 8'h20;
    mem[11] = 8'h20;
    mem[12] = 8'h20;
    mem[13] = 8'h20;
    mem[14] = 8'h20;
    mem[15] = 8'hFF; // checksum
    mem[16] = 8'h00;  // reserveer

    // Data
    mem[17] = 8'h0A;
    mem[18] = 8'h00;
    mem[19] = 8'hF0; // REM
    mem[20] = 8'h48; // H
    mem[21] = 8'h45; // E
    mem[22] = 8'h4C; // L
    mem[23] = 8'h4C; // L
    mem[24] = 8'h4F; // O
    mem[25] = 8'h0D; // EOL
    mem[26] = 8'hFF; // checksum
end

    // schrijf
    always @(posedge clk) begin
        if (we)
            mem[waddr] <= wdata;
    end

    // lees
    always @(posedge clk) begin
        rdata <= mem[raddr];
    end

endmodule
