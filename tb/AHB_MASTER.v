module AHB_Master(
    input hclk,
    input hresetn,
    input hreadyout,
    input [31:0] hrdata,
    output reg [31:0] haddr,
    output reg [31:0] hwdata,
    output reg hwrite,
    output reg hreadyin,
    output reg [1:0] htrans
);

    reg [2:0] hburst;
    reg [2:0] hsize;
    integer i;

    task single_write();
        begin
            @(posedge hclk) #1;
            begin
                hwrite   = 1;
                htrans   = 2'd2;
                hsize    = 0;
                hburst   = 0;
                hreadyin = 1;
                haddr    = 32'h8000_0001;
            end

            @(posedge hclk) #1;
            begin
                hwrite   = 1;
                htrans   = 2'd2;
                hsize    = 0;
                hburst   = 0;
                hreadyin = 1;
                haddr    = 32'h8000_0001;
            end

            @(posedge hclk) #1;
            begin
                htrans   = 2'd0;
                hwdata   = 8'h80;
            end
        end
    endtask

    task single_read();
        begin
            @(posedge hclk) #1;
            begin
                hwrite   = 0;
                htrans   = 2'd2;
                hsize    = 0;
                hburst   = 0;
                hreadyin = 1;
                haddr    = 32'h8000_0001;
            end

            @(posedge hclk) #1;
            begin
                htrans   = 2'd0;
            end
        end
    endtask

    task burst_write();
        begin
            @(posedge hclk) #1;
            begin
                hwrite   = 1'b1;
                htrans   = 2'd2;
                hsize    = 0;
                hburst   = 3'd3;
                hreadyin = 1;
                haddr    = 32'h8000_0001;
            end

            @(posedge hclk) #1;
            begin
                haddr    = haddr + 1'b1;
                hwdata   = {$random} % 256;
                htrans   = 2'd3;
            end

            for (i = 0; i < 2; i = i + 1) begin
                @(posedge hclk) #1;
                begin
                    haddr    = haddr + 1;
                    hwdata   = {$random} % 256;
                    htrans   = 2'd3;
                end
            end

            @(posedge hclk) #1;
            begin
                hwdata   = {$random} % 256;
                htrans   = 2'd0;
            end
        end
    endtask

    initial
        begin
            hwrite   = 0;
            hreadyin = 1;
            htrans   = 2'd0;
            hwdata   = 32'd0;
            haddr    = 32'd0;
            hburst   = 3'd0;
            hsize    = 3'd0;
        end

    initial
        begin
            @(negedge hresetn);
            @(posedge hresetn);
            //single_write();
            //single_read();
            burst_write();
        end

endmodule