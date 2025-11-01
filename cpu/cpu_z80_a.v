module cpu_z80a (
    input wire clk,
    input wire reset_n,
    output wire [15:0] address_bus, // 16-bit adresbus
    inout wire [7:0] data_bus,      // 8-bit tri-state databus
    input wire halt_n,
    input wire int_n,
    output wire iorq_n,
    output wire m1_n,
    output wire mreq_n,
    output wire rd_n,
    output wire wr_n
);

    // --- Instantie van T80a / T80a core ---
    T80a cpu (
        .CLK_n(clk),
        .RESET_n(reset_n),
        .A(address_bus),
        .D(data_bus),
        .MREQ_n(mreq_n),
        .RD_n(rd_n),
        .WR_n(wr_n),
        .IORQ_n(iorq_n),  // voorlopig niet gebruikt
        .RFSH_n(),  // voorlopig niet gebruikt
        .M1_n(m1_n),    // voorlopig niet gebruikt
        .HALT_n(halt_n),  // voorlopig niet gebruikt
        .BUSAK_n(), // voorlopig niet gebruikt
        .INT_n(int_n),
        .NMI_n(1'b1),
        .WAIT_n(1'b1),
        .BUSRQ_n(1'b1)
    );

endmodule