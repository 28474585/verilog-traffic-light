`timescale 1ns/1ns

module light_tst();
    reg  clk, rst_n, emergency;
    wire [3:0] led;
    wire [7:0] sec_ge;
    wire [1:0] ledn, ledw;
    wire [4:0] north, west;

    parameter period=20;

    initial begin
        clk=1'b0; rst_n=1'b0; emergency=1'b0;
        #20 rst_n=1'b1;
        #50 emergency=1'b1;
        #100 emergency=1'b0;
    end

    always
    begin
        #(period/2) clk<=~clk;
    end

    light u0(
        .clk(clk),
        .rst_n(rst_n),
        .emergency(emergency),
        .led(led),
        .sec_ge(sec_ge),
        .ledn(ledn),
        .ledw(ledw),
        .north(north),
        .west(west)
    );

endmodule
