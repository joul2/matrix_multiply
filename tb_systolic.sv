// // 测试平台
// tb_systolic
// module tb_systolic();
    
//     reg clk;
//     reg rst;
//     reg start;
//     reg [3:0] a_data, b_data;
//     reg a_valid, b_valid;
//     wire [7:0] c_data;
//     wire c_valid;
//     wire done;
    
//     // 测试矩阵数据
//     reg [3:0] test_a [0:255][0:255];
//     reg [3:0] test_b [0:255][0:255];
//     reg [15:0] expected_c [0:255][0:255];
    
//     integer i, j, k;
//     integer block_row, block_col;
//     integer data_count;
    
//     // 时钟生成
//     initial begin
//         clk = 0;
//         forever #5 clk = ~clk;
//     end
    
//     // 初始化测试数据
//     initial begin
//         // 复位
//         rst = 1;
//         start = 0;
//         a_data = 0;
//         b_data = 0;
//         a_valid = 0;
//         b_valid = 0;
        
//         #20;
//         rst = 0;
        
//         // 初始化测试矩阵 (简单的递增模式)
//         for (i = 0; i < 256; i++) begin
//             for (j = 0; j < 256; j++) begin
//                 test_a[i][j] = (i + j) % 16;
//                 test_b[i][j] = (i * j) % 16;
//             end
//         end
        
//         // 计算期望结果 (仅计算前16x16块作为验证)
//         for (i = 0; i < 16; i++) begin
//             for (j = 0; j < 16; j++) begin
//                 expected_c[i][j] = 0;
//                 for (k = 0; k < 16; k++) begin
//                     expected_c[i][j] = expected_c[i][j] + test_a[i][k] * test_b[k][j];
//                 end
//             end
//         end
        
//         #50;
        
//         // 开始测试第一个16x16块
//         start = 1;
//         #10;
//         start = 0;
        
//         // 等待加载数据状态，然后提供数据
//         wait(dut.current_state == dut.LOAD_DATA);
        
//         // 提供A矩阵数据
//         data_count = 0;
//         for (i = 0; i < 16; i++) begin
//             for (j = 0; j < 16; j++) begin
//                 @(posedge clk);
//                 a_data <= test_a[i][j];
//                 a_valid <= 1;
//             end
//         end
//         a_valid <= 0;
        
//         // 提供B矩阵数据
//         for (i = 0; i < 16; i++) begin
//             for (j = 0; j < 16; j++) begin
//                 @(posedge clk);
//                 b_data <= test_b[i][j];
//                 b_valid <= 1;
//             end
//         end
//         b_valid <= 0;
        
//         // 等待计算完成
//         wait(dut.current_state == dut.OUTPUT);
        
//         // 检查输出结果
//         data_count = 0;
//         for (i = 0; i < 16; i++) begin
//             for (j = 0; j < 16; j++) begin
//                 wait(c_valid);
//                 @(posedge clk);
//                 if (c_data != expected_c[i][j][7:0]) begin
//                     $display("ERROR: C[%0d][%0d] = %0d, expected = %0d", 
//                             i, j, c_data, expected_c[i][j][7:0]);
//                 end else begin
//                     $display("PASS: C[%0d][%0d] = %0d", i, j, c_data);
//                 end
//             end
//         end
        
//         wait(done);
//         $display("Test completed!");
//         #100;
//         $finish;
//     end
    
//     // 实例化DUT
//     Top_systolic dut(
//         .clk(clk),
//         .rst(rst),
//         .start(start),
//         .a_data(a_data),
//         .b_data(b_data),
//         .a_valid(a_valid),
//         .b_valid(b_valid),
//         .c_data(c_data),
//         .c_valid(c_valid),
//         .done(done)
//     );

// endmodule

