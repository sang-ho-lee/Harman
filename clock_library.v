//clock과 관련된 모듈을 넣는 공간



module clock_usec( //마이크로세크 클럭
    input clk, reset_p,
    output clk_usec);

    //basys는 clk 주기가 10ns
    reg [7:0] cnt_sysclk; //10ns
    wire cp_usec;         //10ns 가 100개 를 세야 1us, 즉 최소 7비트(8비트)필요

    always @(posedge clk, posedge reset_p) begin
        if(reset_p) cnt_sysclk = 0;
        else if(cnt_sysclk >= 99) cnt_sysclk = 0; //99에서 다음 100이 되지 않고 0으로클리어됨
        else cnt_sysclk = cnt_sysclk + 1; //reset이 들어오지 않으면 cnt_sysclk는 계속 1씩 증가
    end

    assign cp_usec = cnt_sysclk < 50 ? 0 : 1; //1ms주기를 가지는 클락펄스는 0이었다가 cnt_sysclk이 50이 되면 1이 됨
    edge_detector_n ed(.clk(clk), .reset_p(reset_p),
     .cp(cp_usec), .n_edge(clk_usec));
    //99에서 0 으로떨어질때로 해야하므로 negative edge잡는게 좋음
endmodule
//cp는 1usec주기로 0 1이 바뀌는 애임
//그렇게되면 1인동안 계속 카운트 될테니까 엣지디텍터로 원사이클써서


module clock_div_1000( //1000분(나눌 분)주기만들기
//1ms마다 한번씩클럭이나올것, 결국 천 개 세는 카운터
    input clk, reset_p,
    input clk_source,
    output clk_div_1000);

    reg [8:0] cnt_clk_source; //500개 필요함 즉 9비트 필요함 
    reg cp_div_1000;
//usec * 1000 = msec
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin
            cnt_clk_source = 0;
            cp_div_1000 = 0; //0으로 clear해놓고
        end
        else if (clk_source) begin
            if(cnt_clk_source > 499) begin
                 cnt_clk_source = 0; //clear
                 cp_div_1000 = ~ cp_div_1000; //usec의 반주기마다 토글되도록
            end
            else cnt_clk_source = cnt_clk_source + 1;
        end
    end
        // assign cp_msec = cnt_clk_source >= 499 ? 1: 0; 위 if문에 500마다설정해줫으므로 필요없음
        edge_detector_n ed(.clk(clk), .reset_p(reset_p),
                            .cp(cp_div_1000), .n_edge(clk_div_1000));
    //상승엣지 잡아서 써도 1msec 하강엣지써도 1msec임 어차피 한주기는 1msec니까

endmodule

module clock_div_1000( //1000분(나눌 분)주기만들기
//1ms마다 한번씩클럭이나올것, 결국 천 개 세는 카운터
    input clk, reset_p,
    input clk_source,
    output clk_div_1000);

    reg [8:0] cnt_clk_source; //500개 필요함 즉 9비트 필요함 
    reg cp_div_1000;
//usec * 1000 = msec
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin
            cnt_clk_source = 0;
            cp_div_1000 = 0; //0으로 clear해놓고
        end
        else if (clk_source) begin
            if(cnt_clk_source >= 499) begin
                 cnt_clk_source = 0; //clear
                 cp_div_1000 = ~ cp_div_1000; //usec의 반주기마다 토글되도록
            end
            else cnt_clk_source = cnt_clk_source + 1;
        end
    end
        // assign cp_msec = cnt_clk_source >= 499 ? 1: 0; 위 if문에 500마다설정해줫으므로 필요없음
        edge_detector_n ed(.clk(clk), .reset_p(reset_p),
                            .cp(cp_div_1000), .n_edge(clk_div_1000));
    //상승엣지 잡아서 써도 1msec 하강엣지써도 1msec임 어차피 한주기는 1msec니까

endmodule

//clk60개 들어올때마다 한번식 발쌩하는 60진 카운터

//1초클락을 빼서 59->0으로, 1분에 한번씩만 펄스가 나오는 카운터

module clock_min( 
    input clk, reset_p,
    input clk_sec,
    output clk_min);

    reg [4:0] cnt_sec; 
    reg cp_min;

    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin
            cnt_sec = 0;
            cp_min = 0; 
        end
        else if (clk_sec) begin
            if(cnt_sec >= 29) begin //29되고 30으로 넘어갈때 동작
                 cnt_sec = 0;
                 cp_min = ~cp_min;
            end
            else cnt_sec = cnt_sec + 1;
        end
    end
        edge_detector_n ed(.clk(clk), .reset_p(reset_p),
                            .cp(cp_min), .n_edge(clk_min));
endmodule


module counter_dec_60( //decimal로 60까지 세는 카운터
    input clk, reset_p,
    input clk_time,
    output reg [3:0] dec1, dec10); //1의자리 10의자리 따로내보내서 fnd에 출력

    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin
            dec1 = 0;
            dec10 = 0;    
        end
        else begin
            if(clk_time) begin
    //  else if(clk_time) begin
                if(dec1 >= 9) begin
                    dec1 = 0;
                    if(dec10 >= 5) dec10 = 0;
                    else dec10 = dec10 + 1;
                end
                else dec1 = dec1 + 1; //초클러을 받으면 1초클락받을때마다
                // 1의자리를 1씩증가(카운터니까) 9에서 10되면 0이되야함
            end
        end
    end

endmodule


