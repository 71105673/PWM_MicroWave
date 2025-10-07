`timescale 1ns / 1ps

module tb_microwave();

reg clk, rst, sw0;
reg [3:0] btn;
wire led, pwm_out;
wire [1:0] motor_dir;
wire [3:0] fnd_com;
wire [7:0] fnd_data;

microwave_top dut(
    .clk(clk),
    .rst(rst),
    .sw0(sw0),
    .btn(btn),
    .led(led),
    .pwm_out(pwm_out),
    .motor_dir(motor_dir),
    .fnd_com(fnd_com),
    .fnd_data(fnd_data)
);

always #5 clk = ~clk;

initial begin
    clk = 0; rst = 1; sw0 = 0; btn = 0;
    #25;
    rst = 0;
    #10;
    sw0=1;
    #10;
    btn = 4'b0001;//R
    #1000;
    btn=4'b0000;
    #10;
    btn = 4'b1000;//U
    #1000;
    btn = 4'b0000;
    #10;
    btn = 4'b0010;//L
    #1000;
    btn = 4'b0000;
    #1000000;
    btn = 4'b0010;//L
    #1000;
    btn = 4'b0000;
    #10;
    sw0 = 0;

    #1000000;

    $stop;

end

endmodule
