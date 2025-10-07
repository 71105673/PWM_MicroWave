`timescale 1ns / 1ps

module microwave_dp (
    input        clk,
    input        rst,
    input  [1:0] btn,    //u,d
    input  [1:0] sel,    //min,sec
    input        run,
    output [5:0] min,
    output [5:0] sec,
    output       finish
);

  parameter COUNT = 60;

  reg [$clog2(COUNT)-1:0] min_reg, min_next, sec_reg, sec_next;
  reg finish_reg, finish_next;
  wire w_tick_1khz, w_tick_sec;

  tick_gen_1khz U_TICK_GEN_1KHZ (
      .clk(clk),
      .rst(rst),
      .tick_1khz(w_tick_1khz)
  );

  tick_cnt_sec U_TICK_CNT_SEC (
      .clk(clk),
      .rst(rst),
      .tick_1khz(w_tick_1khz),
      .run(run),
      .tick_sec(w_tick_sec)
  );

  assign min = min_reg;
  assign sec = sec_reg;
  assign finish = finish_reg;

  always @(posedge clk, posedge rst) begin
    if (rst) begin
      min_reg <= 0;
      sec_reg <= 0;
      finish_reg <= 0;
    end else begin
      min_reg <= min_next;
      sec_reg <= sec_next;
      finish_reg <= finish_next;
    end
  end

  always @(*) begin
    min_next = min_reg;
    sec_next = sec_reg;
    finish_next = 0;
    case ({
      run, sel
    })
      3'b001: begin  //sec setting
        case (btn)
          2'b01: begin  //down
            if (sec_reg == 0) begin
              sec_next = COUNT - 1;
            end else begin
              sec_next = sec_reg - 1;
            end
          end
          2'b10: begin  //up
            if (sec_reg == COUNT - 1) begin
              sec_next = 0;
            end else begin
              sec_next = sec_reg + 1;
            end
          end
        endcase
      end
      3'b010: begin  //min setting
        case (btn)
          2'b01: begin  //down
            if (min_reg == 0) begin
              min_next = COUNT - 1;
            end else begin
              min_next = min_reg - 1;
            end
          end
          2'b10: begin  //up
            if (min_reg == COUNT - 1) begin
              min_next = 0;
            end else begin
              min_next = min_reg + 1;
            end
          end
        endcase
      end
      3'b100: begin  //run
        if (w_tick_sec) begin
          if ((min_reg == 0) && (sec_reg == 0)) begin
            finish_next = 1;
            sec_next = 0;
          end else if ((min_reg > 0) && (sec_reg == 0)) begin
            min_next = min_reg - 1;
            sec_next = COUNT - 1;
          end else begin  //sec_reg > 0
            sec_next = sec_reg - 1;
          end
        end
      end
    endcase
  end

endmodule

module tick_gen_1khz (
    input clk,
    input rst,
    output reg tick_1khz
);

  parameter COUNT_TICK = 100;  //100_000

  reg [$clog2(COUNT_TICK)-1:0] r_tick;

  always @(posedge clk, posedge rst) begin
    if (rst) begin
      r_tick <= 0;
      tick_1khz <= 0;
    end else begin
      if (r_tick == COUNT_TICK - 1) begin
        r_tick <= 0;
        tick_1khz <= 1;
      end else begin
        r_tick <= r_tick + 1;
        tick_1khz <= 0;
      end
    end
  end

endmodule

module tick_cnt_sec (
    input clk,
    input rst,
    input tick_1khz,
    input run,
    output reg tick_sec
);

  parameter COUNT_SEC = 10;  //1000

  reg [$clog2(COUNT_SEC)-1:0] r_tick_sec;

  always @(posedge clk, posedge rst) begin
    if (rst) begin
      r_tick_sec <= 0;
      tick_sec   <= 0;
    end else begin
      if (run & tick_1khz) begin
        if (r_tick_sec == COUNT_SEC - 1) begin
          r_tick_sec <= 0;
          tick_sec   <= 1;
        end else begin
          r_tick_sec <= r_tick_sec + 1;
        end
      end else if (run) begin
        r_tick_sec <= r_tick_sec;
        tick_sec   <= 0;
      end else begin
        r_tick_sec <= 0;
        tick_sec   <= 0;
      end
    end
  end

endmodule
