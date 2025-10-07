`timescale 1ns / 1ps

module led_controller (
    input        clk,
    input        rst,
    input  [1:0] sel,  // finish, setting
    output       led
);

  reg [5:0] r_cnt;
  reg r_led;
  wire w_clk_tick_1khz;

  clk_div U_CLK_DIV_TICK (
      .clk  (clk),
      .reset(rst),
      .o_clk(w_clk_tick_1khz)
  );

  assign led = sel[1] ? r_led : (sel[0] ? 1 : 0);

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      r_cnt <= 0;
      r_led <= 0;
    end else begin
      if (w_clk_tick_1khz && sel[1]) begin
        if (r_cnt == 50) begin
          r_cnt <= 0;
          r_led <= ~r_led;
        end else begin
          r_cnt <= r_cnt + 1;
          r_led <= r_led;
        end
      end
    end
  end

endmodule

//clk divider
//1kHz
module clk_div (
    input  clk,
    input  reset,
    output o_clk
);
  reg r_clk;
  //reg [16:0] r_counter;
  reg [$clog2(100)-1:0] r_counter; //100_000

  assign o_clk = r_clk;

  always @(posedge clk, posedge reset) begin
    if (reset) begin
      r_counter <= 1'b0;
      r_clk <= 1'b0;
    end else begin
      if (r_counter == 100 - 1) begin  //1kHz period 100_000
        r_counter <= 0;
        r_clk <= 1'b1;
      end else begin
        r_counter <= r_counter + 1;
        r_clk <= 1'b0;
      end
    end
  end

endmodule
