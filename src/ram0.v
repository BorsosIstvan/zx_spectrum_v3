module ram8k_reg_0 (
    input  wire        clk,
    input  wire        reset,
    input  wire        ce,
    input  wire        oce,
    input  wire        wre,     // write enable
    input  wire [12:0] ad,
    inout  wire [7:0]  data_bus
);

    // 8 KB RAM
    reg [7:0] mem [0:8191];
    reg [7:0] ram_dout;

    // Tri-state bus
    assign data_bus = (ce && oce && !wre) ? ram_dout : 8'bz;

    // Init waarden

    // ★ Programma inladen vanuit HEX-bestand
    initial begin
        $readmemh("../rom/pacman/ram0.hex", mem);
    end

    // Lezen/schrijven
    always @(posedge clk) begin
        if (reset) begin
            ram_dout <= 8'h00;
        end else if (ce) begin
            if (wre) begin
                mem[ad] <= data_bus;     // schrijven
            end else if (oce) begin
                ram_dout <= mem[ad];     // lezen
            end
        end
    end

endmodule