module loadable_counter_dec_60(
    input clk, reset_p,
    input clk_time,
    input load_enable,
    input [3:0] set_value1, set_value10, set_value100, set_value1000,
    output reg [3:0] dec1, dec10, dec100, dec1000);
    always @(posedge clk or posedge reset_p) begin
        if(reset_p) begin
            dec1 = 0;
            dec10 = 0;
        end
        else begin
            if(load_enable) begin
                dec1 = set_value1;
                dec10 = set_value10;
            end
            else if(clk_time) begin
                if(dec1 >= 9)begin
                    dec1 = 0;
                    if(dec10 >= 5) begin
                        dec10 = 0;
                    end
                    else dec10 = dec10 + 1;
                end
                else dec1 = dec1 + 1;
            end
        end
    end
endmodule


module loadable_down_counter_dec_60(
    input clk, reset_p,
    input clk_time,
    input load_enable,
    input [31:0] set_value1, set_value10, set_value100, set_value1000,
    output reg [31:0] dec1, dec10, dec100, dec1000);

    always @(posedge clk or posedge reset_p) begin
        if(reset_p) begin
            dec1 = 9;
            dec10 = 5;
            dec100 = 9;
            dec1000 = 5;
        end
        else begin
            if(load_enable) begin
                dec1 = set_value1;
                dec10 = set_value10;
                dec100 = set_value100;
                dec1000 = set_value1000;
            end
            else if(clk_time) begin
                if(dec1 == 0) begin
                    dec1 = 9;
                    if(dec10 == 0) begin
                        dec10 = 5;
                        if (dec100 == 0) begin
                            dec100 = 9;
                            if (dec1000 == 0) begin
                                dec1000 = 5;
                            end
                            else dec1000 = dec1000 - 1;
                        end
                        else dec100 = dec100 - 1;
                    end
                    else dec10 = dec10 - 1;
                end 
                else dec1 = dec1 - 1;
            end
        end
    end
endmodule

module clock_div_10( //10분(나눌 분)주기만들기
    input clk, reset_p,
    input clk_source,
    output clk_div_10);

    integer cnt_clk_source; //5개 필요함 즉 2비트 필요함 
    reg cp_div_10;
//msec * 10 = 10msec
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin
            cnt_clk_source = 0;
            cp_div_10 = 0; //0으로 clear해놓고
        end
        else if (clk_source) begin
            if(cnt_clk_source >= 4) begin 
                 cnt_clk_source = 0; //clear
                 cp_div_10 = ~ cp_div_10; //usec의 반주기마다 토글되도록
            end
            else cnt_clk_source = cnt_clk_source + 1;
        end
    end
        // assign cp_msec = cnt_clk_source >= 499 ? 1: 0; 위 if문에 500마다설정해줫으므로 필요없음
        edge_detector_n ed(.clk(clk), .reset_p(reset_p),
                            .cp(cp_div_10), .n_edge(clk_div_10));
    //상승엣지 잡아서 써도 1msec 하강엣지써도 1msec임 어차피 한주기는 1msec니까

endmodule

module clock_div_100( //100분(나눌 분)주기만들기
    input clk, reset_p,
    input clk_source,
    output clk_div_100);

    reg [5:0] cnt_clk_source; //50개 필요함 즉 2비트 필요함 
    reg cp_div_100;
    //msec * 10 = 10msec
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin
            cnt_clk_source = 0;
            cp_div_100 = 0; //0으로 clear해놓고
        end
        else if (clk_source) begin
            if(cnt_clk_source > 49) begin
                 cnt_clk_source = 0; //clear
                 cp_div_100 = ~ cp_div_100; //usec의 반주기마다 토글되도록
            end
            else cnt_clk_source = cnt_clk_source + 1;
        end
    end
        // assign cp_msec = cnt_clk_source >= 49 ? 1: 0; 위 if문에 500마다설정해줫으므로 필요없음
        edge_detector_n ed(.clk(clk), .reset_p(reset_p),
                            .cp(cp_div_100), .n_edge(clk_div_100));
    //상승엣지 잡아서 써도 1msec 하강엣지써도 1msec임 어차피 한주기는 1msec니까

endmodule


module clock_div_10000( //100분(나눌 분)주기만들기
    input clk, reset_p,
    input clk_source,
    output clk_div_1000);

    reg [15:0] cnt_clk_source; //50개 필요함 즉 2비트 필요함 
    reg cp_div_10000;
    //msec * 10 = 10msec
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin
            cnt_clk_source = 0;
            cp_div_10000 = 0; //0으로 clear해놓고
        end
        else if (clk_source) begin
            if(cnt_clk_source > 4999) begin
                 cnt_clk_source = 0; //clear
                 cp_div_10000 = ~ cp_div_10000; //usec의 반주기마다 토글되도록
            end
            else cnt_clk_source = cnt_clk_source + 1;
        end
    end
        // assign cp_msec = cnt_clk_source >= 49 ? 1: 0; 위 if문에 500마다설정해줫으므로 필요없음
        edge_detector_n ed(.clk(clk), .reset_p(reset_p),
                            .cp(cp_div_10000), .n_edge(clk_div_10000));
    //상승엣지 잡아서 써도 1msec 하강엣지써도 1msec임 어차피 한주기는 1msec니까

endmodule



module counter_dec_100( //decimal로 60까지 세는 카운터
    input clk, reset_p,
    input clk_time,
    output reg [3:0] dec1, dec10); //1의자리 10의자리 따로내보내서 fnd에 출력

    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin
            dec1 = 0;
            dec10 = 0;    
        end
        else begin
            if(clk_time) begin
    //  else if(clk_time) begin
                if(dec1 >= 9) begin
                    dec1 = 0;
                    if(dec10 >= 9) dec10 = 0;
                    else dec10 = dec10 + 1;
                end
                else dec1 = dec1 + 1; 

            end
        end
    end

endmodule