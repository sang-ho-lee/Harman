`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/15 12:00:20
// Design Name: 
// Module Name: controller
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

    module fnd_4digit_cntr(
        input clk, reset_p,
        input [15:0] value,
        output [7:0] seg_7_an, seg_7_ca,
        output [3:0] com);
        
        reg [3:0] hex_value;
        
        ring_counter_fnd rc(.clk(clk), .reset_p(reset_p), .com(com));
        
        always @(posedge clk) begin
            case(com)               
                4'b0111 : hex_value = value[15:12];
                4'b1011 : hex_value = value[11:8];
                4'b1101 : hex_value = value[7:4];
                4'b1110 : hex_value = value[3:0];
            endcase
        end
    
        decoder_7seg fnd (.hex_value(hex_value), .seg_7(seg_7_an));
        assign seg_7_ca = ~ seg_7_an;
        
    endmodule
    
    
    module button_cntr(
        input clk, reset_p,
        input btn,
        output btn_pe, btn_ne);
    
        reg [16:0] clk_div;
        wire clk_div_16;
        reg [3:0] debounced_btn;
    
        always @(posedge clk) clk_div = clk_div + 1;
        edge_detector_n ed1(.clk(clk), .reset_p(reset_p), .cp(clk_div[16]), .p_edge(clk_div_16));
    
        always @(posedge clk, posedge reset_p) begin
            if(reset_p) debounced_btn = 0;
            else if(clk_div_16) debounced_btn = btn;
        end
        edge_detector_n ed2(.clk(clk), .reset_p(reset_p), .cp(debounced_btn), .p_edge(btn_pe), .n_edge(btn_ne));
        
    endmodule
    
    
    module key_pad_cntr(
        input clk, reset_p,
        input [3:0] row,
        output reg [3:0] col,
        output reg [3:0] key_value, //16개의 키 => 4비트로 받아옴
        output reg key_valid //키값이 바뀌면 1이 됨, 키입력이 있는지 없는지를 나타냄, 없으면 key_value[0]이 애매해짐
        //16개 키 중 키 입력이 아무것도 들어오지 않은 초기상태를 처리하기 위한 output
        );
        
        reg [19:0] clk_div;//한 줄 읽는데 8ms 4줄 총 32ms가 읽는데 걸리는 시간
        always @(posedge clk) clk_div = clk_div + 1;
        wire clk_8msec;
        wire key_valid_pe;
        edge_detector_n ed1(.clk(clk), .reset_p(reset_p), .cp(clk_div[19]),
         .p_edge(clk_8msec_p), .n_edge(clk_8msec_n));
        
        always @(posedge clk, posedge reset_p)begin 
            if(reset_p) col = 4'b0001;
            else if(clk_8msec_p && !key_valid) begin //key valid가 1이 아닐때 8msec로  case문 계속 스캔
                case(col)                          //1일때는 case문 안돌고 계속고정
                    4'b0001 : col = 4'b0010;       //D플립플롭이 생성될때 enable역할을 함
                    4'b0010 : col = 4'b0100;
                    4'b0100 : col = 4'b1000;
                    4'b1000 : col = 4'b0001;    
                    default : col = 4'b0001;
                endcase
            end
        end
        
        always @(posedge clk, posedge reset_p)begin
            if (reset_p) begin
                key_value = 4'b0000;
                key_valid = 0;
            end
            else begin
                if(clk_8msec_n) begin
                    if(row) begin //8msec마다 키 읽을 때만 읽음
                        key_valid = 1;
                        case({col, row})
                            8'b0001_0001: key_value = 4'h1; //0
                            8'b0001_0010: key_value = 4'h2; //1
                            8'b0001_0100: key_value = 4'h3; //2
                            8'b0001_1000: key_value = 4'hA; //3
                            8'b0010_0001: key_value = 4'h4; //4
                            8'b0010_0010: key_value = 4'h5; //5
                            8'b0010_0100: key_value = 4'h6; //6
                            8'b0010_1000: key_value = 4'hb; //7
                            8'b0100_0001: key_value = 4'h7; //8
                            8'b0100_0010: key_value = 4'h8; //9
                            8'b0100_0100: key_value = 4'h9; //A
                            8'b0100_1000: key_value = 4'hE; //b
                            8'b1000_0001: key_value = 4'hC; //C
                            8'b1000_0010: key_value = 4'h0; //d
                            8'b1000_0100: key_value = 4'hF; //E
                            8'b1000_1000: key_value = 4'hd; //F
                        endcase
                    end
                    else begin
                        key_valid = 0;
                        key_value = 0; //키 누르는동안만 유지
                    end
                end
            end
        end
        
        //key valid에 엣지 p엣지에서 (손 뗄때)잡아서 키값이 1이먄(1 누르면) 카운트값 1증가 키값이 2번이면 감소
        //키카운터 16비트짜리 하나 만들고 그 키카운터값을 fnd에다 출력하기(.value)에 출력하기 
        // keyvalue받아서 엣지잡고
    endmodule
    
    
    module keypad_cntr_FSM(//FSM : 각각의 상태에서 어떤 동작을 해야 하는지 규정
        input clk, reset_p, //Finite State Machine 제한적인(유한한) ASM(:Algorithm)
        input [3:0] row,
        output reg [3:0] col,
        output reg [3:0] key_value, //16개의 키 => 4비트로 받아옴
        output reg key_valid);
        
        parameter SCAN_0 = 1; //N비트짜리 만들때 PARAMETER씀
        parameter SCAN_1 = 2; //PARAMETER는 상수를 선언할때 씀
        parameter SCAN_2 = 3; //변수에 값을 주면 상수가 되서 값이 변하지 않는다
        parameter SCAN_3 = 4; 
        parameter KEY_PROCESS = 5;
//
//        parameter SCAN_0 = 5'b00001;
//        parameter SCAN_1 = 5'b00010;
//        parameter SCAN_2 = 5'b00100; 
//        parameter SCAN_3 = 5'b01000; 
//        parameter KEY_PROCESS = 5'b10000;
//        => 이러면 회로가 더 깔끔해짐(링카운터처럼)
        
        reg [2:0] state, next_state;
        
        always @* begin//조합논리회로
            case(state)//이렇게 하는 이유 : 복잡한 상태천이도 안의 다양한 조건을 구현할수 있음
                SCAN_0: begin
                    if(row == 0) next_state = SCAN_1; //state가 1일때 next_state = 2 로 바꿔라
                    else next_state = KEY_PROCESS;    //결국 가독성과 구분 위해 위에서 PARAMETER 쓴 것 
                end
                SCAN_1: begin
                    if(row == 0) next_state = SCAN_2;
                    else next_state = KEY_PROCESS;
                end
                SCAN_2: begin
                    if(row == 0) next_state = SCAN_3;
                    else next_state = KEY_PROCESS;
                end
                SCAN_3: begin
                    if(row == 0) next_state = SCAN_0;
                    else next_state = KEY_PROCESS;
                end
                KEY_PROCESS : begin
                    if(row != 0) next_state = KEY_PROCESS;
                    else next_state = SCAN_0;
                end
            endcase
        end
    
        reg [19:0] clk_div;
        always @(posedge clk) clk_div = clk_div + 1;
        wire clk_8msec;
        edge_detector_n ed1(.clk(clk), .reset_p(reset_p), .cp(clk_div[19]),
         .p_edge(clk_8msec));
         
         always @(posedge clk, posedge reset_p) begin // 순서논리회로
            if(reset_p) state = SCAN_0;
            else if(clk_8msec) state = next_state;
         end
        
        always @(posedge clk, posedge reset_p) begin
            if(reset_p) begin
                key_value = 0;
                key_valid = 0;
                col = 4'b0001;
            end
            else begin
                case(state)
                    SCAN_0 : begin col = 4'b0001; key_valid = 0; end //scan0에 머무는 동안 kv는 계속 0
                    SCAN_1 : begin col = 4'b0010; key_valid = 0; end
                    SCAN_2 : begin col = 4'b0100; key_valid = 0; end
                    SCAN_3 : begin col = 4'b1000; key_valid = 0; end
                    KEY_PROCESS : begin
                        key_valid = 1;
                        case({col, row})
                            8'b0001_0001: key_value = 4'h1; //0
                            8'b0001_0010: key_value = 4'h2; //1
                            8'b0001_0100: key_value = 4'h3; //2
                            8'b0001_1000: key_value = 4'hA; //3
                            8'b0010_0001: key_value = 4'h4; //4
                            8'b0010_0010: key_value = 4'h5; //5
                            8'b0010_0100: key_value = 4'h6; //6
                            8'b0010_1000: key_value = 4'hb; //7
                            8'b0100_0001: key_value = 4'h7; //8
                            8'b0100_0010: key_value = 4'h8; //9
                            8'b0100_0100: key_value = 4'h9; //A
                            8'b0100_1000: key_value = 4'hE; //b
                            8'b1000_0001: key_value = 4'hC; //C
                            8'b1000_0010: key_value = 4'h0; //d
                            8'b1000_0100: key_value = 4'hF; //E
                            8'b1000_1000: key_value = 4'hd; //F
                        endcase
                    end
                endcase
            end
        end
    
    endmodule
    
    
    


