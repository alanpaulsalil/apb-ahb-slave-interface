module tb_apb;

    reg hclk, hresetn;
    reg valid, hwrite, hwritereg;
    reg [31:0] haddr, haddr1, haddr2;
    reg [31:0] hwdata, hwdata1, hwdata2;
    reg [2:0] tempselx;

    wire pwrite, penable;
    wire [2:0] pselx;
    wire [31:0] paddr, pwdata;
    wire hreadyout;
    wire [31:0] prdata;

    apb_controller apb_c(
        .hclk(hclk),
        .hresetn(hresetn),
        .valid(valid),
        .hwrite(hwrite),
        .hwritereg(hwritereg),
        .haddr(haddr),
        .haddr1(haddr1),
        .haddr2(haddr2),
        .hwdata(hwdata),
        .hwdata1(hwdata1),
        .hwdata2(hwdata2),
        .tempselx(tempselx),
        .hreadyout(hreadyout),
        .pselx(pselx),
        .penable(penable),
        .pwrite(pwrite),
        .paddr(paddr),
        .pwdata(pwdata)
    );

    APB_Interface apb_slave(
        .pwrite(pwrite),
        .penable(penable),
        .pselx(pselx),
        .paddr(paddr),
        .pwdata(pwdata),
        .prdata(prdata)
    );

    initial hclk = 0;
    always #5 hclk = ~hclk;

    initial begin
        hresetn   = 0;
        valid     = 0;
        hwrite    = 0;
        hwritereg = 0;
        haddr     = 0;
        haddr1    = 0;
        haddr2    = 0;
        hwdata    = 0;
        hwdata1   = 0;
        hwdata2   = 0;
        tempselx  = 3'b000;
        #15;
        hresetn = 1;

        // single write
        @(posedge hclk) #1;
        valid=1; hwrite=1; hwritereg=0;
        haddr=32'h80000001; haddr1=32'h80000001; haddr2=32'h0;
        hwdata=32'hAA; hwdata1=32'hAA; hwdata2=32'h0;
        tempselx=3'b001;

        @(posedge hclk) #1;
        valid=1; hwrite=1; hwritereg=1;
        haddr=32'h80000001; haddr1=32'h80000001; haddr2=32'h80000001;
        hwdata=32'hAA; hwdata1=32'hAA; hwdata2=32'hAA;

        @(posedge hclk) #1;
        valid=0; hwrite=0; hwritereg=0;
        tempselx=3'b000;

        #50;

        // single read
        @(posedge hclk) #1;
        valid=1; hwrite=0; hwritereg=0;
        haddr=32'h80000002; haddr1=32'h80000002; haddr2=32'h0;
        tempselx=3'b001;

        @(posedge hclk) #1;
        valid=0; hwrite=0; hwritereg=0;

        #50;

        // burst write
        @(posedge hclk) #1;
        valid=1; hwrite=1; hwritereg=0;
        haddr=32'h80000003; haddr1=32'h80000003; haddr2=32'h0;
        hwdata=32'hB1; hwdata1=32'hB1; hwdata2=32'h0;
        tempselx=3'b001;

        @(posedge hclk) #1;
        valid=1; hwrite=1; hwritereg=1;
        haddr=32'h80000004; haddr1=32'h80000004; haddr2=32'h80000003;
        hwdata=32'hB2; hwdata1=32'hB2; hwdata2=32'hB1;

        @(posedge hclk) #1;
        valid=1; hwrite=1; hwritereg=1;
        haddr=32'h80000005; haddr1=32'h80000005; haddr2=32'h80000004;
        hwdata=32'hB3; hwdata1=32'hB3; hwdata2=32'hB2;

        @(posedge hclk) #1;
        valid=0; hwrite=0; hwritereg=0;
        tempselx=3'b000;

        #200;
    end

    initial begin
        $dumpfile("tb_apb.vcd");
        $dumpvars(0, tb_apb);
    end

endmodule