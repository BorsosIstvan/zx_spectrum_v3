module decoder(
    input  wire       mreq_n,   // actief laag
    input  wire       iorq_n,
    input  wire [15:0] ad,    // address_bus
    output wire [7:0] ram_cs,   // chip select outputs
    output wire [7:0] io_cs
);

    assign ram_cs[0] = (ad[15:13] == 3'b000)&!mreq_n;
    assign ram_cs[1] = (ad[15:13] == 3'b001)&!mreq_n;
    assign ram_cs[2] = (ad[15:13] == 3'b010)&!mreq_n;
    assign ram_cs[3] = (ad[15:13] == 3'b011)&!mreq_n;
    assign ram_cs[4] = (ad[15:13] == 3'b100)&!mreq_n;
    assign ram_cs[5] = (ad[15:13] == 3'b101)&!mreq_n;
    assign ram_cs[6] = (ad[15:13] == 3'b110)&!mreq_n;
    assign ram_cs[7] = (ad[15:13] == 3'b111)&!mreq_n;

    assign io_cs[0] = (ad[7:0] == 8'hFB)&!iorq_n;   // out to LED 
    assign io_cs[1] = (ad[7:0] == 8'hFE)&!iorq_n;   // keyboard read

endmodule