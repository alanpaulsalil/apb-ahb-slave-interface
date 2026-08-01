module tb_ahb_slave;

    reg hclk, hresetn;
    reg [31:0] prdata;

    wire hwrite, hreadyin;
    wire [1:0] htrans;
    wire [31:0] hwdata, haddr;
    wire hreadyout;

    wire valid, hwrite_reg;
    wire [31:0] haddr_1, haddr_2;
    wire [31:0] hwdata_1, hwdata_2;
    wire [2:0] temp_selx;
    wire [31:0] hrdata;
    wire [1:0] hresp;

    AHB_Master ahb_m(
        .hclk(hclk),
        .hresetn(hresetn),
        .hreadyout(1'b1),
        .hrdata(hrdata),
        .haddr(haddr),
        .hwdata(hwdata),
        .hwrite(hwrite),
        .hreadyin(hreadyin),
        .htrans(htrans)
    );

    AHB_slave_interface ahb_s(
        .hclk(hclk),
        .hresetn(hresetn),
        .hwrite(hwrite),
        .hreadyin(hreadyin),
        .htrans(htrans),
        .hwdata(hwdata),
        .haddr(haddr),
        .prdata(prdata),
        .valid(valid),
        .hwrite_reg(hwrite_reg),
        .haddr_1(haddr_1),
        .haddr_2(haddr_2),
        .hwdata_1(hwdata_1),
        .hwdata_2(hwdata_2),
        .temp_selx(temp_selx),
        .hrdata(hrdata),
        .hresp(hresp)
    );

    initial hclk = 0;
    always #5 hclk = ~hclk;

    initial begin
        hresetn = 0;
        prdata  = 32'hDEADBEEF;
        #15;
        hresetn = 1;
        #300;
        $finish;
    end

    initial begin
        $dumpfile("tb_ahb_slave.vcd");
        $dumpvars(0, tb_ahb_slave);
    end

endmodule