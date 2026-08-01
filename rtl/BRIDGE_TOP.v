module Bridge_top(

    input hclk,
    input hresetn,
    input hwrite,
    input hreadyin,

    input [1:0] htrans,
    input [31:0] hwdata,
    input [31:0] haddr,
    input [31:0] prdata,

    output pwrite,
    output penable,
    output hreadyout,

    output [2:0] psel,

    output [31:0] paddr,
    output [31:0] pwdata,
    output [31:0] hrdata,

    output [1:0] hresp
);


wire valid;

wire [31:0] hwdata_1;
wire [31:0] hwdata_2;

wire [31:0] haddr_1;
wire [31:0] haddr_2;

wire [2:0] temp_selx;

wire hwrite_reg;



// AHB Slave Interface

AHB_slave_interface ahb_s
(
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




// APB Controller

apb_controller apb_c
(
    .hclk(hclk),
    .hresetn(hresetn),

    .valid(valid),

    .hwrite(hwrite),

    .haddr(haddr),
    .haddr1(haddr_1),
    .haddr2(haddr_2),

    .hwdata(hwdata),
    .hwdata1(hwdata_1),
    .hwdata2(hwdata_2),

    .hwritereg(hwrite_reg),

    .tempselx(temp_selx),

    .hreadyout(hreadyout),

    .pselx(psel),

    .penable(penable),

    .pwrite(pwrite),

    .paddr(paddr),

    .pwdata(pwdata)
);


endmodule