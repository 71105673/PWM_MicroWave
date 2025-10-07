`timescale 1ns / 1ps

module microwave_top (
    input        clk,
    input        rst,
    input        sw0,
    input  [3:0] btn,
    output       led,
    output       pwm_out,
    output [1:0] motor_dir,
    output [3:0] fnd_com,
    output [7:0] fnd_data
);

  wire [3:0] w_debounced_btn;  //u,d,l,r
  wire [1:0] w_sel;
  wire w_run, w_finish, w_toggle;
  wire [5:0] w_min_data, w_sec_data;

  btn_debouncing U_BTN_DEBOUNCING (
      .clk(clk),
      .rst(rst),
      .btn(btn),
      .debounced_btn(w_debounced_btn)
  );

  microwave_cu U_MICROWAVE_CU (
      .clk(clk),
      .rst(rst),
      .sw0(sw0),
      .finish(w_finish),
      .Btn(w_debounced_btn[1:0]),  //L,R
      .sel(w_sel),  //min, sec
      .run(w_run),
      .toggle(w_toggle)
  );

  microwave_dp U_MICROWAVE_DP (
      .clk(clk),
      .rst(rst),
      .btn(w_debounced_btn[3:2]),  //u,d
      .sel(w_sel),  //min,sec
      .run(w_run),
      .min(w_min_data),
      .sec(w_sec_data),
      .finish(w_finish)
  );

  fnd_controller U_FND_CNTL (
      .clk(clk),
      .reset(rst),
      .sec(w_sec_data),
      .min(w_min_data),
      .fnd_data(fnd_data),
      .fnd_com(fnd_com)
  );

  led_controller U_LED_CNTL (
      .clk(clk),
      .rst(rst),
      .sel({w_toggle, (|w_sel)}),  // finish, setting
      .led(led)
  );

  motor_controller U_MOTOR_CNTL (
      .clk(clk),
      .rst(rst),
      .run(w_run),
      .pwm(pwm_out)
  );

  assign motor_dir = 2'b10;  //forward

endmodule

module btn_debouncing (
    input        clk,
    input        rst,
    input  [3:0] btn,
    output [3:0] debounced_btn
);

  btn_debounce U_BTN_DEBOUNCE_UP (  //u
      .clk  (clk),
      .rst  (rst),
      .i_btn(btn[3]),
      .o_btn(debounced_btn[3])
  );

  btn_debounce U_BTN_DEBOUNCE_DOWN (  //d
      .clk  (clk),
      .rst  (rst),
      .i_btn(btn[2]),
      .o_btn(debounced_btn[2])
  );

  btn_debounce U_BTN_DEBOUNCE_LEFT (  //l
      .clk  (clk),
      .rst  (rst),
      .i_btn(btn[1]),
      .o_btn(debounced_btn[1])
  );

  btn_debounce U_BTN_DEBOUNCE_RIGHT (  //r
      .clk  (clk),
      .rst  (rst),
      .i_btn(btn[0]),
      .o_btn(debounced_btn[0])
  );

endmodule
