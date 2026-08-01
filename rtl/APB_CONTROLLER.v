module apb_controller(
    hclk, hresetn, valid, hwrite, haddr, hwdata,
    haddr1, haddr2, hwdata1, hwdata2,
    hwritereg, tempselx, hreadyout,
    pselx, penable, pwrite, paddr, pwdata
);

    input valid, hwritereg, hclk, hresetn, hwrite;
    input [31:0] haddr1, haddr2, hwdata1, hwdata2, haddr, hwdata;
    input [2:0] tempselx;

    output reg pwrite, penable;
    output reg [2:0] pselx;
    output reg hreadyout;
    output reg [31:0] pwdata, paddr;


    parameter st_idle     = 3'b000;
    parameter st_wait     = 3'b001;
    parameter st_write    = 3'b010;
    parameter st_writep   = 3'b011;
    parameter st_wenableb = 3'b100;
    parameter st_wenable  = 3'b101;
    parameter st_read     = 3'b110;
    parameter st_renable  = 3'b111;


    reg [2:0] state, next_state;

    reg [31:0] paddr_temp, pwdata_temp;
    reg penable_temp, pwrite_temp, hreadyout_temp;
    reg [2:0] pselx_temp;



    // State register
    always @(posedge hclk)
    begin
        if(!hresetn)
            state <= st_idle;
        else
            state <= next_state;
    end



    // Next state logic
    always @(*)
    begin

        case(state)

            st_idle:
            begin
                if(valid && hwrite)
                    next_state = st_wait;

                else if(valid && !hwrite)
                    next_state = st_read;

                else
                    next_state = st_idle;
            end



            st_wait:
            begin
                if(valid)
                    next_state = st_writep;
                else
                    next_state = st_write;
            end



            st_writep:
            begin
                next_state = st_wenableb;
            end



            st_write:
            begin
                if(valid)
                    next_state = st_writep;
                else
                    next_state = st_wenable;
            end



            st_wenableb:
            begin
                if(valid && hwritereg)
                    next_state = st_writep;

                else if(!hwritereg)
                    next_state = st_read;

                else if(!valid)
                    next_state = st_write;

                else
                    next_state = st_wenableb;
            end



            st_wenable:
            begin
                if(valid && !hwrite)
                    next_state = st_read;

                else if(!valid)
                    next_state = st_idle;

                else
                    next_state = st_wenable;
            end



            st_read:
            begin
                next_state = st_renable;
            end



            st_renable:
            begin
                if(valid && !hwrite)
                    next_state = st_read;

                else if(valid && hwrite)
                    next_state = st_wait;

                else if(!valid)
                    next_state = st_idle;

                else
                    next_state = st_renable;
            end



            default:
                next_state = st_idle;

        endcase

    end





    // Temporary output logic
    always @(*)
    begin

        // Default assignments (prevents latches)
        paddr_temp     = paddr;
        pwdata_temp    = pwdata;
        pwrite_temp    = pwrite;
        pselx_temp     = pselx;
        penable_temp   = penable;
        hreadyout_temp = hreadyout;



        case(state)



            st_idle:
            begin
                if(valid && !hwrite)
                begin
                    paddr_temp     = haddr;
                    pwrite_temp    = hwrite;
                    pselx_temp     = tempselx;
                    penable_temp   = 0;
                    hreadyout_temp = 0;
                end

                else if(valid && hwrite)
                begin
                    pselx_temp     = 0;
                    penable_temp   = 0;
                    hreadyout_temp = 1;
                end

                else
                begin
                    pselx_temp     = 0;
                    penable_temp   = 0;
                    hreadyout_temp = 1;
                end
            end





            st_read:
            begin
                penable_temp   = 1;
                hreadyout_temp = 1;
            end





            st_renable:
            begin
                if(valid && !hwrite)
                begin
                    paddr_temp     = haddr;
                    pwrite_temp    = hwrite;
                    pselx_temp     = tempselx;
                    penable_temp   = 0;
                    hreadyout_temp = 0;
                end

                else if(valid && hwrite)
                begin
                    pselx_temp     = 0;
                    penable_temp   = 0;
                    hreadyout_temp = 1;
                end

                else
                begin
                    pselx_temp     = 0;
                    penable_temp   = 0;
                    hreadyout_temp = 1;
                end
            end





            st_wait:
            begin
                paddr_temp     = haddr1;
                pwdata_temp    = hwdata;
                pwrite_temp    = hwrite;
                pselx_temp     = tempselx;
                penable_temp   = 0;
                hreadyout_temp = 0;
            end





            st_write:
            begin
                penable_temp   = 1;
                hreadyout_temp = 1;
            end





            st_wenable:
            begin

                if(valid && !hwrite)
                begin
                    hreadyout_temp = 1;
                    pselx_temp     = 0;
                    penable_temp   = 0;
                end

                else if(valid && hwrite)
                begin
                    paddr_temp     = haddr1;
                    pwrite_temp    = hwritereg;
                    pselx_temp     = tempselx;
                    penable_temp   = 0;
                end

            end





            st_writep:
            begin
                penable_temp   = 1;
                hreadyout_temp = 1;
            end





            st_wenableb:
            begin
                paddr_temp     = haddr1;
                pwdata_temp    = hwdata;
                pwrite_temp    = hwrite;
                pselx_temp     = tempselx;
                penable_temp   = 0;
                hreadyout_temp = 0;
            end


        endcase

    end





    // Registered outputs
    always @(posedge hclk)
    begin

        if(!hresetn)
        begin
            paddr     <= 0;
            pwdata    <= 0;
            pwrite    <= 0;
            pselx     <= 0;
            penable   <= 0;
            hreadyout <= 1;
        end

        else
        begin
            paddr     <= paddr_temp;
            pwdata    <= pwdata_temp;
            pwrite    <= pwrite_temp;
            pselx     <= pselx_temp;
            penable   <= penable_temp;
            hreadyout <= hreadyout_temp;
        end

    end


endmodule