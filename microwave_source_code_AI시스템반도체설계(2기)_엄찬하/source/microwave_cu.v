`timescale 1ns / 1ps

module microwave_cu (
    input        clk,
    input        rst,
    input        sw0,
    input        finish,
    input  [1:0] Btn,     //L,R
    output [1:0] sel,     //min, sec
    output       run,
    output       toggle
);

  localparam IDLE = 0, SELECT_SEC = 1, SELECT_MIN = 2, RUN = 3, FINISH = 4;

  reg [2:0] n_state, c_state;

  always @(posedge clk, posedge rst) begin
    if (rst) begin
      c_state <= IDLE;
    end else begin
      c_state <= n_state;
    end
  end

  always @(*) begin
    n_state = c_state;
    case (c_state)
      IDLE: begin
        if (sw0) begin
          n_state = SELECT_SEC;
        end
      end
      SELECT_SEC: begin
        if (!sw0) begin
          n_state = IDLE;
        end else if (Btn[1]) begin
          n_state = RUN;
        end else if (Btn[0]) begin
          n_state = SELECT_MIN;
        end
      end
      SELECT_MIN: begin
        if (!sw0) begin
          n_state = IDLE;
        end else if (Btn[1]) begin
          n_state = RUN;
        end else if (Btn[0]) begin
          n_state = SELECT_SEC;
        end
      end
      RUN: begin
        if (Btn[1] || finish) begin
          n_state = FINISH;
        end
      end
      FINISH: begin
        if (Btn[1]) begin
          n_state = IDLE;
        end
      end
    endcase
  end

  assign sel[0] = (c_state == SELECT_SEC) ? 1 : 0;
  assign sel[1] = (c_state == SELECT_MIN) ? 1 : 0;
  assign run    = (c_state == RUN) ? 1 : 0;
  assign toggle = (c_state == FINISH) ? 1 : 0;

endmodule
