`timescale 1ns / 1ps

module btn_debounce (
    input      clk,
    input      rst,
    input      i_btn,
    output     o_btn
);

    reg prev_btn, r_start;
    wire w_tick, w_10ms;

    tick_gen_100kHz U_TICK_GEN (  //100kHz tick
        .clk(clk),
        .rst(rst),
        .tick_100kHz(w_tick)
    );
    tick_counter U_TICK_CNT (  //tick count 10ms
        .clk(clk),
        .tick(w_tick),
        .rst(rst),
        .start(r_start),
        .cnt_10ms(w_10ms)
    );

    assign o_btn = w_10ms & i_btn & (~prev_btn);

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            prev_btn <= 1'b0;
            r_start <= 1'b0;
        end
        else begin
            if (w_10ms) begin
                r_start <= 1'b0;
                prev_btn <= i_btn;
            end
            else if (i_btn && (~prev_btn)) begin //btn rising edge
                r_start <= 1'b1;
            end
            else if (~i_btn) begin
                prev_btn <= 1'b0;
            end
            else begin
                r_start <= r_start;
                prev_btn <= prev_btn;
            end
        end
    end

endmodule

module tick_gen_100kHz (  //100kHz tick
    input      clk,
    input      rst,
    output reg tick_100kHz
);

    parameter COUNT = 10;//1000

    reg [$clog2(COUNT)-1:0] r_count;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            r_count <= 1'b0;
            tick_100kHz <= 1'b0;
        end else begin
            if (r_count == COUNT - 1) begin
                r_count <= 0;
                tick_100kHz <= 1'b1;
            end else begin
                r_count <= r_count + 1'b1;
                tick_100kHz <= 1'b0;
            end
        end
    end

endmodule

module tick_counter (  //tick count 10ms
    input      clk,
    input      rst,
    input      tick,
    input      start,
    output reg cnt_10ms
);

    parameter COUNT = 10;//1000

    reg [$clog2(COUNT)-1:0] r_tick_count;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            r_tick_count <= 0;
            cnt_10ms <= 0;
        end else begin
            cnt_10ms <= 0;
            if (start && tick) begin
                if (r_tick_count == COUNT - 1) begin
                    r_tick_count <= 0;
                    cnt_10ms <= 1;
                end else begin
                    r_tick_count <= r_tick_count + 1'b1;
                end
            end
            else if (~start)begin
                r_tick_count <= 0;
            end
            else begin
                r_tick_count <= r_tick_count;
            end
        end
    end

endmodule
