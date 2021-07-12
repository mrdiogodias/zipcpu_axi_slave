
`timescale 1 ns / 1 ps

	module axi_wrapper_v1_0_S00_AXI #(
		

		// Width of S_AXI data bus
		parameter integer C_S_AXI_DATA_WIDTH = 32,
		// Width of S_AXI address bus
		parameter integer C_S_AXI_ADDR_WIDTH = 4,
		
		// Users to add parameters here
		parameter [0:0]	OPT_SKIDBUFFER = 1'b0,
		parameter [0:0]	OPT_LOWPOWER = 0,
		localparam	ADDRLSB = $clog2(C_S_AXI_DATA_WIDTH)-3
		// User parameters ends
	) (
	    // Users to add ports here
		output wire [3:0] o_led,
	    // User ports ends
		// Do not modify the ports beyond this line
		
		input	wire S_AXI_ACLK,
		input	wire S_AXI_ARESETN,
		
		input	wire S_AXI_AWVALID,
		output	wire S_AXI_AWREADY,
		input	wire [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR,
		input	wire [2:0] S_AXI_AWPROT,
		
		input	wire S_AXI_WVALID,
		output	wire S_AXI_WREADY,
		input	wire [C_S_AXI_DATA_WIDTH-1:0] S_AXI_WDATA,
		input	wire [C_S_AXI_DATA_WIDTH/8-1:0] S_AXI_WSTRB,
		
		output	wire S_AXI_BVALID,
		input	wire S_AXI_BREADY,
		output	wire [1:0] S_AXI_BRESP,
		
		input	wire S_AXI_ARVALID,
		output	wire S_AXI_ARREADY,
		input	wire [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR,
		input	wire [2:0] S_AXI_ARPROT,
		
		output	wire S_AXI_RVALID,
		input	wire S_AXI_RREADY,
		output	wire [C_S_AXI_DATA_WIDTH-1:0] S_AXI_RDATA,
		output	wire [1:0] S_AXI_RRESP
	);


	/***********************************************************************
     *
     * Register/wire signal declarations
     * 
	 ***********************************************************************/

	wire i_reset = !S_AXI_ARESETN;

	wire axil_write_ready;
	wire [C_S_AXI_ADDR_WIDTH-ADDRLSB-1:0]	awskd_addr;

	wire [C_S_AXI_DATA_WIDTH-1:0]	wskd_data;
	wire [C_S_AXI_DATA_WIDTH/8-1:0]	wskd_strb;
	reg	 axil_bvalid;
	
	wire axil_read_ready;
	wire [C_S_AXI_ADDR_WIDTH-ADDRLSB-1:0]	arskd_addr;
	reg	 [C_S_AXI_DATA_WIDTH-1:0]	axil_read_data;
	reg	 axil_read_valid;

	reg	 [31:0]	led0, led1, led2, led3;
	wire [31:0]	wskd_r0, wskd_r1, wskd_r2, wskd_r3;
	

	/***********************************************************************
     *
     * AXI-Lite signaling
     * 
	 ***********************************************************************/

    /****** Write signaling *****/

    reg axil_awready;

    initial	axil_awready = 1'b0;
	always @(posedge S_AXI_ACLK)
	if (!S_AXI_ARESETN)
		axil_awready <= 1'b0;
	else
		axil_awready <= !axil_awready
			&& (S_AXI_AWVALID && S_AXI_WVALID)
			&& (!S_AXI_BVALID || S_AXI_BREADY);

    assign	S_AXI_AWREADY = axil_awready;
	assign	S_AXI_WREADY  = axil_awready;

    assign 	awskd_addr = S_AXI_AWADDR[C_S_AXI_ADDR_WIDTH-1:ADDRLSB];
	assign	wskd_data  = S_AXI_WDATA;
	assign	wskd_strb  = S_AXI_WSTRB;
    
    assign	axil_write_ready = axil_awready;


    initial	axil_bvalid = 0;
	always @(posedge S_AXI_ACLK)
	if (i_reset)
		axil_bvalid <= 0;
	else if (axil_write_ready)
		axil_bvalid <= 1;
	else if (S_AXI_BREADY)
		axil_bvalid <= 0;

	assign	S_AXI_BVALID = axil_bvalid;
	assign	S_AXI_BRESP = 2'b00;


    /****** Read signaling *****/

    reg	axil_arready;

    always @(*)
        axil_arready = !S_AXI_RVALID;

    assign	arskd_addr = S_AXI_ARADDR[C_S_AXI_ADDR_WIDTH-1:ADDRLSB];
    assign	S_AXI_ARREADY = axil_arready;
    assign	axil_read_ready = (S_AXI_ARVALID && S_AXI_ARREADY);


    initial	axil_read_valid = 1'b0;
	always @(posedge S_AXI_ACLK)
	if (i_reset)
		axil_read_valid <= 1'b0;
	else if (axil_read_ready)
		axil_read_valid <= 1'b1;
	else if (S_AXI_RREADY)
		axil_read_valid <= 1'b0;

	assign	S_AXI_RVALID = axil_read_valid;
	assign	S_AXI_RDATA  = axil_read_data;
	assign	S_AXI_RRESP = 2'b00;


    /***********************************************************************
     *
     * AXI-Lite register logic
     * 
	 ***********************************************************************/

	assign	wskd_r0 = apply_wstrb(led0, wskd_data, wskd_strb);
	assign	wskd_r1 = apply_wstrb(led1, wskd_data, wskd_strb);
	assign	wskd_r2 = apply_wstrb(led2, wskd_data, wskd_strb);
	assign	wskd_r3 = apply_wstrb(led3, wskd_data, wskd_strb);
	
	assign  o_led[0] = led0[0];
	assign  o_led[1] = led0[1];
	assign  o_led[2] = led0[2];
	assign  o_led[3] = led0[3];

	initial	led0 = 0;
	initial	led1 = 0;
	initial	led2 = 0;
	initial	led3 = 0;
	always @(posedge S_AXI_ACLK)
	if (i_reset)
	begin
		led0 <= 0;
		led1 <= 0;
		led2 <= 0;
		led3 <= 0;
	end else if (axil_write_ready)
	begin
		case(awskd_addr)
		2'b00:	led0 <= wskd_r0;
		2'b01:	led1 <= wskd_r1;
		2'b10:	led2 <= wskd_r2;
		2'b11:	led3 <= wskd_r3;
		endcase
	end

	initial	axil_read_data = 0;
	always @(posedge S_AXI_ACLK)
	if (OPT_LOWPOWER && !S_AXI_ARESETN)
		axil_read_data <= 0;
	else if (!S_AXI_RVALID || S_AXI_RREADY)
	begin
		case(arskd_addr)
		2'b00:	axil_read_data	<= led0;
		2'b01:	axil_read_data	<= led1;
		2'b10:	axil_read_data	<= led2;
		2'b11:	axil_read_data	<= led3;
		endcase

		if (OPT_LOWPOWER && !axil_read_ready)
			axil_read_data <= 0;
	end

	function [C_S_AXI_DATA_WIDTH-1:0]	apply_wstrb;
		input	[C_S_AXI_DATA_WIDTH-1:0]		prior_data;
		input	[C_S_AXI_DATA_WIDTH-1:0]		new_data;
		input	[C_S_AXI_DATA_WIDTH/8-1:0]	wstrb;

		integer	k;
		for(k=0; k<C_S_AXI_DATA_WIDTH/8; k=k+1)
		begin
			apply_wstrb[k*8 +: 8]
				= wstrb[k] ? new_data[k*8 +: 8] : prior_data[k*8 +: 8];
		end
	endfunction

endmodule