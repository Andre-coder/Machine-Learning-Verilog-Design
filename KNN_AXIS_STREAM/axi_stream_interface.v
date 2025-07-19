module axi_stream_interface (
    input  wire        clk,
    input  wire        reset_n,

    // ADC input
    input  wire [15:0] adc_data_in,
    input  wire        adc_data_valid,

    // AXI Stream Master output (ADC → PS)
    output reg         m_axis_tvalid,
    input  wire        m_axis_tready,
    output reg [15:0]  m_axis_tdata,
    output reg         m_axis_tlast,

    // AXI Stream Slave input (PS → FPGA Logic)
    input  wire        s_axis_tvalid,
    output wire        s_axis_tready,
    input  wire [15:0] s_axis_tdata,
    input  wire        s_axis_tlast,

    // Processed data output (from PS)
    output reg [15:0]  data_from_ps
);

    //-------------------------------------------------
    // AXIS MASTER: ADC to PS
    //-------------------------------------------------
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            m_axis_tvalid <= 0;
            m_axis_tdata  <= 0;
            m_axis_tlast  <= 0;
        end else begin
            if (adc_data_valid) begin
                m_axis_tdata  <= adc_data_in;
                m_axis_tvalid <= 1;
                m_axis_tlast  <= 0; // Set to 1 if you're sending packets/frames
            end

            if (m_axis_tvalid && m_axis_tready) begin
                m_axis_tvalid <= 0;
            end
        end
    end

    //-------------------------------------------------
    // AXIS SLAVE: PS to FPGA
    //-------------------------------------------------
    assign s_axis_tready = 1'b1; // Always ready to receive (use FIFO in real apps)

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            data_from_ps <= 16'd0;
        end else begin
            if (s_axis_tvalid && s_axis_tready) begin
                data_from_ps <= s_axis_tdata;  // Capture data from PS
            end
        end
    end

endmodule
