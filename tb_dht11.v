`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////



module tb_dht11();

    reg clk, reset_p; //reg=>pull up 된 와이어, test를 위해 input을 reg로 입력을 주고
    tri1 dht11_data;//tri1 : 1일때 활성화되는 3상버퍼, Testbench에서만 사용
    //pullup달려있어서 평상시에는 임피던스를 출력   
    wire [7:0] humidity, temperature;// output은 wire로 확인하기
    
    dht11 DUT(clk, reset_p, dht11_data, humidity, temperature);

    reg dout, wr;
    assign dht11_data = wr ? dout : 1'bz;

    parameter [7:0] humi_value = 8'd80;
    parameter [7:0] tmpr_value = 8'd25;
    parameter [7:0] check_sum = humi_value + tmpr_value;
    parameter [39:0] data = {humi_value, 8'b0, tmpr_value, {8{1'b0}}, check_sum}; //{8{1'b0}}반복연산자

    initial begin // reg들 초기화
        clk = 0;
        reset_p = 1; #10;

        wr = 0;
    end

    always #5 clk = ~clk; //#5 -> delay 시간을 끈다, 5ns후에 1 -> 한 주기는 10ns

    integer i;
    initial begin
        #10;
        reset_p = 0;
        wait(!dht11_data); //while문, data가 들어올때까지 빠져나가지 못함
        wait(dht11_data); //data가 안들어오기 시작해야 나감
        #20000; //20us
        dout = 0; wr = 1; #80000;
        wr = 0; #80000;
        wr = 1;

        for (i=0; i<40; i=i+1 ) begin
            dout = 0; #50000; //50us동안 임피던스 출력
            dout = 1;
            if(data[39-i]) #70000; //1이면 70us동안 지속
            else #27000; //0이면 27us동안 지속
        end
        dout = 0; wr = 1; #10;
        wr = 0; #10000;

        $stop; //시뮬레이션 종료

    end

endmodule

