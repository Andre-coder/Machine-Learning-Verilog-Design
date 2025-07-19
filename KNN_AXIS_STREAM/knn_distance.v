// Designer: Eng. Mariano Viegas Andre
// 6/19/2025

module knn_distance #(
	parameter data_with=32
)(
    input clk,
    input rst,
    input [data_with-1:0] x_data_df,
    input [data_with-1:0] y_data_df,
    input [data_with-1:0] new_x_data_point,
    input [data_with-1:0] new_y_data_point,
    output reg [data_with-1:0] distance 
);

reg [data_with-1:0] dx_reg, dy_reg;        
reg [data_with*2-1:0] dx_sq, dy_sq;         
reg [data_with*2-1:0] sum_sq;               
wire [16:0] sqrt_out;                       

// Pipelined square root module instance
knn_sqrt_pipeline knn_sqrt_pipeline_inst(
    .clk(clk),
    .rst(rst),
    .data_in(sum_sq[31:0]), 
    .data_out(sqrt_out)
);

// Pipeline stage 1: Calculate differences
always @(posedge clk) begin
    if (rst) begin
        dx_reg <= 0;
        dy_reg <= 0;
    end else begin
        dx_reg <= new_x_data_point - x_data_df;
        dy_reg <= new_y_data_point - y_data_df;
    end
end

// Pipeline stage 2: Calculate squares
always @(posedge clk) begin
    if (rst) begin
        dx_sq <= 0;
        dy_sq <= 0;
    end else begin
        dx_sq <= dx_reg * dx_reg;
        dy_sq <= dy_reg * dy_reg;
    end
end

// Pipeline stage 3: Calculate sum of squares
always @(posedge clk) begin
    if (rst) begin
        sum_sq <= 0;
    end else begin
        sum_sq <= dx_sq + dy_sq;
    end
end

// Pipeline stage 4: Capture square root result
always @(posedge clk) begin
    if (rst) begin
        distance <= 0;
    end else begin
        // Pad 17-bit result to 32-bit output
        distance <= {15'b0, sqrt_out};
    end
end

endmodule