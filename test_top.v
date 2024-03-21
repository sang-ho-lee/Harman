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
