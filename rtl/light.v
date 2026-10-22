module light (
    input            clk,
    input            rst_n,
    input            emergency,
    output reg [7:0] sec_ge,
    output reg [3:0] led,
    output reg [1:0] ledn,
    output reg [4:0] north,
    output reg [4:0] west,
    output reg [1:0] ledw
);

reg [31:0] cnt_div;
reg        clk_1hz;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_div <= 32'd0;
        clk_1hz <= 1'b0;
    end else if (cnt_div < 32'd49999999) begin
        cnt_div <= cnt_div + 1'b1;
        clk_1hz <= 1'b0;
    end else begin
        cnt_div <= 32'd0;
        clk_1hz <= 1'b1;
    end
end

parameter S1 = 2'd0,
          S2 = 2'd1,
          S3 = 2'd2,
          S4 = 2'd3;

reg [1:0] state;

always @(posedge clk_1hz or negedge rst_n) begin
    if (!rst_n) begin
        state <= S1;
        north <= 5'd25;
        west  <= 5'd20;
        ledn  <= 2'b00;
        ledw  <= 2'b01;
    end
    else if (emergency) begin
        ledn  <= 2'b00;
        ledw  <= 2'b00;
        north <= north;
        west  <= west;
    end
    else begin
        case (state)
            S1: begin
                if (west == 5'd0) begin
                    state <= S2;
                    north <= 5'd5;
                    west  <= 5'd5;
                    ledw  <= 2'b10;
                end else begin
                    north <= north - 1;
                    west  <= west - 1;
                end
            end

            S2: begin
                if (north == 5'd0 && west == 5'd0) begin
                    state <= S3;
                    north <= 5'd20;
                    west  <= 5'd25;
                    ledn  <= 2'b01;
                    ledw  <= 2'b00;
                end else begin
                    north <= north - 1;
                    west  <= west - 1;
                end
            end

            S3: begin
                if (north == 5'd0) begin
                    state <= S4;
                    north <= 5'd5;
                    west  <= 5'd5;
                    ledn  <= 2'b10;
                end else begin
                    north <= north - 1;
                    west  <= west - 1;
                end
            end

            S4: begin
                if (north == 5'd0 && west == 5'd0) begin
                    state <= S1;
                    north <= 5'd25;
                    west  <= 5'd20;
                    ledn  <= 2'b00;
                    ledw  <= 2'b01;
                end else begin
                    north <= north - 1;
                    west  <= west - 1;
                end
            end
        endcase
    end
end

reg [1:0] cntl;
reg [3:0] digit;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cntl  <= 2'd0;
        led   <= 4'b1111;
        digit <= 4'd0;
    end else begin
        cntl <= cntl + 1'b1;
        case (cntl)
            2'd0: begin
                led   <= 4'b1110;
                digit <= west % 10;
            end
            2'd1: begin
                led   <= 4'b1101;
                digit <= west / 10;
            end
            2'd2: begin
                led   <= 4'b1011;
                digit <= north % 10;
            end
            2'd3: begin
                led   <= 4'b0111;
                digit <= north / 10;
            end
        endcase
    end
end

always @(*) begin
    case (digit)
        4'd0:    sec_ge = 8'b00111111;
        4'd1:    sec_ge = 8'b00000110;
        4'd2:    sec_ge = 8'b01011011;
        4'd3:    sec_ge = 8'b01001111;
        4'd4:    sec_ge = 8'b01100110;
        4'd5:    sec_ge = 8'b01101101;
        4'd6:    sec_ge = 8'b01111101;
        4'd7:    sec_ge = 8'b00000111;
        4'd8:    sec_ge = 8'b01111111;
        4'd9:    sec_ge = 8'b01101111;
        default: sec_ge = 8'b00000000;
    endcase
end

endmodule
