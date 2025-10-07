`timescale 1ns / 1ps

module motor_controller (
    input  clk,
    input  rst,
    input  run,
    output pwm
);

  reg [2:0] r_duty;
  wire w_10mhz_tick;

  clk_10mhz_tick U_CLK_DIV_10MHZ (
      .clk(clk),
      .rst(rst),
      .tick_10mhz(w_10mhz_tick)
  );

  assign pwm = (r_duty > 3) ? 1 : 0;

  always @(posedge clk, posedge rst) begin
    if (rst) begin
      r_duty <= 0;
    end else begin
      if (run) begin
        if (w_10mhz_tick) begin
            if (r_duty == (10-1)) begin
                r_duty <= 0;
            end
            else begin
                r_duty <= r_duty + 1;
            end    
        end
      end
      else begin
        r_duty <= 0;
      end
    end
  end

endmodule

module clk_10mhz_tick (
    input  clk,
    input  rst,
    output tick_10mhz
);

  reg [3:0] r_cnt_10mhz;

  assign tick_10mhz = (r_cnt_10mhz == (10 - 1)) ? 1 : 0;

  always @(posedge clk, posedge rst) begin
    if (rst) begin
      r_cnt_10mhz <= 0;
    end else begin
      if (r_cnt_10mhz == (10 - 1)) begin
        r_cnt_10mhz <= 0;
      end else begin
        r_cnt_10mhz <= r_cnt_10mhz + 1;
      end
    end
  end

endmodule
