`timescale 1 ns / 1 ps

module tb_AXI4_read_ram();

    // Parameters
    parameter C_S00_AXI_DATA_WIDTH = 32;
    parameter C_S00_AXI_ADDR_WIDTH = 14;

    // Clock and Reset
    reg s00_axi_aclk;
    reg s00_axi_aresetn;

    // AXI Slave Interface Signals
    reg [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr;
    reg [2 : 0] s00_axi_awprot;
    reg s00_axi_awvalid;
    wire s00_axi_awready;
    reg [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata;
    reg [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb;
    reg s00_axi_wvalid;
    wire s00_axi_wready;
    wire [1 : 0] s00_axi_bresp;
    wire s00_axi_bvalid;
    reg s00_axi_bready;
    reg [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr;
    reg [2 : 0] s00_axi_arprot;
    reg s00_axi_arvalid;
    wire s00_axi_arready;
    wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata;
    wire [1 : 0] s00_axi_rresp;
    wire s00_axi_rvalid;
    reg s00_axi_rready;
    reg [C_S00_AXI_DATA_WIDTH-1 : 0] read_data;
    // PWM Output
    wire pwm_out;

    // Instantiate the DUT
    AXI4_read_ram_v1_0 #(
        .C_S00_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
        .C_S00_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
    ) DUT (
        .pwm_out(pwm_out),
        .s00_axi_aclk(s00_axi_aclk),
        .s00_axi_aresetn(s00_axi_aresetn),
        .s00_axi_awaddr(s00_axi_awaddr),
        .s00_axi_awprot(s00_axi_awprot),
        .s00_axi_awvalid(s00_axi_awvalid),
        .s00_axi_awready(s00_axi_awready),
        .s00_axi_wdata(s00_axi_wdata),
        .s00_axi_wstrb(s00_axi_wstrb),
        .s00_axi_wvalid(s00_axi_wvalid),
        .s00_axi_wready(s00_axi_wready),
        .s00_axi_bresp(s00_axi_bresp),
        .s00_axi_bvalid(s00_axi_bvalid),
        .s00_axi_bready(s00_axi_bready),
        .s00_axi_araddr(s00_axi_araddr),
        .s00_axi_arprot(s00_axi_arprot),
        .s00_axi_arvalid(s00_axi_arvalid),
        .s00_axi_arready(s00_axi_arready),
        .s00_axi_rdata(s00_axi_rdata),
        .s00_axi_rresp(s00_axi_rresp),
        .s00_axi_rvalid(s00_axi_rvalid),
        .s00_axi_rready(s00_axi_rready)
    );

    // Clock generation
    initial begin
        s00_axi_aclk = 0;
        forever #5 s00_axi_aclk = ~s00_axi_aclk; // 100 MHz clock
    end

    // Reset generation
    initial begin
        s00_axi_aresetn = 0;
        #100;
        s00_axi_aresetn = 1;
    end

    // AXI Write Task
    task axi_write(input [C_S00_AXI_ADDR_WIDTH-1:0] address, input [C_S00_AXI_DATA_WIDTH-1:0] data);
        begin
            // Address write
            @(posedge s00_axi_aclk);
            s00_axi_awaddr = address;
            
            s00_axi_wvalid = 1;
            @(posedge s00_axi_aclk);
            
            s00_axi_awvalid = 1;
            wait(s00_axi_awready);
            @(posedge s00_axi_aclk);
            s00_axi_awvalid = 0;
            s00_axi_wvalid = 0;
            // Data write
            s00_axi_wdata = data;
            s00_axi_wstrb = {(C_S00_AXI_DATA_WIDTH/8){1'b1}}; // All bytes are valid
            
            wait(s00_axi_wready);
            

            // Wait for write response
            wait(s00_axi_bvalid);
            @(posedge s00_axi_aclk);
            s00_axi_bready = 1;
            @(posedge s00_axi_aclk);
            // @(posedge s00_axi_aclk);
            
            s00_axi_bready = 0;
        end
    endtask

    // AXI Read Task
    task axi_read(input [C_S00_AXI_ADDR_WIDTH-1:0] address, output [C_S00_AXI_DATA_WIDTH-1:0] data);
        begin
            // Address read
            @(posedge s00_axi_aclk);
            s00_axi_araddr = address;
            s00_axi_arvalid = 1;
            wait(s00_axi_arready);
            @(posedge s00_axi_aclk);
            s00_axi_arvalid = 0;

            // Wait for read response
            wait(s00_axi_rvalid);
            @(posedge s00_axi_aclk);
            data = s00_axi_rdata;
            s00_axi_rready = 1;
            @(posedge s00_axi_aclk);
            // #10;
            s00_axi_rready = 0;
        end
    endtask

    // Test sequence
    initial begin
        // Initialize signals
        s00_axi_awaddr = 0;
        s00_axi_awprot = 0;
        s00_axi_awvalid = 0;
        s00_axi_wdata = 0;
        s00_axi_wstrb = 0;
        s00_axi_wvalid = 0;
        s00_axi_bready = 0;
        s00_axi_araddr = 0;
        s00_axi_arprot = 0;
        s00_axi_arvalid = 0;
        s00_axi_rready = 0;

        // Wait for reset deassertion
        wait(s00_axi_aresetn);
        @(posedge s00_axi_aclk);
        $display("Enter run!\n");
        // Write and read example
        #100;

        // Write to address 0x0
        axi_write(4'h0c, 32'h54213698);
        axi_write(4'h00, 32'h12345678);
        axi_write(4'h04, 32'h55aa55aa);
        axi_write(4'h08, 32'haa66aa66);
        axi_write(4'h0c, 32'h54213698);

        // Read from address 0x0
        axi_read(4'h04, read_data);
        $display("Read data: %h", read_data);
        axi_read(4'h08, read_data);
        $display("Read data: %h", read_data);
        axi_read(4'h0c, read_data);
        $display("Read data: %h", read_data);

        // Add more read/write tests as needed

        // Finish simulation
        #1000;
        $finish;
    end

endmodule
