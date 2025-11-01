module ram8k_reg (
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
/*
    initial begin
        mem[13'h0000] = 8'hDB;  //8'hC3;
        mem[13'h0001] = 8'hFB;  //8'h03;
        mem[13'h0002] = 8'hD3;  //8'h00;
        mem[13'h0003] = 8'hFE;  //8'h31;
        mem[13'h0004] = 8'hC3;  //8'hFF;
        mem[13'h0005] = 8'h00;  //8'h1F;
        mem[13'h0006] = 8'h00;  //8'hF3;
        mem[13'h0007] = 8'hFB;
        mem[13'h0008] = 8'h06;
        mem[13'h0009] = 8'hFB;
        mem[13'h000A] = 8'h0E;
        mem[13'h000B] = 8'hFE;
        mem[13'h000C] = 8'hED;
        mem[13'h000D] = 8'h78;
        mem[13'h000E] = 8'h06;
        mem[13'h000F] = 8'hFE;
        mem[13'h0010] = 8'h0E;
        mem[13'h0011] = 8'hFE;
        mem[13'h0012] = 8'hED;
        mem[13'h0013] = 8'h79;
        mem[13'h0014] = 8'hC3;
        mem[13'h0015] = 8'h08;
        // alle andere blijven automatisch 'x' of 0 (afhankelijk van simulator)
    end
*/
    // ★ Programma inladen vanuit HEX-bestand
/*    initial begin
        $readmemh("../asm/ping.hex", mem);
    end
*/
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
