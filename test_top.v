`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/15 14:01:45
// Design Name: 
// Module Name: test_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module button_test_top(
    input clk, reset_p,
    input btnU, btnD, btnLS, btnRS,
    output [7:0] seg_7,
    output [3:0] com);
    
    reg[15:0] btn_counter;
    reg [3:0] value;
    wire btnU_pedge, btnD_pedge, btnLS_pedge, btnRS_pedge;
    reg [16:0] clk_div; //채터링 제거작업
    
    always @(posedge clk) clk_div = clk_div + 1;
    
    wire clk_div_16;
    edge_detector_n chattering(.clk(clk), .reset_p(reset_p), .cp(clk_div[16]), .p_edge(clk_div_16)); //채터링 제거작업
    
    reg debounced_btnU, debounced_btnD, debounced_btnLS, debounced_btnRS;
    
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin
            debounced_btnU = 0;
            debounced_btnD = 0;
            debounced_btnLS = 0;
            debounced_btnRS = 0;
        end
        else if (clk_div_16) begin
            debounced_btnU = btnU; //채터링이 제거된 버튼
            debounced_btnD = btnD;
            debounced_btnLS = btnLS;
            debounced_btnRS = btnRS;
        end
    end 
    
    edge_detector_n edBtnU(.clk(clk), .reset_p(reset_p), .cp(debounced_btnU), .p_edge(btnU_pedge));//cp에 btnU넣어서
    edge_detector_n edBtnD(.clk(clk), .reset_p(reset_p), .cp(debounced_btnD), .p_edge(btnD_pedge));//cp에 btnU넣어서
    edge_detector_n edbtnLS(.clk(clk), .reset_p(reset_p), .cp(debounced_btnLS), .p_edge(btnLS_pedge));//cp에 btnU넣어서
    edge_detector_n edbtnRS(.clk(clk), .reset_p(reset_p), .cp(debounced_btnRS), .p_edge(btnRS_pedge));//cp에 btnU넣어서

    //btnU의 p엣지에서 1사이클엣지 생성될 수 있게 인스턴스 생성

    always @(posedge clk, posedge reset_p)begin // 엣지디텍터 안쓰면 동기가 안맞아서 에러날수잇음, 엣지를 잡아야함
    //CPU 램 등 고속동작에 한해서는 always문안에는 clk, reset_p, enable만 써야함(문법적으로는 가능함)
        if(reset_p) btn_counter = 0; //리셋우선
        else begin
            if(btnU_pedge) btn_counter = btn_counter + 1; //카운트
            else if(btnD_pedge) btn_counter = btn_counter - 1;
            else if(btnLS_pedge) btn_counter = {btn_counter[14:0], btn_counter[15]};
            else if(btnRS_pedge) btn_counter = {btn_counter[0], btn_counter[15:1]};
        end
    end
    
    ring_counter_fnd rc(.clk(clk), .reset_p(reset_p), .com(com));
    
    always @(posedge clk) begin
        case(com)               
            4'b0111 : value = btn_counter[15:12];
            4'b1011 : value = btn_counter[11:8];
            4'b1101 : value = btn_counter[7:4];
            4'b1110 : value = btn_counter[3:0];
        endcase
    end
    wire [7:0] seg_7_bar;
    decoder_7seg fnd (.hex_value(value), .seg_7(seg_7_bar));
    assign seg_7 = ~ seg_7_bar;
    
endmodule


module led_bar_top(
    input clk, reset_p,
    output [7:0] led_bar);
    
    reg [28:0] clk_div;
    always @(posedge clk) clk_div = clk_div + 1;
    
    assign led_bar = ~clk_div[28:21];
//    assign led_bar[0] = clk_div[21]; //clk의 21번비트의 값에 따라서 led가 켜지고꺼짐
//    assign led_bar[1] = clk_div[22];
//    assign led_bar[2] = clk_div[23];
//    assign led_bar[3] = clk_div[24];
//    assign led_bar[4] = clk_div[25];
//    assign led_bar[5] = clk_div[26];
//    assign led_bar[6] = clk_div[27];
//    assign led_bar[7] = clk_div[28];
    
    
    
endmodule

 
// 버튼 눌렀을때 led가 ㅎ나씩 이진수증가가 보이도록 설계해보기
module button_ledbar_top(
    input clk, reset_p,
    input btnU, btnD, btnRv, btnLS,
    output [7:0] led_bar);
    
    reg[7:0] btn_counter;
    wire btnU_pedge, btnD_pedge;
    reg [16:0] clk_div; //채터링 제거작
    always @(posedge clk) clk_div = clk_div + 1;
    
    wire clk_div_16;
    edge_detector_n edCht(.clk(clk), .reset_p(reset_p), .cp(clk_div[16]), .p_edge(clk_div_16)); //채터링 제거작업
    //채터링 제거작업 안하면 ed2로 버튼입력의 posedge잡아도 한번눌렀을때 2번이상 작동할 수 있음
    reg debounced_btnU, debounced_btnD, debounced_btnRv, debounced_btnLS;
    
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin
            debounced_btnU = 0;
            debounced_btnD = 0;
            debounced_btnRv = 0;
            debounced_btnLS = 0;
        end
        else if(clk_div_16) begin
            debounced_btnU = btnU;
            debounced_btnD = btnD; //채터링이 제거된 버튼
            debounced_btnRv = btnRv;
            debounced_btnLS = btnLS;
        end
    end 
    edge_detector_n edBtnU(.clk(clk), .reset_p(reset_p), .cp(debounced_btnU), .p_edge(btnU_pedge));//cp에 btnU넣어서
    edge_detector_n edBtnD(.clk(clk), .reset_p(reset_p), .cp(debounced_btnD), .p_edge(btnD_pedge));//cp에 btnU넣어서
    edge_detector_n edBtnRv(.clk(clk), .reset_p(reset_p), .cp(debounced_btnRv), .p_edge(btnRv_pedge));//cp에 btnU넣어서
    edge_detector_n edbtnLS(.clk(clk), .reset_p(reset_p), .cp(debounced_btnLS), .p_edge(btnLS_pedge));//cp에 btnU넣어서
    
    always @(posedge clk, posedge reset_p)begin // 엣지디텍터 안쓰면 동기가 안맞아서 에러날수잇음, 엣지를 잡아야함
        if(reset_p) btn_counter = 0;
        else begin
            if(btnU_pedge) btn_counter = btn_counter + 1; //카운트
            else if(btnD_pedge) btn_counter = btn_counter - 1;
            else if(btnRv_pedge) btn_counter = ~btn_counter;
            else if(btnLS_pedge) btn_counter = {btn_counter[6:0], btn_counter[7]};
        end
    end

    assign led_bar = ~btn_counter;

endmodule



module button_fnd_top(
    input clk, reset_p,
    input [1:0] btn,
    output [7:0] seg_7);
    
    reg[3:0] btn_counter;
    wire btn0_pedge, btn1_pedge;
    
    reg [16:0] clk_div; //채터링 제거작
    always @(posedge clk) clk_div = clk_div + 1;
    
    wire clk_div_16;
    edge_detector_n edCht(.clk(clk), .reset_p(reset_p), .cp(clk_div[16]), .p_edge(clk_div_16)); //채터링 제거작업
    //채터링 제거작업 안하면 ed2로 버튼입력의 posedge잡아도 한번눌렀을때 2번이상 작동할 수 있음
    reg [1:0] debounced_btn;
    
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) debounced_btn = 0;
        else if(clk_div_16) begin
            debounced_btn[0] = btn[0];
            debounced_btn[1] = btn[1];
        end
    end 
    edge_detector_n edBtn0(.clk(clk), .reset_p(reset_p), .cp(debounced_btn[0]), .p_edge(btn0_pedge));//cp에 btnU넣어서
    edge_detector_n edBtn1(.clk(clk), .reset_p(reset_p), .cp(debounced_btn[1]), .p_edge(btn1_pedge));
    
    always @(posedge clk, posedge reset_p)begin // 엣지디텍터 안쓰면 동기가 안맞아서 에러날수잇음, 엣지를 잡아야함
        if(reset_p) btn_counter = 0;
        else begin
            if(btn0_pedge) btn_counter = btn_counter + 1; // UP
            else if(btn1_pedge) btn_counter = btn_counter - 1; //DOWN
        end
    end
    wire [7:0] seg_7_bar;
    decoder_7seg fnd (.hex_value(btn_counter[3:0]), .seg_7(seg_7_bar));
    assign seg_7 = ~ seg_7_bar;
endmodule


module button_fnd2_top(
    input clk, reset_p,
    input [1:0] btn,
    output [7:0] seg_7);
    
    reg[15:0] btn_counter;
    reg [3:0]value;
    wire btn0_pedge, btn1_pedge;
    
    reg [16:0] clk_div; //채터링 제거작
    always @(posedge clk) clk_div = clk_div + 1;
    
    wire clk_div_16;
    edge_detector_n edCht(.clk(clk), .reset_p(reset_p), .cp(clk_div[16]), .p_edge(clk_div_16)); //채터링 제거작업
    //채터링 제거작업 안하면 ed2로 버튼입력의 posedge잡아도 한번눌렀을때 2번이상 작동할 수 있음
    reg [1:0] debounced_btn;
    
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) debounced_btn = 0;
        else if(clk_div_16) begin
            debounced_btn[0] = btn[0];
            debounced_btn[1] = btn[1];
        end
    end 
    edge_detector_n edBtn0(.clk(clk), .reset_p(reset_p), .cp(debounced_btn[0]), .p_edge(btn0_pedge));//cp에 btnU넣어서
    edge_detector_n edBtn1(.clk(clk), .reset_p(reset_p), .cp(debounced_btn[1]), .p_edge(btn1_pedge));
    
    always @(posedge clk, posedge reset_p)begin // 엣지디텍터 안쓰면 동기가 안맞아서 에러날수잇음, 엣지를 잡아야함
        if(reset_p) btn_counter = 0;
        else begin
            if(btn0_pedge) btn_counter = btn_counter + 1; // UP
            else if(btn1_pedge) btn_counter = btn_counter - 1; //DOWN
        end
    end
    wire [7:0] seg_7_bar;

    assign seg_7 = ~ seg_7_bar;
    
    ring_counter_fnd rc(.clk(clk), .reset_p(reset_p), .com(com));
    
    always @(posedge clk) begin
        case(com)               
            4'b0111 : value = btn_counter[15:12];

            4'b1011 : value = btn_counter[11:8];
            4'b1101 : value = btn_counter[7:4];
            4'b1110 : value = btn_counter[3:0];
        endcase
        
    end
     decoder_7seg fnd (.hex_value(value), .seg_7(seg_7_bar));
endmodule








module button_test_top2(
    input clk, reset_p,
    input btnU, btnD, btnLS, btnRS,
    output [7:0] seg_7,
    output [3:0] com);
    
    reg[15:0] btn_counter;
    reg [3:0] value;
    wire btnU_pedge, btnD_pedge, btnLS_pedge, btnRS_pedge;
    
    button_cntr btnU_cntr(.clk(clk), .reset_p(reset_p), .btn(btnU), .btn_pe(btnU_pedge));
    button_cntr btnD_cntr(.clk(clk), .reset_p(reset_p), .btn(btnD), .btn_pe(btnD_pedge));
    button_cntr btnLS_cntr(.clk(clk), .reset_p(reset_p), .btn(btnLS), .btn_pe(btnLS_pedge));
    button_cntr btnRS_cntr(.clk(clk), .reset_p(reset_p), .btn(btnRS), .btn_pe(btnRS_pedge));

      always @(posedge clk, posedge reset_p)begin
        if(reset_p) btn_counter = 0; 
        else begin
            if(btnU_pedge) btn_counter = btn_counter + 1; 
            else if(btnD_pedge) btn_counter = btn_counter - 1;
            else if(btnLS_pedge) btn_counter = {btn_counter[14:0], btn_counter[15]};
            else if(btnRS_pedge) btn_counter = {btn_counter[0], btn_counter[15:1]};
        end
    end

    fnd_4digit_cntr f4c(.clk(clk), .reset_p(reset_p), .value(btn_counter), .seg_7_ca(seg_7), .com(com));

endmodule


module button_test_top2_for(
    input clk, reset_p,
    input [3:0] btn,
    output [7:0] seg_7,
    output [3:0] com);
    
    reg[15:0] btn_counter;
    reg [3:0] value;
    wire [3:0] btn_pedge;

    genvar i;
    generate 
        for (i=0; i<4; i=i+1) begin:btn_cntr
                button_cntr btn_inst(.clk(clk), .reset_p(reset_p), .btn(btn[i]), .btn_pe(btn_pedge[i]));
        end
    
    endgenerate
    
    always @(posedge clk, posedge reset_p)begin
        if(reset_p) btn_counter = 0; 
        else begin
            if(btn_pedge[0]) btn_counter = btn_counter + 1;
            else if(btn_pedge[1]) btn_counter = btn_counter - 1;
            else if(btn_pedge[2]) btn_counter = {btn_counter[14:0], btn_counter[15]};
            else if(btn_pedge[3]) btn_counter = {btn_counter[0], btn_counter[15:1]};
        end
    end

    fnd_4digit_cntr f4c(.clk(clk), .reset_p(reset_p), .value(btn_counter), .seg_7_ca(seg_7), .com(com));

endmodule


module button_ledbar_4bit_top(
    input clk, reset_p, 
    input [3:0] btn,
    output [7:0] led_bar);
    
    reg[7:0] btn_counter;
    wire btn0_pedge, btn1_pedge, btn2_pedge, btn3_pedge;
    reg [16:0] clk_div; //채터링 제거작
    always @(posedge clk) clk_div = clk_div + 1;
    
    wire clk_div_16;
    edge_detector_n edCht(.clk(clk), .reset_p(reset_p), .cp(clk_div[16]), .p_edge(clk_div_16)); //채터링 제거작업
    //채터링 제거작업 안하면 ed2로 버튼입력의 posedge잡아도 한번눌렀을때 2번이상 작동할 수 있음
    reg [3:0] debounced_btn;
    
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) debounced_btn = 0;
        else if(clk_div_16) begin
            debounced_btn[0] = btn[0];
            debounced_btn[1] = btn[1]; //채터링이 제거된 버튼
            debounced_btn[2] = btn[2];
            debounced_btn[3] = btn[3];
        end
    end 
    edge_detector_n edBtn1(.clk(clk), .reset_p(reset_p), .cp(debounced_btn[0]), .p_edge(btn0_pedge));//cp에 btnU넣어서
    edge_detector_n edBtn2(.clk(clk), .reset_p(reset_p), .cp(debounced_btn[1]), .p_edge(btn1_pedge));//cp에 btnU넣어서
    edge_detector_n edBtn3(.clk(clk), .reset_p(reset_p), .cp(debounced_btn[2]), .p_edge(btn2_pedge));//cp에 btnU넣어서
    edge_detector_n edBtn4(.clk(clk), .reset_p(reset_p), .cp(debounced_btn[3]), .p_edge(btn3_pedge));//cp에 btnU넣어서
    
    always @(posedge clk, posedge reset_p)begin // 엣지디텍터 안쓰면 동기가 안맞아서 에러날수잇음, 엣지를 잡아야함
        if(reset_p) btn_counter = 0;
        else begin
            if(btn0_pedge) btn_counter = btn_counter + 1; //카운트
            else if(btn1_pedge) btn_counter = btn_counter - 1;
            else if(btn2_pedge) btn_counter = ~btn_counter;
            else if(btn3_pedge) btn_counter = {btn_counter[6:0], btn_counter[7]};
        end
    end

    assign led_bar = ~btn_counter;

endmodule


module keypad_test_top(
    input clk, reset_p,
    input [3:0] row,
    output [3:0] col, //keypad cntr의 col을 받고 연결만 하므로 wire
    output [7:0] seg_7,
    output [3:0] com); //keyvalid가1이되는 엣지에서 1이면 증가 2면 감소, count값 fnd로 출력
    
    wire [3:0] key_value;
    reg [15:0] key_counter;
    
    keypad_cntr_FSM key_pad(.clk(clk), .reset_p(reset_p),
         .row(row), .col(col), .key_value(key_value), .key_valid(key_valid));//16개의 키 => 4비트로 받아옴
    wire key_valid_pe;
    edge_detector_n ed1(.clk(clk),.reset_p(reset_p),.cp(key_valid),.p_edge(key_valid_pe));
    
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) key_counter = 0;
        else if(key_valid_pe) begin
            if(key_value == 1) key_counter = key_counter + 1;
            else if(key_value == 2) key_counter = key_counter - 1;
            else key_counter = key_value;
        end
    end
        fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(key_counter), .seg_7_ca(seg_7), .com(com));

//    always @(posedge clk, posedge reset_p)begin
//        if(reset_p) begin
//            key_counter = 0;
//        end else if (key_valid_pe) begin
//            case (key_value)
//                4'h1: key_counter <= key_counter + 1;
//                4'h2: key_counter <= key_counter - 1;
//                default: key_counter <= key_value;
//            endcase
//        end
//    end
        
endmodule


// 시계

module watch_top(
    input clk, reset_p,
    input [2:0] btn,
    output [3:0] com,
    output [7:0] seg_7);

    wire clk_usec, clk_msec, clk_sec;
    wire [3:0] sec1, sec10, min1, min10;
    wire sec_edge, min_edge;
    wire btnS_pedge, btnUS_pedge, btnUM_pedge;
    wire set_mode;

    clock_usec usec_clk(clk, reset_p, clk_usec); //모듈에서 선언한 변수 순서대로 선언하면 .clk같은거 생략가능
    clock_div_1000 msec_clk(clk, reset_p, clk_usec, clk_msec);
    clock_div_1000 sec_clk(clk, reset_p, clk_msec, clk_sec); //FND하위 2자리
    clock_min min_clk(.clk(clk), .reset_p(reset_p), .clk_sec(sec_edge), .clk_min(clk_min));

    // clock_min min_clk(.clk(clk), .reset_p(reset_p), .clk_sec(sec_edge), .clk_min(clk_min));
    // clock_min hr_clk(.clk(clk), .reset_p(reset_p), .clk_sec(min_edge), .clk_min(clk_hr));


    counter_dec_60 counter_sec(clk, reset_p, sec_edge, sec1, sec10); //초
    counter_dec_60 counter_min(clk, reset_p, min_edge, min1, min10); //분

    fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p),
     .value({min10,min1,sec10,sec1}), .seg_7_ca(seg_7), .com(com));

    button_cntr btn_set( clk, reset_p, btn[0], btnS_pedge);
    button_cntr btnU_sec( clk, reset_p, btn[1], btnUS_pedge);
    button_cntr btnU_min( clk, reset_p, btn[2], btnUM_pedge);

    // 내가 한거
    T_flip_flop_n Set(clk, reset_p, btnS_pedge, set_mode);
    assign sec_edge = set_mode ? btnUS_pedge : clk_sec;
    assign min_edge = set_mode ? btnUM_pedge : clk_min;

endmodule


module watch_top_r(
    input clk, reset_p,
    input [2:0] btn,
    output [3:0] com,
    output [7:0] seg_7);

    wire clk_usec, clk_msec, clk_sec, clk_min;
    wire [3:0] sec1, sec10, min1, min10;
    wire sec_edge, min_edge;
    wire [2:0] btn_pedge;
    wire set_mode;

    clock_usec usec_clk(clk, reset_p, clk_usec);
    clock_div_1000 msec_clk(clk, reset_p, clk_usec, clk_msec);
    clock_div_1000 sec_clk(clk, reset_p, clk_msec, clk_sec);
    clock_min min_clk(clk, reset_p, sec_edge, clk_min);
    
    counter_dec_60 counter_sec(.clk(clk), .reset_p(reset_p), .clk_time(sec_edge), .dec1(sec1), .dec10(sec10));
    counter_dec_60 counter_min(.clk(clk), .reset_p(reset_p), .clk_time(min_edge), .dec1(min1), .dec10(min10));

    fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p),
                        .value({min10, min1, sec10, sec1}), .seg_7_ca(seg_7), .com(com));

    button_cntr btn0(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btn_pedge[0]));
    button_cntr btn1(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btn_pedge[1]));
    button_cntr btn2(.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_pe(btn_pedge[2]));

    T_flip_flop_p tff_setmode(.clk(clk), .reset_p(reset_p), .t(btn_pedge[0]), .q(set_mode));

    assign sec_edge = (set_mode) ? btn_pedge[1] : clk_sec; // MUX
    assign min_edge = (set_mode) ? btn_pedge[2] : clk_min; // MUX
endmodule


module loadable_watch_top(
    input clk, reset_p,
    input [2:0] btn,
    output [3:0] com,
    output [7:0] seg_7);
    wire clk_usec, clk_msec, clk_sec, clk_min;
    wire [3:0] sec1, sec10, min1, min10;
    wire sec_edge, min_edge;
    wire [2:0] btn_pedge;
    wire set_mode;

    clock_usec usec_clk(clk, reset_p, clk_usec);
    clock_div_1000 msec_clk(clk, reset_p, clk_usec, clk_msec);
    clock_div_1000 sec_clk(clk, reset_p, clk_msec, clk_sec);
    clock_min min_clk(clk, reset_p, sec_edge, clk_min);

    wire cur_time_load_en, set_time_load_en;
    wire [3:0] cur_sec1, cur_sec10, set_sec1, set_sec10;
    wire [3:0] cur_min1, cur_min10, set_min1, set_min10;

    loadable_counter_dec_60 cur_time_sec(.clk(clk), .reset_p(reset_p), .clk_time(clk_sec), .load_enable(cur_time_load_en),
                                            .set_value1(set_sec1), .set_value10(set_sec10), .dec1(cur_sec1), .dec10(cur_sec10));
    loadable_counter_dec_60 cur_time_min(.clk(clk), .reset_p(reset_p), .clk_time(clk_min), .load_enable(cur_time_load_en),
                                             .set_value1(set_min1), .set_value10(set_min10), .dec1(cur_min1), .dec10(cur_min10));
    //시간을 카운트
    loadable_counter_dec_60 set_time_sec(.clk(clk), .reset_p(reset_p), .clk_time(btn_pedge[1]), .load_enable(set_time_load_en),
                                             .set_value1(cur_sec1), .set_value10(cur_sec10), .dec1(set_sec1), .dec10(set_sec10));
    loadable_counter_dec_60 set_time_min(.clk(clk), .reset_p(reset_p), .clk_time(btn_pedge[2]), .load_enable(set_time_load_en),
                                             .set_value1(cur_min1), .set_value10(cur_min10), .dec1(set_min1), .dec10(set_min10));
    //버튼 입력을 카운트
    wire [15:0] value;
    assign value = set_mode ? {set_min10, set_min1, set_sec10, set_sec1} : {cur_min10, cur_min1, cur_sec10, cur_sec1};
    fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p),
                        .value(value), .seg_7_ca(seg_7), .com(com));

    button_cntr btn0(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btn_pedge[0]));
    button_cntr btn1(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btn_pedge[1]));
    button_cntr btn2(.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_pe(btn_pedge[2]));

    T_flip_flop_p tff_setmode(.clk(clk), .reset_p(reset_p), .t(btn_pedge[0]), .q(set_mode));

    edge_detector_n ed1(.clk(clk), .reset_p(reset_p), .cp(set_mode), .n_edge(cur_time_load_en), .p_edge(set_time_load_en));
    assign sec_edge = (set_mode) ? btn_pedge[1] : clk_sec;
    assign min_edge = (set_mode) ? btn_pedge[2] : clk_min;
endmodule



//스탑워치
//tff의 출력이 1일때 시간이 가야함
//usec로 들어가는 clk을 막아버리면 출력이 변하지 않을것

module stopwatch_top(
input clk, reset_p,
input [2:0] btn,
output [3:0] com,
output [7:0] seg_7,
output led);

    wire clk_usec, clk_msec, clk_sec, clk_min;
    wire [2:0] btn_pedge;
    wire start_stop;
    wire clk_start;
    wire [3:0] sec1, sec10, min1, min10;

    clock_usec usec_clk(clk_start, reset_p, clk_usec);
    clock_div_1000 msec_clk(clk_start, reset_p, clk_usec, clk_msec);
    clock_div_1000 sec_clk(clk_start, reset_p, clk_msec, clk_sec);
    clock_min min_clk(clk_start, reset_p, clk_sec, clk_min);
    
    button_cntr btn0(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btn_pedge[0]));
    button_cntr btn1(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btn_pedge[1]));
    button_cntr btn2(.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_pe(btn_pedge[2]));

    T_flip_flop_p tff_start(.clk(clk), .reset_p(reset_p), .t(btn_pedge[0]), .q(start_stop));

    assign clk_start = start_stop ? clk : 0;

    counter_dec_60 counter_sec(clk, reset_p, clk_sec, sec1, sec10); //초
    counter_dec_60 counter_min(clk, reset_p, clk_min, min1, min10); //분
    fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p),
     .value({min10,min1,sec10,sec1}), .seg_7_ca(seg_7), .com(com));
endmodule

//시간은 계속 카운트하고 있는데
//랩버튼을 누르면 버튼눌렀을때의 시간이 fnd에 표시되고
//한번 더 누르면 계속카운트되던 시간이 표시되고
//단 랩버튼을 눌러도 시간은 계속 카운트되고있어야함

module stopwatch_lap_top(
input clk, reset_p,
input [2:0]btn,
output [3:0] com,
output [7:0] seg_7 //이것도 [7:0] 안썼음
);

    wire clk_usec, clk_msec, clk_sec, clk_min;
    wire [2:0] btn_pedge;
    wire start_stop;
    wire clk_start;

    wire [3:0] sec1, sec10, min1, min10;

    clock_usec usec_clk(clk_start, reset_p, clk_usec);
    clock_div_1000 msec_clk(clk_start, reset_p, clk_usec, clk_msec);
    clock_div_1000 sec_clk(clk_start, reset_p, clk_msec, clk_sec);
    clock_min min_clk(clk_start, reset_p, clk_sec, clk_min);
    
    button_cntr btn0(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btn_pedge[0]));
    button_cntr btn1(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btn_pedge[1]));
    button_cntr btn2(.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_pe(btn_pedge[2]));

    T_flip_flop_p tff_start(.clk(clk), .reset_p(reset_p), .t(btn_pedge[0]), .q(start_stop));
    assign clk_start = start_stop ? clk : 0;


    counter_dec_60 counter_sec(clk, reset_p, clk_sec, sec1, sec10); //초
    counter_dec_60 counter_min(clk, reset_p, clk_min, min1, min10); //분
    
    wire lap_swatch, lap_load; //이거 안함
    T_flip_flop_p tff_lap(.clk(clk), .reset_p(reset_p), .t(btn_pedge[1]), .q(lap_swatch));

    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(lap_swatch),
                         .p_edge(lap_load));

    reg [15:0] lap;
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) lap = 0; //이거 안함
        else if(lap_load) lap = {min10,min1,sec10,sec1};
    end

    wire [15:0] fnd_start;
    assign fnd_start = lap_swatch ? lap : {min10,min1,sec10,sec1};

    fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p),
     .value(fnd_start), .seg_7_ca(seg_7), .com(com));
     //.value(min10,min1,sec10,sec1)을 그대로 쓰고 있었음

endmodule

module stopwatch_lap_top_answer(
input clk, reset_p,
input [2:0] btn,
output [3:0] com,
output [7:0] seg_7);

    wire clk_usec, clk_msec, clk_sec, clk_min;
    wire [2:0] btn_pedge;
    wire start_stop;
    wire clk_start;
    wire [3:0] sec1, sec10, min1, min10;

    clock_usec usec_clk(clk_start, reset_p, clk_usec);
    clock_div_1000 msec_clk(clk_start, reset_p, clk_usec, clk_msec);
    clock_div_1000 sec_clk(clk_start, reset_p, clk_msec, clk_sec);
    clock_min min_clk(clk_start, reset_p, clk_sec, clk_min);
    
    button_cntr btn0(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btn_pedge[0]));
    button_cntr btn1(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btn_pedge[1]));
    button_cntr btn2(.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_pe(btn_pedge[2]));

    T_flip_flop_p tff_start(.clk(clk), .reset_p(reset_p), .t(btn_pedge[0]), .q(start_stop));

    assign clk_start = start_stop ? clk : 0;

    counter_dec_60 counter_sec(clk, reset_p, clk_sec, sec1, sec10); //초
    counter_dec_60 counter_min(clk, reset_p, clk_min, min1, min10); //분

    wire lap_swatch, lap_load;
    T_flip_flop_p tff_lap(.clk(clk), .reset_p(reset_p), .t(btn_pedge[1]), .q(lap_swatch));

    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(lap_swatch),
                         .p_edge(lap_load));

    reg [15:0] lap;
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) lap = 0;
        else if(lap_load) lap = {min10,min1,sec10,sec1};
    end

    wire [15:0]value;
    assign value = lap_swatch ? lap : {min10,min1,sec10,sec1};
    
    fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p),
     .value(value), .seg_7_ca(seg_7), .com(com));

endmodule

//초초:ms ms 
//99다음에 1초증가
module stopwatch_csec_top(
input clk, reset_p,
input [2:0] btn,
output [3:0] com,
output [7:0] seg_7);

    wire clk_usec, clk_msec, clk_sec, clk_min, clk_10msec;
    wire [2:0] btn_pedge;
    wire start_stop;
    wire clk_start;
    wire [3:0] sec1, sec10, min1, min10;
    wire [3:0] csec1, csec10;
    wire lap_swatch, lap_load;
    reg [15:0] lap_time;
    wire [15:0]value, cur_time;

    clock_usec usec_clk(clk_start, reset_p, clk_usec);
    clock_div_1000 msec_clk(clk_start, reset_p, clk_usec, clk_msec);
    clock_div_1000 sec_clk(clk_start, reset_p, clk_msec, clk_sec);
    clock_min min_clk(clk_start, reset_p, clk_sec, clk_min);
    clock_div_10 ten_msec( clk_start, reset_p, clk_msec, clk_10msec);

    button_cntr btn0(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btn_pedge[0]));
    button_cntr btn1(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btn_pedge[1]));
    button_cntr btn2(.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_pe(btn_pedge[2]));

    T_flip_flop_p tff_start(.clk(clk), .reset_p(reset_p), .t(btn_pedge[0]), .q(start_stop));

    assign clk_start = start_stop ? clk : 0;

    counter_dec_100 counter_ms(clk, reset_p, clk_10msec, csec1, csec10);
    counter_dec_60 counter_sec(clk, reset_p, clk_sec, sec1, sec10); //초
    counter_dec_60 counter_min(clk, reset_p, clk_min, mmin1, in10); //분


    T_flip_flop_p tff_lap(.clk(clk), .reset_p(reset_p), .t(btn_pedge[1]), .q(lap_swatch));

 
    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(lap_swatch),
                         .p_edge(lap_load));

 
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) lap_time = 0;
        else if(lap_load) lap_time = {sec10,sec1,csec10,csec1};
    end


    assign cur_time = {sec10,sec1,csec10, csec1};
    assign value = lap_swatch ? lap_time : cur_time;
    
    fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p),
     .value(value), .seg_7_ca(seg_7), .com(com));

endmodule


module timer_top(
input clk, reset_p,
input [2:0] btn,
output [3:0] com,
output [7:0] seg_7,
output [15:0] led);

    wire clk_usec, clk_msec, clk_sec, clk_min;
    wire [2:0] btn_pedge;
    wire start_stop;
    wire clk_start;
    wire [3:0] sec1, sec10, min1, min10, target_sec1, target_sec10, target_min1, target_min10;
    reg [10:0] target_sec;
    reg [10:0] target_min;
    wire [3:0] cur_sec1, cur_sec10, set_sec1, set_sec10;
    wire [3:0] cur_min1, cur_min10, set_min1, set_min10;
    reg [15:0] remain_time;
    wire [15:0] set_time;

    clock_usec usec_clk(clk_start, reset_p, clk_usec);
    clock_div_1000 msec_clk(clk_start, reset_p, clk_usec, clk_msec);
    clock_div_1000 sec_clk(clk_start, reset_p, clk_msec, clk_sec);
    clock_min min_clk(clk_start, reset_p, clk_sec, clk_min);
    
    button_cntr btn0(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btn_pedge[0]));
    button_cntr btn1(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btn_pedge[1]));
    button_cntr btn2(.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_pe(btn_pedge[2]));

    T_flip_flop_p tff_start(.clk(clk), .reset_p(reset_p), .t(btn_pedge[0]), .q(run_mode));
    edge_detector_p runmode(.clk(clk), .reset_p(reset_p), .cp(run_mode), .p_edge(rm_pedge));
    assign clk_start = run_mode ? clk : 0;

    counter_dec_60 min(clk, reset_p, target_min, target_min1, target_min10);
    counter_dec_60 sec(clk, reset_p, target_sec, target_sec1, target_sec10);
    loadable_down_counter_dec_60 loadable_60m
    (clk, reset_p, clk_min, rm_pedge, target_min1, target_min10, min1, min10);
    loadable_down_counter_dec_60 loadable_60s
    (clk, reset_p, clk_sec, rm_pedge, target_sec1, target_sec10, sec1, sec10);

    assign set_time = {target_min1, target_min10, target_sec1, target_sec10};

    wire [15:0] value;
    assign value = run_mode ? remain_time : set_time;
    assign led = (~remain_time) & run_mode;
    
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) remain_time = 0;
        else if(clk_start) remain_time = {min10,min1,sec10, sec1};
    end


    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin
            target_sec = 0;
            target_min = 0;
        end
        else if(btn_pedge[1]) target_sec = target_sec + 1;
        else if(btn_pedge[2]) target_min = target_min + 1;
    end

    fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p),
     .value(value), .seg_7_ca(seg_7), .com(com));
endmodule

module cook_clock_top(
    input clk, reset_p,
    input [2:0] btn,
    output [3:0] com,
    output [7:0] seg_7,
    output led);
    
    wire clk_usec, clk_msec, clk_sec, clk_min;
    wire sec_edge, min_edge;
    wire [2:0] btn_pedge; 
    wire set_mode;
    
    clock_usec usec_clk(clk, reset_p, clk_usec);
    clock_div_1000 msec_clk(clk, reset_p, clk_usec, clk_msec);
    clock_div_1000 sec_clk(clk, reset_p, clk_msec, clk_sec);
    clock_min min_clk(clk, reset_p, sec_edge, clk_min);
    
    wire cur_time_load_en, set_time_load_en;
    wire [3:0] cur_sec1, cur_sec10, set_sec1, set_sec10;
    wire [3:0] cur_min1, cur_min10, set_min1, set_min10;
    
    button_cntr btn0(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btn_pedge[0]));
    button_cntr btn1(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btn_pedge[1]));
    button_cntr btn2(.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_pe(btn_pedge[2]));

    loadable_down_counter_dec_60 cur_time_sec(
        .clk(clk), 
        .reset_p(reset_p), 
        .clk_time(sec_edge),
        .load_enable(cur_time_load_en), 
        .set_value1(set_sec1), 
        .set_value10(set_sec10),
        .dec1(cur_sec1),
        .dec10(cur_sec10));
    loadable_down_counter_dec_60 cur_time_min(
        .clk(clk), 
        .reset_p(reset_p), 
        .clk_time(min_edge),
        .load_enable(cur_time_load_en), 
        .set_value1(set_min1), 
        .set_value10(set_min10),
        .dec1(cur_min1),
        .dec10(cur_min10));
    loadable_counter_dec_60 set_time_sec(
        .clk(clk), 
        .reset_p(reset_p), 
        .clk_time(btn_pedge[1]), 
        .load_enable(set_time_load_en),
        .set_value1(cur_sec1),
        .set_value10(cur_sec10), 
        .dec1(set_sec1), 
        .dec10(set_sec10));
    loadable_counter_dec_60 set_time_min(
        .clk(clk), 
        .reset_p(reset_p), 
        .clk_time(btn_pedge[2]), 
        .load_enable(set_time_load_en),
        .set_value1(cur_min1),
        .set_value10(cur_min10), 
        .dec1(set_min1), 
        .dec10(set_min10));
                
    wire [15:0] value;
    assign value = set_mode ? {set_min10, set_min1, set_sec10, set_sec1} : {cur_min10, cur_min1, cur_sec10, cur_sec1};                        
    
    fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(value), .seg_7_ca(seg_7), .com(com));
    
    T_flip_flop_p tff_setmode(.clk(clk), .reset_p(reset_p), .t(btn_pedge[0]), .q(set_mode));
    
    edge_detector_p ed(.clk(clk), .reset_p(reset_p), 
                 .cp(set_mode), .n_edge(cur_time_load_en), .p_edge(set_time_load_en));

    assign sec_edge = set_mode ? btn_pedge[1] : clk_sec;
    assign min_edge = set_mode ? btn_pedge[2] : clk_min;
    assign led = ~{cur_min10, cur_min1, cur_sec10, cur_sec1} & set_mode;
endmodule