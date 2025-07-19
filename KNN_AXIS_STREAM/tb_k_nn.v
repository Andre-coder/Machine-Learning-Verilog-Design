`timescale 1ns / 1ps

module tb_k_nn;

    // Parameters
    localparam DATA_WIDTH      = 32;
    localparam NUMBER_ELEMENTS = 6;
    localparam CLASS_WIDTH     = 8;

    // DUT Inputs
    reg                         clk;
    reg                         rst_n;
    reg [DATA_WIDTH-1:0]        new_x_data_point;
    reg [DATA_WIDTH-1:0]        new_y_data_point;

    // AXI Stream Interface (Master)
    wire                        m_axis_tvalid;
    reg                         m_axis_tready;
    wire [DATA_WIDTH-1:0]       m_axis_tdata;
    wire                        m_axis_tlast;

    // AXI Stream Interface (Slave)
    reg                         s_axis_tvalid;
    wire                        s_axis_tready;
    reg [DATA_WIDTH-1:0]        s_axis_tdata;
    reg                         s_axis_tlast;

    // Output
    wire [DATA_WIDTH-1:0]       distance_result;

    // Instantiate DUT
    k_nn #(
        .NUMBER_ELEMENTS(NUMBER_ELEMENTS),
        .DATA_WIDTH(DATA_WIDTH),
        .CLASS_WIDTH(CLASS_WIDTH)
    ) DUT (
        .clk(clk),
        .rst_n(rst_n),
        .new_x_data_point(new_x_data_point),
        .new_y_data_point(new_y_data_point),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tlast(m_axis_tlast),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tready(s_axis_tready),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tlast(s_axis_tlast),
        .distance_result(distance_result)
    );

    // Generate Clock
    always #5 clk = ~clk; // 100MHz clock (10ns period)

    // Stimulus
    initial begin
        // Initialize
        clk              = 0;
        rst_n            = 0;
        new_x_data_point = 0;
        new_y_data_point = 0;
        m_axis_tready    = 1;  // Always ready for simplicity
        s_axis_tvalid    = 0;
        s_axis_tdata     = 0;
        s_axis_tlast     = 0;

        // Apply reset
        #20;
        rst_n = 1;

        // Wait a bit for initialization
        #20;

        // Apply test input data points (scaled by 1000)
        send_data_point(5000, 3200);   
        send_data_point(6800, 3300);   
        send_data_point(6000, 3100);   

        // Simulate receiving data from PS (optional)
        send_data_from_ps(32'hAABBCCDD);
        send_data_from_ps(32'h12345678);

        // Finish simulation
        #200;
        $finish;
    end

    // Task to send a new data point
    task send_data_point(input [DATA_WIDTH-1:0] x, input [DATA_WIDTH-1:0] y);
        begin
            new_x_data_point = x;
            new_y_data_point = y;
            #20; // Wait for computation
        end
    endtask

    // Task to simulate data coming from PS (AXIS Slave side)
    task send_data_from_ps(input [DATA_WIDTH-1:0] ps_data);
        begin
            s_axis_tdata  = ps_data;
            s_axis_tvalid = 1;
            s_axis_tlast  = 0;
            #10;
            s_axis_tvalid = 0;
            #10;
        end
    endtask

    // Monitor output (optional but useful)
    initial begin
        $monitor("Time=%0t | x=%d | y=%d | distance_result=%d | m_axis_tvalid=%b", 
                 $time, new_x_data_point, new_y_data_point, distance_result, m_axis_tvalid);
    end

endmodule
