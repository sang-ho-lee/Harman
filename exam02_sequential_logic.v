`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////



module and_gate(
    input A,
    input B, 
    output F
    );
    
    and (F, A, B);
    
endmodule

module half_adder_structural(  //aaaa
    input A, B,
    output sum, carry
    );
    
    xor (sum, A, B);
    and (carry, A, B);
    
endmodule   

module half_adder_behavioral(
    input A, B,
    output reg sum, carry
    );

    always @(A, B)begin
        case({A, B})
            2'b00: begin sum = 0; carry = 0; end
            2'b01: begin sum = 1; carry = 0; end
            2'b10: begin sum = 1; carry = 0; end
            2'b11: begin sum = 0; carry = 1; end
        endcase
    end

endmodule

module half_adder_dataflow(
    input A, B,
    output sum, carry
    );
    
    wire [1:0] sum_value;
    
    assign sum_value = A + B;
    
    assign sum = sum_value[0];
    assign carry = sum_value[1];

endmodule

module full_adder_structural(
    input A, B, cin,
    output sum, carry);
    
    wire sum_0, carry_0, carry_1;
    
    half_adder_structural ha0 (.A(A), .B(B), .sum(sum_0), .carry(carry_0));
    half_adder_structural ha1 (.A(sum_0), .B(cin), .sum(sum), .carry(carry_1));
    
    or (carry, carry_0, carry_1);

endmodule

module full_adder_behavioral(
    input A, B, cin,
    output reg sum, carry);
    
    always @(A, B, cin)begin
        case({A, B, cin})
            3'b000: begin sum = 0; carry = 0; end
            3'b001: begin sum = 1; carry = 0; end
            3'b010: begin sum = 1; carry = 0; end
            3'b011: begin sum = 0; carry = 1; end
            3'b100: begin sum = 1; carry = 0; end
            3'b101: begin sum = 0; carry = 1; end
            3'b110: begin sum = 0; carry = 1; end
            3'b111: begin sum = 1; carry = 1; end
        endcase
    end

endmodule

module full_adder_dataflow(
    input A, B, cin,
    output sum, carry
    );
    
    wire [1:0] sum_value;
    
    assign sum_value = A + B + cin;
    
    assign sum = sum_value[0];
    assign carry = sum_value[1];

endmodule

module fadder_4bit_s(
    input [3:0] A, B,
    input cin,
    output [3:0] sum,
    output carry);
    
    wire [2:0] carry_w;
    
    full_adder_structural fa0 (.A(A[0]), .B(B[0]), 
            .cin(cin), .sum(sum[0]), .carry(carry_w[0]));
    full_adder_structural fa1 (.A(A[1]), .B(B[1]), 
            .cin(carry_w[0]), .sum(sum[1]), .carry(carry_w[1]));
    full_adder_structural fa2 (.A(A[2]), .B(B[2]), 
            .cin(carry_w[1]), .sum(sum[2]), .carry(carry_w[2]));
    full_adder_structural fa3 (.A(A[3]), .B(B[3]), 
            .cin(carry_w[2]), .sum(sum[3]), .carry(carry));
    
endmodule

module fadder_4bit( //

    input [3:0] A, B,
    input cin,
    output [3:0] sum,
    output carry);
    
    wire [4:0] temp;
    
    assign temp = A + B + cin;
    assign sum = temp[3:0];
    assign carry = temp[4];   
    

endmodule

module fadd_sub_4bit_s(
    input [3:0] A, B,
    input s,            // add : s = 0, sub : s = 1
    output [3:0] sum,
    output carry);
    
    wire [3:0] carry_w;
    
    wire s0;
    xor (s0, B[0], s);  // ^ : xor, ~^ : xnor, & : and, | : or, ~ : not
    
    full_adder_structural fa0 (.A(A[0]), .B(B[0] ^ s),    
            .cin(s), .sum(sum[0]), .carry(carry_w[0]));
    full_adder_structural fa1 (.A(A[1]), .B(B[1] ^ s), 
            .cin(carry_w[0]), .sum(sum[1]), .carry(carry_w[1]));
    full_adder_structural fa2 (.A(A[2]), .B(B[2] ^ s), 
            .cin(carry_w[1]), .sum(sum[2]), .carry(carry_w[2]));
    full_adder_structural fa3 (.A(A[3]), .B(B[3] ^ s), 
            .cin(carry_w[2]), .sum(sum[3]), .carry(carry));
    
endmodule

module fadd_sub_4bit( //

    input [3:0] A, B,
    input s,
    output [3:0] sum,
    output carry);
    
    wire [4:0] temp;
    
    assign temp = s ? A - B : A + B;
    assign sum = temp[3:0];
    assign carry = ~temp[4];   
    
endmodule

module comparator_dataflow(
    input A, B,
    output equal, greater, less);
    
    assign equal = (A == B) ? 1'b1 : 1'b0;
    assign greater = (A > B) ? 1'b1 : 1'b0;
    assign less = (A < B) ? 1'b1 : 1'b0;

endmodule

module comparator #(parameter N = 8)(
    input [N-1:0] A, B,
    output equal, greater, less);
    
    assign equal = (A == B) ? 1'b1 : 1'b0;
    assign greater = (A > B) ? 1'b1 : 1'b0;
    assign less = (A < B) ? 1'b1 : 1'b0;

endmodule

module comparator_N_bit_test(
    input [1:0] A, B,
    output equal, greater, less);
    
    comparator #(.N(2)) c_16 (.A(A), .B(B), 
         .equal(equal), .greater(greater), .less(less));

endmodule

module comparator_N_bit_b #(parameter N = 8)(
    input [N-1:0] A, B,
    output reg equal, greater, less);
    
    always @(A, B)begin
        if(A == B)begin
            equal = 1;
            greater = 0;
            less = 0;
        end
        else if(A > B)begin
            equal = 0;
            greater = 1;
            less = 0;
        end
        else begin
            equal = 0;
            greater = 0;
            less = 1;
        end
    end
    
endmodule

module decoder_2_4_s(
    input [1:0] code,
    output [3:0] signal);

    wire [1:0] code_bar;
    not (code_bar[0], code[0]);
    not (code_bar[1], code[1]);
    
    and (signal[0], code_bar[1], code_bar[0]);
    and (signal[1], code_bar[1], code[0]);
    and (signal[2], code[1], code_bar[0]);
    and (signal[3], code[1], code[0]);

endmodule

module decoder_2_4_b(
    input [1:0] code,
    output reg [3:0] signal);
    
//    always @(code) 
//        if      (code == 2'b00) signal = 4'b0001;
//        else if (code == 2'b01) signal = 4'b0010;
//        else if (code == 2'b10) signal = 4'b0100;
//        else                    signal = 4'b1000;
    
    
    always @(code) 
        case(code)
            2'b00: signal = 4'b0001;
            2'b01: signal = 4'b0010;
            2'b10: signal = 4'b0100;
            2'b11: signal = 4'b1000;
        endcase
    
endmodule

module decoder_2_4_d(
    input [1:0] code,
    output [3:0] signal);

    assign signal = (code == 2'b00) ? 4'b0001 : 
        (code == 2'b01) ? 4'b0010 : (code == 2'b10) ? 4'b0100 : 4'b1000;

endmodule

module decoder_2_4_en(
    input [1:0] code,
    input enable,
    output [3:0] signal);

    assign signal = (enable == 1'b0) ? 4'b0000 : (code == 2'b00) ? 4'b0001 : 
        (code == 2'b01) ? 4'b0010 : (code == 2'b10) ? 4'b0100 : 4'b1000;

endmodule

module decoder_3_8(
    input [2:0] code,
    output [7:0] signal);
    
    decoder_2_4_en dec_low (.code(code[1:0]), .enable(~code[2]), .signal(signal[3:0]));
    decoder_2_4_en dec_high (.code(code[1:0]), .enable(code[2]), .signal(signal[7:4]));
    
endmodule

module encoder_4_2(
    input [3:0] signal,
    output [1:0] code);

    assign code = (signal == 4'b0001) ? 2'b00 : 
        (signal == 4'b0010) ? 2'b01 : (signal == 4'b0100) ? 2'b10 : 2'b11;
    
endmodule

// 과제 




module decoder_7seg(
 input [3:0] hex_value,
 output reg [7:0] seg_7);
    always @(hex_value)begin
        case(hex_value)
            4'b0000: begin seg_7 = 8'b0000_0011; end //0, 비트가 0일 때 켜짐
            4'b0001: begin seg_7 = 8'b1001_1111; end //1
            4'b0010: begin seg_7 = 8'b0010_0101; end //2
            4'b0011: begin seg_7 = 8'b0000_1101; end //3
            4'b0100: begin seg_7 = 8'b1001_1001; end //4
            4'b0101: begin seg_7 = 8'b0100_1001; end //5
            4'b0110: begin seg_7 = 8'b0100_0001; end //6
            4'b0111: begin seg_7 = 8'b0001_1011; end //7
            4'b1000: begin seg_7 = 8'b0000_0001; end //8
            4'b1001: begin seg_7 = 8'b0001_1001; end //9
            4'b1010: begin seg_7 = 8'b0001_0001; end //a
            4'b1011: begin seg_7 = 8'b1100_0001; end //b
            4'b1100: begin seg_7 = 8'b0110_0011; end //c
            4'b1101: begin seg_7 = 8'b1000_0101; end //d
            4'b1110: begin seg_7 = 8'b0110_0001; end //e
            4'b1111: begin seg_7 = 8'b0111_0001; end //f
        endcase
    end
endmodule

module mux_2_1(
    input [1:0] d,
    input s,
    output f);
    
    assign f = s ? d[1] : d[0];
    
//    wire sbar, w0, w1;
    
//    not (sbar, s);
//    and (w0, sbar, d[0]);
//    and (w1, s, d[1]);
//    or (f, w0, w1);
    
endmodule

module mux_4_1(
    input [3:0] d,
    input [1:0] s,
    output f);
    
    assign f = d[s];
   
endmodule

module mux_8_1(
    input [7:0] d,
    input [2:0] s,
    output f);
    
    assign f = d[s];
   
endmodule

module demux_1_4(
    input d,
    input [1:0] s,
    output [3:0] f    
);

                                                    //{}<-합성 => 000d
    assign f = (s == 2'b00) ? {3'b000, d} :         //s=00이 참이면  f=0001, 거짓이면 f=1110
               (s == 2'b01) ? {2'b00, d, 1'b0} :    //s=1이면 f=2
               (s == 2'b10) ? {1'b0, d, 2'b00} :    //s=2이면 f=4
                              {d, 3'b000};
  //이렇게 써도 같음 [f = 조건 ? 참 : 거짓] '거짓'에 조건문 삽입한 것
  //assign f = (s == 2'b00) ? {3'b000, d} : (s == 2'b01) ? {2'b00, d, 1'b0} : (s == 2'b10) ? {1'b0, d, 2'b00} : {d, 3'b000};

endmodule

module mux_demux(
    input [7:0] d,
    input [2:0] s_mux,
    input [1:0] s_demux,
    output [3:0] f
);
    
    wire w;  
    
    mux_8_1 mux(.d(d), .s(s_mux), .f(w));    // 인스턴스 생성 
    //  mux_8_1(                             // .d->mux_8_1의 d, d->mux_demux의 d
    //  input [7:0] d,
    //  input [2:0] s,
    //  output f);
    
    demux_1_4 demux(.d(w), .s(s_demux), .f(f)); 
    //  demux_1_4(
    //  input d,
    //  input [1:0] s,
    //  output [3:0] f);
endmodule


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////



module D_flip_flop_n(
    input d,
    input clk,
    input reset_p,
    output reg q
);

    wire d_bar;
    
    always @(negedge clk or posedge reset_p) begin
        if(reset_p) begin q = 0; end
        else begin q = d; end
    end
    
endmodule

module D_flip_flop_p(
    input d,
    input clk,
    input reset_p,
    output reg q
);

    wire d_bar;
    
    always @(posedge clk or posedge reset_p) begin
        if(reset_p) begin q = 0; end
        else begin q = d; end
    end
    
endmodule


module T_flip_flop_n(
    input clk, reset_p,
    input t,
    output reg q);

    always @(negedge clk or posedge reset_p) begin
        if(reset_p) begin q = 0; end
        else begin
            if(t) q = ~q;
            else q = q;
        end
    end

endmodule

module T_flip_flop_p(
    input clk, reset_p,
    input t,
    output reg q);

    always @(posedge clk or posedge reset_p) begin
        if(reset_p) begin q = 0; end
        else begin
            if(t) q = ~q;
            else q = q;
        end
    end

endmodule

module up_counter_asyc(
    input clk, reset_p,
    output [3:0] count);
    
    T_flip_flop_n T0(.clk(clk), .reset_p(reset_p), .t(1), .q(count[0]));
    T_flip_flop_n T1(.clk(count[0]), .reset_p(reset_p), .t(1), .q(count[1]));
    T_flip_flop_n T2(.clk(count[1]), .reset_p(reset_p), .t(1), .q(count[2]));
    T_flip_flop_n T3(.clk(count[2]), .reset_p(reset_p), .t(1), .q(count[3]));
    
endmodule

module down_counter_asyc(
    input clk, reset_p,
    output [3:0] count);
    
    T_flip_flop_p T0(.clk(clk), .reset_p(reset_p), .t(1), .q(count[0]));
    T_flip_flop_p T1(.clk(count[0]), .reset_p(reset_p), .t(1), .q(count[1]));
    T_flip_flop_p T2(.clk(count[1]), .reset_p(reset_p), .t(1), .q(count[2]));
    T_flip_flop_p T3(.clk(count[2]), .reset_p(reset_p), .t(1), .q(count[3]));
    
endmodule




module up_counter_p(
    input clk, reset_p, enable,
    output reg [3:0] count);
    
    always @(posedge clk, posedge reset_p)begin
        if(reset_p) count = 0;
        else begin
            if (enable) count = count + 1;
            else count = count;
        end
    end
endmodule

module down_counter_p(
    input clk, reset_p, enable,
    output reg [3:0] count);
    
    always @(posedge clk, posedge reset_p)begin
        if(reset_p) count = 0;
        else begin
            if (enable) count = count - 1;
            else count = count;
        end
    end
endmodule


module down_counter_Nbit_p #(parameter N = 8)(
    input clk, reset_p, enable,
    output reg [N-1:0] count);
    
    always @(posedge clk, posedge reset_p)begin
        if(reset_p) count = 0;
        else begin
            if (enable) count = count - 1;
            else count = count;
        end
    end
endmodule

module bcd_up_counter_p(
    input clk, reset_p,
    output reg [3:0] count);
    
    always @(posedge clk, posedge reset_p)begin
        if(reset_p) count = 0;
        else begin
            count = count + 1;
            if(count == 10) count = 0;
        end
    end
endmodule


module up_down_counter(
    input clk, reset_p,
    input down_up, //0일때 up , 1일때 down
    output reg [3:0] count);
    
    always @(posedge clk, posedge reset_p)begin
        if (reset_p) count = 0;
        else begin
            if(down_up) count = count - 1;
            else count = count + 1;
        end
    end
    
endmodule

module bcd_up_down_counter(
    input clk, reset_p,
    input down_up,
    output reg [3:0] count);
    
    always @(posedge clk, posedge reset_p)begin
        if (reset_p) count = 0;
        else begin
            if (down_up) count = count - 1;
            else if (~down_up) count = count + 1;
            if (count == 15) count = 9;
            if (count == 10) count = 0;
        end
    end
    
endmodule


module up_counter_test_top(
    input clk, reset_p,
    output [15:0] count,
    output [7:0] seg_7,
    output [3:0] com);
    
    reg [31:0] count_32;
    
    always @(posedge clk, posedge reset_p)begin
        if(reset_p) count_32 = 0;
        else count_32 = count_32 + 1;           // 업카운터로 count_32 채우기(?), 업카운터 파형 생각하기
    end
    
    assign count = count_32[31:16]; // 비교적 주기가 긴 상위 절반 비트(16번~31번) 추출하기, 그래야 사람이 눈으로 확인 할 수있음
    
    ring_counter_fnd rc(.clk(clk), .reset_p(reset_p), .com(com)); //4개의 FND LED 중에 어떤 것을 표시할 것인가를 결정하는 링 카운터
    
    reg [3:0] value;
    
    
    
    always @(posedge clk) begin //순서논리회로, mux가 만들어짐, reset_p는 고려 안함, clk만으로도 가능
    //always @(com) begin 이면 조합논리회로 mux안만들어짐, 상관없음
        case(com)               
            4'b0111 : value = count_32[31:28]; //16번~31번까지의 비트를 네 구간으로 나눔
            4'b1011 : value = count_32[27:24]; //하위 비트일수록 주기가 짧아서 속도가 빠름 -> 사람 눈으로 보기 힘들어짐
            4'b1101 : value = count_32[23:20]; //보드에서 4개의 FND 중 0부터f까지 변하는 속도가 가장 빠른 부분이 
            4'b1110 : value = count_32[19:16]; //<-여기임
        endcase
    end
    
    decoder_7seg fnd (.hex_value(value), .seg_7(seg_7)); //0부터 f까지의 FND값을 생성하는 7seg디코더를 이용함
    
endmodule


module ring_counter(
    input clk, reset_p,
    output reg [3:0] q);
    
    always @(posedge clk, posedge reset_p)begin
        if(reset_p) q = 4'b0001;
        else begin
            if(q == 4'b0001) q = 4'b1000;
            else if(q == 4'b1000) q = 4'b0100;
            else if(q == 4'b0100) q = 4'b0010;
            else q = 4'b0001;
//            case(q)
//                4'b0001 : q = 4'b1000;
//                4'b1000 : q = 4'b0100;
//                4'b0100 : q = 4'b0010;
//                4'b0010 : q = 4'b0001;    
//                default : q = 4'b0001;
//            endcase
        end
    end

endmodule

module ring_counter_fnd(
    input clk, reset_p,
    output reg [3:0] com);
    
    reg [16:0] clk_div;
    wire clk_div_16;
    
    always @(posedge clk) clk_div = clk_div + 1;
    
    edge_detector_n chattering(.clk(clk), .reset_p(reset_p), .cp(clk_div[16]), .p_edge(clk_div_16)); //채터링 제거작업

    always @(posedge clk, posedge reset_p)begin //clk_div 31번 -> 1.3ms에 한번씩,
        if(reset_p) com = 4'b1110;
        else if(clk_div_16) begin
            case(com)
                4'b1110 : com = 4'b1101;
                4'b1101 : com = 4'b1011;
                4'b1011 : com = 4'b0111;
                4'b0111 : com = 4'b1110;    
                default : com = 4'b1110;
            endcase
        end
    end

endmodule


module ring_counter_led(
    input clk, reset_p,
    output reg[15:0] count);
    
    reg [31:0] clk_div;
    
    always @(posedge clk) clk_div = clk_div + 1;

    always @(posedge clk_div[27], posedge reset_p)begin 
        if(reset_p) count = 16'b0000000000000001;
        else begin
            case(count)
                16'b0000000000000001 : count = 16'b0000000000000010;
                16'b0000000000000010 : count = 16'b0000000000000100;
                16'b0000000000000100 : count = 16'b0000000000001000;
                16'b0000000000001000 : count = 16'b0000000000010000;
                16'b0000000000010000 : count = 16'b0000000000100000;
                16'b0000000000100000 : count = 16'b0000000001000000;
                16'b0000000001000000 : count = 16'b0000000010000000;
                16'b0000000010000000 : count = 16'b0000000100000000;
                16'b0000000100000000 : count = 16'b0000001000000000;
                16'b0000001000000000 : count = 16'b0000010000000000;
                16'b0000010000000000 : count = 16'b0000100000000000;
                16'b0000100000000000 : count = 16'b0001000000000000;
                16'b0001000000000000 : count = 16'b0010000000000000;
                16'b0010000000000000 : count = 16'b0100000000000000;
                16'b0100_0000_0000_0000 : count = 16'b1000_0000_0000_0000;
                default : count = 16'b0000000000000001;
            endcase
        end
    end
    
endmodule
 
 




module edge_detector_n(
    input clk, reset_p,
    input cp,
    output p_edge, n_edge);
    
    reg ff_cur, ff_old;
    
    always @(negedge clk or posedge reset_p) begin
        if(reset_p)begin
            ff_cur <= 0;
            ff_old <= 0;
        end
        else begin            //always문 안의 이퀄 "=", "<="
            ff_cur <= cp;     //1번동작,"="을 쓰면 blocking문으로 제대로 입력 안됨
            ff_old <= ff_cur; //2번동작,"<="를 써야 non blocking으로 1번동작 2번동작 각각 병렬동작
        end
        //언제 non blocking을 쓰느냐? 현재 1인가 0인가? 순서
    end
    
    assign p_edge = ({ff_cur, ff_old} == 2'b10) ? 1 : 0; //p_edge는 ff_old의 출력 q_old를 반전시키기 위한 10ns짜리 클럭
    assign n_edge = ({ff_cur, ff_old} == 2'b01) ? 1 : 0; //n_edge는 ff_cur의 출력 q_cur를 반전

endmodule

module edge_detector_p(
    input clk, reset_p,
    input cp,
    output p_edge, n_edge);
    
    reg ff_cur, ff_old;
    
    always @(posedge clk or posedge reset_p) begin
        if(reset_p)begin
            ff_cur <= 0;
            ff_old <= 0;
        end
        else begin            //always문 안의 이퀄 "=", "<="
            ff_cur <= cp;     //1번동작,"="을 쓰면 blocking문으로 제대로 입력 안됨
            ff_old <= ff_cur; //2번동작,"<="를 써야 non blocking으로 1번동작 2번동작 각각 병렬동작
        end
        //언제 non blocking을 쓰느냐? 현재 1인가 0인가? 순서
    end
    
    assign p_edge = ({ff_cur, ff_old} == 2'b10) ? 1 : 0; //p_edge는 ff_old의 출력 q_old를 반전시키기 위한 10ns짜리 클럭
    assign n_edge = ({ff_cur, ff_old} == 2'b01) ? 1 : 0; //n_edge는 ff_cur의 출력 q_cur를 반전

endmodule

module ring_counter_led_shift1(
    input clk, reset_p,
    output reg[15:0] count);
    
    reg [20:0] clk_div;
    
    always @(posedge clk) clk_div = clk_div + 1;

    always @(posedge clk_div[20], posedge reset_p)begin
        if(reset_p) count = 16'b1;
        else begin
            if(count == 16'b1000_0000_0000_0000) count = 16'b1;
            else count = {count[14:0], 1'b0};
        end
    end
endmodule

module ring_counter_led_shift2(
    input clk, reset_p,
    output reg[15:0] count);
    
    reg [20:0] clk_div;
    wire posedge_clk_div_20;
    
    always @(posedge clk, posedge reset_p) begin
        if (reset_p) clk_div = 0;
        else clk_div = clk_div + 1;   
    end

    always @(posedge clk, posedge reset_p)begin
        if(reset_p)begin
        count = 16'b1;
        end
        else begin
            if(posedge_clk_div_20) count = {count[14:0], count[15]};
        end
    end
    
    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(clk_div[20]),
     .p_edge(posedge_clk_div_20));
    
endmodule


module shift_register_SISO_n(//직렬입력직렬출력
    input clk, reset_p,
    input d,
    output q);

    reg [3:0] siso_reg;

    always @(negedge clk, posedge reset_p) begin
        if(reset_p) siso_reg <= 0; //여기는 nonblk blk상관없음 왠만하면 nonblk로 가자
        else begin
            siso_reg[3] <= d;
            siso_reg[2] <= siso_reg[3];
            siso_reg[1] <= siso_reg[2];
            siso_reg[0] <= siso_reg[1];
             //block문이면 한문장할동안 나머지 멈춰잇음 sisoreg 3~0모두 다 d로 입력될것
            //nonblocking문을 써서 이미 출력되고있는값을 받아들여야함
            //q는 레지스터가 아니라 그냥 선이니까 바로 나와야 함 
        end
    end
    
    assign q = siso_reg[0]; //always문안에 blocking문써서 해도 되지만 실수하지 않게 밖으로빼둠
    
endmodule


module shift_register_SIPO_n(//직렬입력병렬출력
    input clk, reset_p,
    input d, //직렬이니까 1비트
    input rd_en,
    output [3:0] q); //병렬출력 이니까 4비트출력 나오게

    reg [3:0] sipo_reg;
    
    always @(negedge clk or posedge reset_p) begin
        if(reset_p) begin
            sipo_reg = 0;
        end
        else begin
            sipo_reg = {d, sipo_reg[3:1]};
        end
    end

    assign q = rd_en? sipo_reg : 4'bz; //=zzzz(!=000z) unknown, 임피던스z
//=   bufif1 (q[0], sipo_reg[0], rd_en); //3상버퍼 출력, ?, 제어
//    bufif1 (q[1], sipo_reg[1], rd_en);
//    bufif1 (q[2], sipo_reg[2], rd_en);
//    bufif1 (q[3], sipo_reg[3], rd_en); //primitive게이트인데 안쓸거니까 이런 문법이 있다 만 생각하고 담부터 안씀
endmodule


module shift_register_PISO(
    input clk, reset_p,
    input [3:0] d,
    input shift_load, //1이면 쉬프트 0이면 로드
    output q);

    reg [3:0] piso_reg; //결국 레지스터는 얘임

    always @(posedge clk, posedge reset_p) begin
        if (reset_p) piso_reg = 0;
        else begin
            if(shift_load == 1) piso_reg = {1'b0, piso_reg[3:1]}; //최하위 비트 (0번비트)는 버려짐
            else piso_reg = d;
        end
    end

    assign q = piso_reg[0]; //한 비트 밖에 출력을 못함, 위에서 계속 쉬프트해야함

endmodule