// Designer: Eng. Mariano Viegas Andre
// Date: 6/19/2025
// Date: 6/22/2025

module k_nn #( 
    parameter NUMBER_ELEMENTS = 6,
    parameter DATA_WIDTH = 32,
    parameter CLASS_WIDTH = 8
)(
    // Inputs
    input  wire                     clk,
    input  wire                     rst, // Active-low reset
    //input  wire [DATA_WIDTH-1:0]    new_x_data_point,
    //input  wire [DATA_WIDTH-1:0]    new_y_data_point,

    // AXIS Outputs (ADC → PS)
    output wire                     m_axis_tvalid,
    input  wire                     m_axis_tready,
    output wire [DATA_WIDTH-1:0]    m_axis_tdata,
    output wire                     m_axis_tlast,

    // AXIS Inputs (PS → FPGA)
    input  wire                     s_axis_tvalid,
    output wire                     s_axis_tready,
    input  wire [DATA_WIDTH-1:0]    s_axis_tdata,
    input  wire                     s_axis_tlast,

    // Output Result
    
    output wire [DATA_WIDTH-1:0]    distance_result
);

    // =======================================

    // Internal storage for known data points
    reg [DATA_WIDTH-1:0] x_data_df [0:NUMBER_ELEMENTS-1];
    reg [DATA_WIDTH-1:0] y_data_df [0:NUMBER_ELEMENTS-1];
    reg [CLASS_WIDTH-1:0] data_class [0:NUMBER_ELEMENTS-1];
	
	reg [DATA_WIDTH-1:0] x_data;
	reg [DATA_WIDTH-1:0] y_data;
	reg [2*DATA_WIDTH-1:0] data_ps;
	
	reg [CLASS_WIDTH-1:0] xy_class;
	
	reg [DATA_WIDTH-1:0] new_x_data_point;
	reg [DATA_WIDTH-1:0] new_y_data_point;
	wire data_from_ps;
	
    integer i;
    always @(posedge clk) begin
        if (rst) begin
			i <= 0;
		end else begin
            for (i = 0; i < NUMBER_ELEMENTS; i = i + 1) begin
                x_data <= x_data_df[i];
                y_data <= y_data_df[i];
                xy_class <= data_class[i];
            end
            // Example known points (scaled by 1000)
            x_data_df[0] <= 5100; y_data_df[0] <= 3500; data_class[0] <= 0;
            x_data_df[1] <= 4900; y_data_df[1] <= 3000; data_class[1] <= 0;
            x_data_df[2] <= 4700; y_data_df[2] <= 3200; data_class[2] <= 0;
            x_data_df[3] <= 7000; y_data_df[3] <= 3200; data_class[3] <= 1;
            x_data_df[4] <= 6400; y_data_df[4] <= 3200; data_class[4] <= 1;
            x_data_df[5] <= 6900; y_data_df[5] <= 3100; data_class[5] <= 1;
        end
    end

    // =======================================
    // Distance calculation (module assumed)
    wire [DATA_WIDTH-1:0] distance_result_parallel;

    knn_distance dist_calc (
        .clk(clk),
        .rst(~rst),  // Assuming this module expects active-high reset
        .new_x_data_point(new_x_data_point),
        .new_y_data_point(new_y_data_point),
        .x_data_df(x_data),
        .y_data_df(y_data),
        .distance(distance_result_parallel)
    );

    assign distance_result = distance_result_parallel;

    // =======================================
    // AXI Stream Interface for PS <-> FPGA
    axi_stream_interface u_adc_axi_stream (
        .clk(clk),
        .reset_n(rst),

        .adc_data_in(distance_result_parallel),
        .adc_data_valid(1'b1), // Always valid after calculation? Needs improvement

        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tlast(m_axis_tlast),

        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tready(s_axis_tready),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tlast(s_axis_tlast),

        .data_from_ps(data_from_ps) //
    );

     
	task data_ps (input [DATA_WIDTH-1:0] x, input [DATA_WIDTH-1:0] y);
        begin
            new_x_data_point = x;
            new_y_data_point = y;
        end
    endtask

     always @(posedge clk) begin
        data_ps <= data_from_ps;    
    end 

endmodule

