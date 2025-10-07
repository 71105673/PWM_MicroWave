`timescale 1ns / 1ps

module fnd_controller (
    input        clk,
    input        reset,
    input  [5:0] sec,
    input  [5:0] min,
    output [7:0] fnd_data,
    output [3:0] fnd_com
);

    parameter DP_OFF = 4'hf;

    wire [3:0] w_bcd, w_sec_1, w_sec_10, w_min_1, w_min_10;
    wire w_oclk;
    wire [2:0] fnd_sel;
    wire [3:0] w_dot;

    //instantiation

    clk_div_tick U_Clk_Div (
        .clk  (clk),
        .reset(reset),
        .o_clk(w_oclk)
    );
    
    counter_8 U_Coutner_8 (
        .clk(clk),
        .reset(reset),
        .div_clk(w_oclk),
        .fnd_sel(fnd_sel)
    );

    decoder_2x4 U_Decoder_2x4 (
        .fnd_sel(fnd_sel[1:0]),
        .fnd_com(fnd_com)
    );

    digit_splitter #(
        .BIT_WIDTH(6)
    ) U_DS_SEC (
        .time_data(sec),
        .digit_1  (w_sec_1),
        .digit_10 (w_sec_10)
    );

    digit_splitter #(
        .BIT_WIDTH(6)
    ) U_DS_MIN (
        .time_data(min),
        .digit_1  (w_min_1),
        .digit_10 (w_min_10)
    );

    comp_dot_4 U_DOT (
        .clk(o_clk),
        .dot (w_dot)
    );

    mux_8x1 U_MUX_MIN_SEC_8x1 (
        .digit_1(w_sec_1),
        .digit_10(w_sec_10),
        .digit_100(w_min_1),
        .digit_1000(w_min_10),
        .dp_1(DP_OFF),
        .dp_10(DP_OFF),
        .dp_100(w_dot),
        .dp_1000(DP_OFF),
        .sel(fnd_sel),
        .bcd(w_bcd)
    );

    bcd U_BCD (
        .bcd(w_bcd),
        .fnd_data(fnd_data)
    );

endmodule

//clk divider
//1kHz
module clk_div_tick (
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

//8진 카운터
module counter_8 (
    input        clk,
    input        reset,
    input        div_clk,
    output [2:0] fnd_sel
);
    reg [2:0] r_counter;

    assign fnd_sel = r_counter;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <= 0;
        end else begin
            if (div_clk) begin
                r_counter <= r_counter + 1;
            end
        end
    end

endmodule

module decoder_2x4 (
    input      [1:0] fnd_sel,
    output reg [3:0] fnd_com
);

    always @(fnd_sel) begin
        case (fnd_sel)
            2'b00:   fnd_com = 4'b1110;
            2'b01:   fnd_com = 4'b1101;
            2'b10:   fnd_com = 4'b1011;
            2'b11:   fnd_com = 4'b0111;
            default: fnd_com = 4'b1111;
        endcase
    end

endmodule

module comp_dot_4 (
    input  clk,
    output [3:0] dot
);

    reg [6:0] r_dot;

    assign dot = (r_dot > (50-1)) ? 4'he : 4'hf;

    always @(posedge clk) begin
        if (r_dot == (100-1)) begin
            r_dot <= 0;
        end
        else begin
            r_dot <= r_dot + 1;
        end
    end

endmodule

module mux_8x1 (
    input  [3:0] digit_1,
    input  [3:0] digit_10,
    input  [3:0] digit_100,
    input  [3:0] digit_1000,
    input  [3:0] dp_1,
    input  [3:0] dp_10,
    input  [3:0] dp_100,
    input  [3:0] dp_1000,
    input  [2:0] sel,
    output [3:0] bcd
);

    reg [3:0] r_bcd;

    assign bcd = r_bcd;

    //4:1 mux using always
    //case 나 if문에서 default와 else를 붙여 latch 생성을 방지하는 것이 바람직하다.
    always @(*) begin
        case (sel)
            3'b000: r_bcd = digit_1;
            3'b001: r_bcd = digit_10;
            3'b010: r_bcd = digit_100;
            3'b011: r_bcd = digit_1000;
            3'b100: r_bcd = dp_1;
            3'b101: r_bcd = dp_10;
            3'b110: r_bcd = dp_100;
            3'b111: r_bcd = dp_1000;
        endcase
    end

endmodule

module digit_splitter #(
    parameter BIT_WIDTH = 6
) (
    input  [BIT_WIDTH-1:0] time_data,
    output [          3:0] digit_1,
    output [          3:0] digit_10
);

    assign digit_1  = time_data % 10;
    assign digit_10 = (time_data / 10) % 10;


endmodule

module bcd (
    input  [3:0] bcd,
    output [7:0] fnd_data
);

    reg [7:0] r_fnd_data;

    assign fnd_data = r_fnd_data;

    //combinational modeling
    always @(bcd) begin
        case (bcd)
            4'h0: r_fnd_data = 8'hc0;
            4'h1: r_fnd_data = 8'hf9;
            4'h2: r_fnd_data = 8'ha4;
            4'h3: r_fnd_data = 8'hb0;
            4'h4: r_fnd_data = 8'h99;
            4'h5: r_fnd_data = 8'h92;
            4'h6: r_fnd_data = 8'h82;
            4'h7: r_fnd_data = 8'hf8;
            4'h8: r_fnd_data = 8'h80;
            4'h9: r_fnd_data = 8'h90;
            4'he: r_fnd_data = 8'h7f;
            default: r_fnd_data = 8'hff;
        endcase
    end

endmodule
