module AHB_slave_interface(
    input hclk,
    input hresetn,
    input hwrite,
    input hreadyin,
    input [1:0] htrans,
    input [31:0] hwdata,
    input [31:0] haddr,
    input [31:0] prdata,
    output reg valid,
    output reg hwrite_reg,
    output reg [31:0] haddr_1,
    output reg [31:0] haddr_2,
    output reg [31:0] hwdata_1,
    output reg [31:0] hwdata_2,
    output reg [2:0] temp_selx,
    output reg [31:0] hrdata,
    output [1:0] hresp
);

    always@(posedge hclk)
        begin
            if(!hresetn)
                begin
                    haddr_1 <= 32'd0;
                    haddr_2 <= 32'd0;
                end
            else
                begin
                    haddr_1 <= haddr;
                    haddr_2 <= haddr_1;
                end
        end

    always@(posedge hclk)
        begin
            if(!hresetn)
                begin
                    hwrite_reg <= 1'b0;
                end
            else
                begin
                    hwrite_reg <= hwrite;
                end
        end

    always@(posedge hclk)
        begin
            if(!hresetn)
                begin
                    hwdata_1 <= 32'd0;
                    hwdata_2 <= 32'd0;
                end
            else
                begin
                    hwdata_1 <= hwdata;
                    hwdata_2 <= hwdata_1;
                end
        end

    always@(*)
        begin
            if(haddr >= 32'h80000000 && haddr < 32'h84000000)
                temp_selx = 3'b001;
            else if(haddr >= 32'h84000000 && haddr < 32'h88000000)
                temp_selx = 3'b010;
            else if(haddr >= 32'h88000000 && haddr < 32'h8C000000)
                temp_selx = 3'b100;
            else
                temp_selx = 3'b000;
        end

    always@(*)
        begin
            if((haddr >= 32'h80000000 && haddr < 32'h8C000000) && (hreadyin == 1'b1) && (htrans == 2'b10 || htrans == 2'b11))
                valid = 1'b1;
            else
                valid = 1'b0;
        end

    always@(posedge hclk)
        begin
            if(!hresetn)
                hrdata <= 32'd0;
            else
                hrdata <= prdata;
        end

    assign hresp = 2'b00;

endmodule