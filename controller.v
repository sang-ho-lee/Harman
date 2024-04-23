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
    always @(posedge clk)begin
        case(com)
            4'b0111: hex_value = value[15:12];
            4'b1011: hex_value = value[11:8];
            4'b1101: hex_value = value[7:4];
            4'b1110: hex_value = value[3:0];
        endcase
    end
    decoder_7seg fnd (.hex_value(hex_value), .seg_7(seg_7_an));
    assign seg_7_ca = ~seg_7_an;
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
    
    always @* begin//조합논리회로 FSM
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


module dht11(
    input clk, reset_p,
    inout dht11_data,   //InOut Input도되고 Output도 되고
    output reg [7:0] humidity, temperature,
    output [7:0] led_bar);

    parameter S_IDLE        = 6'b000001;
    parameter S_LOW_18MS    = 6'b000010;
    parameter S_HIGH_20US   = 6'b000100;
    parameter S_LOW_80US    = 6'b001000;
    parameter S_HIGH_80US   = 6'b010000;
    parameter S_READ_DATA   = 6'b100000;
    
    parameter S_WAIT_PEDGE = 2'b01;
    parameter S_WAIT_NEDGE = 2'b10;

    reg [21:0] count_usec;
    wire clk_usec;
    reg count_usec_e;
    clock_usec usec_clk(clk, reset_p, clk_usec);

    always @(negedge clk, posedge reset_p) begin
        if(reset_p) count_usec = 0;
        else begin
            if(clk_usec && count_usec_e) count_usec = count_usec + 1;
            else if(!count_usec_e) count_usec = 0;
        end        
    end
    wire dht_pedge, dht_nedge;
    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(dht11_data),
        .p_edge(dht_pedge), .n_edge(dht_nedge));

    reg [5:0] state, next_state;
    reg [1:0] read_state;

    assign led_bar[5:0] = state;

    always @(negedge clk, posedge reset_p) begin
        if(reset_p) state = S_IDLE;
        else state = next_state;
    end

    reg [39:0] temp_data; //temporally
    reg [5:0] data_count;

    reg dht11_buffer;
    assign dht11_data = dht11_buffer;

    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin
            count_usec_e = 0;
            next_state = S_IDLE;
            dht11_buffer = 1'bz; //임피던스 상태 , pullup저항때문에 데이터선이 HIGH가 됨
            //InOut은 반드시 임피던스상태를 줘야함
            read_state = S_WAIT_PEDGE;
            data_count = 0;
        end
        else begin
            case(state)
                S_IDLE : begin
                    if(count_usec <= 22'd3_000_000) begin //3_000_000 3초가 지나지 않으면
                        count_usec_e = 1;   //usec count가 계속 증가
                        dht11_buffer = 1'bz; //1로 유지되야 하지만
                        // 회로가 pullup이기 때문에 임피던스출력으로 끊어주면 알아서 1이된다
                    end
                    else begin  //3초가 지나면
                        next_state = S_LOW_18MS; //다음상태 LOW18ms로 넘어가고
                        count_usec_e = 0;   //usec count를 0으로 초기화
                    end                
                end
                S_LOW_18MS : begin
                    if(count_usec <= 22'd20_000) begin //(최소18ms) 20ms가 지나지 않으면
                        count_usec_e = 1;
                        dht11_buffer = 0;   //LOW(0)
                    end
                    else begin
                        count_usec_e = 0;
                        next_state = S_HIGH_20US;
                        dht11_buffer = 1'bz;    //계속 읽어야하기때문에 임피던스출력으로 연결끊어줌
                    end
                end
                S_HIGH_20US : begin
                    count_usec_e =1;
                    if(dht_nedge) begin  //센서에서 보낸 신호가 negedge가 들어오면          
                        next_state = S_LOW_80US; //다음상태로 넘어가고
                        count_usec_e = 0; //usec count초기화
                    end      
                    if (count_usec > 22'd20_000) begin //20us를 기다리는 동안
                        next_state = S_IDLE;
                        count_usec_e = 0;
                    end
                end
                S_LOW_80US : begin //센서가 전송해주는 신호 읽는 시간
                    count_usec_e =1;
                    if(dht_nedge) begin  //센서에서 보낸 신호가 negedge가 들어오면          
                        next_state = S_HIGH_80US; //다음상태로 넘어가고
                        count_usec_e = 0; //usec count초기화
                    end      
                    if (count_usec > 22'd20_000) begin //20us를 기다리는 동안
                        next_state = S_IDLE;
                        count_usec_e = 0;
                    end
                end
                S_HIGH_80US : begin//센서가 전송해주는 신호 읽는 시간
                    count_usec_e =1;
                    if(dht_nedge) begin  //센서에서 보낸 신호가 negedge가 들어오면          
                        next_state = S_READ_DATA; //다음상태로 넘어가고
                        count_usec_e = 0; //usec count초기화
                    end      
                    if (count_usec > 22'd20_000) begin //20us를 기다리는 동안
                        next_state = S_IDLE;
                        count_usec_e = 0;
                    end
                end
                S_READ_DATA : begin
                    case (read_state)
                        S_WAIT_PEDGE : begin //센서 신호의 pedge를 기다리는 시간
                            if(dht_pedge) begin   //pedge가 들어 오면
                                read_state = S_WAIT_NEDGE; //다음상태로 넘어가고
                            end
                            count_usec_e = 0; //시간세는거 중지
                        end 
                        S_WAIT_NEDGE : begin//센서 신호의 nedge를 기다리면서 데이터들을 읽는 시간
                            if (dht_nedge) begin //nedge가 들어 오면
                                if (count_usec < 50) begin //기다린 시간이 50us 미만이면
                                    temp_data = {temp_data[38:0], 1'b0}; //최상위 비트 버리고 최하위
                                    //에 0
                                end
                                else begin //50us 이상이면
                                    temp_data = {temp_data[38:0], 1'b1}; //최하위비트에 1
                                end
                                data_count = data_count + 1; //데이터 하나 읽었습니다 표시
                                read_state = S_WAIT_PEDGE;                           
                            end
                            else begin  //nedge가 들어오기 전까지는
                                count_usec_e = 1; //시간을 카운트 하고
                            end                            
                        end 
                    endcase
                    if (data_count >= 40) begin //데이터 40개 다 세면
                        data_count = 0; //세는count 0으로 초기화하고
                        next_state = S_IDLE; //다음상태는 IDLE상태
                        humidity = temp_data[39:32];//tempdata의 최상위 8비트가 습도
                        temperature = temp_data[23:16];//23:16의 8비트가 온도                        
                    end
                    if (count_usec > 22'd50_000) begin
                        data_count = 0;
                        next_state = S_IDLE;
                        count_usec_e = 0;                        
                    end
                end
                default : next_state = S_IDLE;
            endcase
        end
    end
endmodule



module hc_sr04(
    input clk, reset_p,
    input echo,
    output reg trigger,
    output reg [15:0] distance,
    output [7:0] led_bar);

    parameter S_IDLE = 3'b001;
    parameter S_TRIG_10US = 3'b010;
    parameter S_READ_DATA = 3'b100;
    parameter S_WAIT_PEDGE = 2'b01;
    parameter S_WAIT_NEDGE = 2'b10;

    reg [22:0] count_usec;
    wire clk_usec;
    reg count_usec_e;
    clock_usec usec_clk(clk, reset_p, clk_usec);

    always @(negedge clk, posedge reset_p) begin
            if(reset_p) count_usec = 0;
            else begin
                if(clk_usec && count_usec_e) count_usec = count_usec + 1;//count_usec인에이블설정
                else if(!count_usec_e) count_usec = 0; 
            end        
    end

    reg [2:0] state, next_state;
    reg [1:0] read_state;
    
    //LED
    assign led_bar[2:0] = state;
    assign led_bar[4:3] = read_state;
    assign led_bar[5] = count_usec_e;
    
    always @(negedge clk, posedge reset_p) begin
        if(reset_p) state = S_IDLE;
        else state = next_state;
    end

    wire echo_pedge, echo_nedge;
    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(echo),
            .p_edge(echo_pedge), .n_edge(echo_nedge));
    
//    reg [15:0] distance_buffer;

    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin
            count_usec_e = 0;
            next_state = S_IDLE;
            trigger = 0;
            read_state = S_WAIT_PEDGE;
        end
        else begin
            case (state)
                S_IDLE : begin
                    if(count_usec <= 1000_000) begin// Allow 10ms from end of echo to next trigger pulse
                        count_usec_e = 1;//시간(usec)을 센다
                        trigger = 0;
                    end
                    else begin //10ms가 지나면
                        count_usec_e = 0; //countusec = 0 초기화
                        next_state = S_TRIG_10US; //트리거 동작준비�                        
                    end
                end 
                S_TRIG_10US : begin
                    count_usec_e = 1; //시간을 센다
                    trigger = 1; //10 us동안 트리거신호 전송 
                    if(count_usec >= 11) begin //10us가 지나면�
                        count_usec_e = 0; //시간 그만 세고�
                        trigger = 0; //트리거 신호 중지 
                        next_state = S_READ_DATA;  // 데이터 읽을 준비
                    end
                end 
                //HC-SR04 지가 알아서 8 pulse 버스트
                S_READ_DATA : begin
                    case(read_state)
                        S_WAIT_PEDGE : begin
                            if(echo_pedge) begin                          
                                read_state = S_WAIT_NEDGE;
                            end                            
                        end 
                        S_WAIT_NEDGE : begin//센서 신호의 nedge를 기다리면서 데이터들을 읽는 시간
                            if (echo_nedge) begin//nedge가 들어 오면                                 
                                distance = count_usec / 58; 
                                count_usec_e = 0;
                                next_state = S_IDLE; 
                                read_state = S_WAIT_PEDGE;
                                
                            end
                            else begin   //nedge가 들어오기 전까지는
                                count_usec_e = 1;  //시간을 카운트 하고
                            end
                        end                        
                    endcase
                    // if(echo_pedge) begin
                    //     count_usec_e = 1;                        
                    // end
                    // if(echo_nedge) begin
                    //     echotime_buffer = count_usec;
                    //     count_usec_e = 0;
                    //     next_state = S_IDLE;
                    // end
                end
                default : next_state = S_IDLE;   
            endcase
        end
    end
//    assign distance = distance_buffer;

endmodule


module ultra_sonic_jw(
    input clk, reset_p,
    input echo,
    output trig,
    output [15:0] distance,
    output [7:0] led_bar);

    parameter S_IDLE = 3'b001;
    parameter S_HIGH_10US = 3'b010;
    parameter S_READ_DATA = 3'b100;
    parameter S_WAIT_PEDGE = 2'b01;
    parameter S_WAIT_NEDGE = 2'b10;

    reg [15:0] count_usec;
    wire clk_usec;
    reg count_usec_e;
    clock_usec usec_clk(clk, reset_p, clk_usec);

    always @(negedge clk or posedge reset_p)begin //네거티브 엣지를 사용하는 이유 :
        if(reset_p)  count_usec = 0;
        else begin
            if(clk_usec && count_usec_e) count_usec = count_usec + 1;
            else if(!count_usec_e) count_usec = 0;
        end
    end

    wire echo_pedge, echo_nedge;
    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(echo), .p_edge(echo_pedge), .n_edge(echo_nedge));
    
    reg [3:0] state, next_state;
    reg [1:0] read_state;

    assign led_bar[2:0] = state;

    always @(negedge clk or posedge reset_p)begin
        if(reset_p) state = S_IDLE;
        else state = next_state;
    end

    reg [15:0] temp_data;

    reg trig_buffer;
    assign trig = trig_buffer;

    always @(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            count_usec_e = 0;
            next_state = S_IDLE;
            trig_buffer = 0;
            read_state = S_WAIT_PEDGE;
        end
        else begin
            case(state)
                S_IDLE:begin
                    if(count_usec < 16'd5000)begin  //3_000_000
                        count_usec_e = 1;
                        trig_buffer = 0;
                    end
                    else begin
                        next_state = S_HIGH_10US;
                        count_usec_e = 0;
                    end
                end
                S_HIGH_10US:begin
                    if(count_usec <= 16'd11)begin
                        count_usec_e =1;
                        trig_buffer = 1;
                    end
                    else begin
                         count_usec_e = 0;
                         next_state = S_READ_DATA;
                         trig_buffer = 0;
                    end
                end
                S_READ_DATA:begin
                    case(read_state)
                        S_WAIT_PEDGE:begin
                            if(echo_pedge)begin
                                read_state = S_WAIT_NEDGE;
                            end
                            count_usec_e = 0;
                        end
                        S_WAIT_NEDGE:begin
                            if(echo_nedge)begin
                                temp_data = count_usec;
                                count_usec_e = 0;
                                read_state = S_WAIT_PEDGE;
                            end
                            else begin
                                count_usec_e = 1;
                            end
                        end
                    endcase
                    if(count_usec > 16'd36)begin
                        temp_data = 0;
                        next_state = S_IDLE;
                        count_usec_e = 0;
                    end
                end
                default:next_state = S_IDLE;
            endcase
        end
    end
    assign distance = temp_data/58;
endmodule
