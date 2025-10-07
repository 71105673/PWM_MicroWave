`timescale 1ns / 1ps

module tb_btn_debounce();

    reg clk, rst, i_btn;
    wire o_btn;

    btn_debounce dut(
        .clk(clk),
        .rst(rst),
        .i_btn(i_btn),
        .o_btn(o_btn)
    );

    always #5 clk = ~clk;

    initial begin
        clk=0; rst=1; i_btn=0;
        #25;
        rst=0;
        #10;
        i_btn=1;
        #20;
        i_btn=0;
        #20;
        i_btn=1;
        #20;
        i_btn=0;
        #20;
        i_btn=1;
        #10000;
        i_btn=0;
        #20;
        i_btn=1;
        #20;
        i_btn=0;
        #100000;
        
        i_btn=1;
        #20;
        i_btn=0;
        #20;
        i_btn=1;
        #20;
        i_btn=0;
        #20;
        i_btn=1;
        #10000;
        i_btn=0;
        #20;
        i_btn=1;
        #20;
        i_btn=0;
        #100000;

        $stop;

    end

endmodule