`timescale 1ns / 1ps
module tb_systolic();
parameter DATA_WIDTH = 4;
parameter ACCUM_WIDTH = 16;
parameter M = 256;
reg clk;
reg rst;
reg en;
reg [DATA_WIDTH*M*M-1:0] in1;
reg [DATA_WIDTH*M*M-1:0] in2;
wire [ACCUM_WIDTH*M*M-1:0] out;


initial begin
    clk = 0;
    rst = 0;
    en = 0;
    in1 = 0;
    in2 = 0;
    #10
    rst = 1;

    #10
    rst = 0;
    generate_data();


    #10
    en = 1;
    // #3000000 // Increased time to allow completion (approximate)
    #2800000 // Increased time to allow completion (approximate)
    // verify_results();

    unpack_out();   // 将out拆成二维数组
    write_csv();    // 写入CSV

    $finish;
end


always #5 clk = ~clk;

Top_systolic u_top(
    .clk(clk),
    .rst(rst),
    .en(en),
    .in1(in1),
    .in2(in2),
    .out(out)
);

// 结果验证
task verify_results;
    integer row, col, k;
    reg [8-1:0] expected_result;
    reg [8-1:0] actual_result;
    integer error_count;
    begin
        $display("TEST STARTED...");
        error_count = 0;
        
        // 软件参考计算（仅验证前16x16块）
        for (row = 0; row < 16; row++) begin
            for (col = 0; col < 16; col++) begin
                expected_result = 0;
                for (k = 0; k < M; k++) begin
                    expected_result = expected_result + (in1[row * M + k] * in2[k * M + col]);
                end
                
                actual_result = out[row * M + col];
                
                if (expected_result != actual_result) begin
                    $display("ERROR: location[%d][%d], expect=%h, real=%h",
                                            row, col, expected_result, actual_result);
                    error_count = error_count + 1;
                end
            end
        end
        
        if (error_count == 0) begin
            $display("TEST PASS! ALL CORRECT");
        end else begin
            $display("TEST FAILED, ERROR found: %d", error_count);
        end
    end
endtask

// task generate_data;

//     begin : set_in1
//         integer ti, tj;
//         for (ti = 0; ti < M; ti = ti + 1) begin
//             for (tj = 0; tj < M; tj = tj + 1) begin
//                 in1[4*(ti*M + tj) +: 4] = (ti + tj) % 16; // Example values 0-15
//                 // if(ti == tj)
//                 //     in1[4*(ti*M + tj) +: 4] = 4'b1;
//             end
//         end
//     end
//     begin : set_in2
//         integer ti2, tj2;
//         for (ti2 = 0; ti2 < M; ti2 = ti2 + 1) begin
//             for (tj2 = 0; tj2 < M; tj2 = tj2 + 1) begin
//                 // in2[4*(ti2*M + tj2) +: 4] = (ti2 + tj2 + 1) % 16; // Example values 0-15
//                 if(ti2 == tj2)
//                     in2[4*(ti2*M + tj2) +: 4] = 4'b1;
//             end
//         end
//     end
// endtask

task generate_data;
    integer i, j;
    integer f_a, f_b;
    integer value;
    string line;

    begin : read_in1
        f_a = $fopen("matrix_A.csv", "r");
        if (!f_a) begin
            $fatal("Failed to open matrix_A.csv");
        end
        for (i = 0; i < M; i++) begin
            for (j = 0; j < M; j++) begin
                void'($fscanf(f_a, "%d,", value));
                in1[4*(i*M + j) +: 4] = value[3:0]; // 强制只保留低4位
            end
        end
        $fclose(f_a);
    end

    begin : read_in2
        f_b = $fopen("matrix_B.csv", "r");
        if (!f_b) begin
            $fatal("Failed to open matrix_B.csv");
        end
        for (i = 0; i < M; i++) begin
            for (j = 0; j < M; j++) begin
                void'($fscanf(f_b, "%d,", value));
                in2[4*(i*M + j) +: 4] = value[3:0]; // 强制只保留低4位
            end
        end
        $fclose(f_b);
    end
endtask




integer fd; // 文件句柄
integer row, col;
reg [ACCUM_WIDTH-1:0] out_matrix [0:M-1][0:M-1]; // 中间数组用于提取 out 中的每个 8-bit 元素

// 将out向二维数组中解包（用于写入）
task unpack_out;
    begin
        for (row = 0; row < M; row = row + 1) begin
            for (col = 0; col < M; col = col + 1) begin
                out_matrix[row][col] = out[ACCUM_WIDTH*(row*M + col) +: ACCUM_WIDTH];
            end
        end
    end
endtask

// 写入CSV文件
task write_csv;
    begin
        // fd = $fopen("result.csv", "w");
        fd = $fopen("matrix_C_verilog.csv", "w");
        
        if (fd == 0) begin
            $display("ERROR: Failed to open file for writing.");
            $finish;
        end

        for (row = 0; row < M; row = row + 1) begin
            for (col = 0; col < M; col = col + 1) begin
                // 写入数据，加逗号（行末不加）
                if (col < M - 1)
                    $fwrite(fd, "%0d,", out_matrix[row][col]);
                else
                    $fwrite(fd, "%0d\n", out_matrix[row][col]); // 行末加换行
            end
        end

        $fclose(fd);
        // $display("CSV file 'result.csv' written successfully.");
        $display("CSV file 'matrix_C_verilog.csv' written successfully.");
    end
endtask



endmodule