// Designer: Eng. Mariano Viegas Andre
// 6/19/2025

module knn_sqrt_pipeline #(parameter data_with=32)(
    input  wire        clk,      // Clock input
    input  wire        rst,      // Reset input
    input  wire [32:0] data_in,  // 33-bit input
    output reg  [16:0] data_out  // 17-bit output
);

// Remainder registers for each stage
reg [32:0] rem [0:16];  

// Quotient registers for each stage
reg [16:0] quo [0:16];  
integer i;

always @(posedge clk) begin
    if (rst) begin
        // Initialize all pipeline stages
        for (i = 0; i <= 16; i = i + 1) begin
            rem[i] <= 0;
            quo[i] <= 0;
        end
        data_out <= 0;
    end else begin
        // Stage 0: Initialize remainder and quotient
        rem[0] <= data_in;
        quo[0] <= 0;

        // Pipelined stages 1 to 16
        for (i = 0; i < 16; i = i + 1) begin
            if (rem[i][32] == 0) begin  // Non-negative remainder
                rem[i+1] <= {rem[i][31:0], 2'b00} - {quo[i], 2'b01};
                quo[i+1] <= {quo[i][15:0], 1'b1};
            end else begin               // Negative remainder
                rem[i+1] <= {rem[i][31:0], 2'b00} + {quo[i], 2'b11};
                quo[i+1] <= {quo[i][15:0], 1'b0};
            end
        end

        // Final adjustment for stage 16
        if (rem[16][32] == 0) begin
            data_out <= quo[16];
        end else begin
            data_out <= quo[16] - 1;  // Adjust quotient if remainder negative
        end
    end
end

endmodule