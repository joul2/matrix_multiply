// `timescale 1ns / 1ps
// Top_systolic
// // 16x16 脉冲阵列顶层模块
// module Top_systolic(
//     input wire clk,
//     input wire rst,
//     input wire start,
//     input wire [DATA_WIDTH-1:0] a_data,
//     input wire [DATA_WIDTH-1:0] b_data,
//     input wire a_valid,
//     input wire b_valid,
//     output reg [ACCUM_WIDTH-1:0] c_data,
//     output reg c_valid,
//     output reg done
// );

//     // 16x16 PE阵列的连接信号
//     wire [DATA_WIDTH-1:0] h_data [0:15][0:16]; // 水平数据流，每行多一个用于边界
//     wire [DATA_WIDTH-1:0] v_data [0:16][0:15]; // 垂直数据流，每列多一个用于边界
//     wire [ACCUM_WIDTH-1:0] pe_sum [0:15][0:15]; // PE输出
    
//     // 控制信号
//     reg [11:0] cycle_count;
//     reg [ACCUM_WIDTH-1:0] block_row, block_col;
//     reg [ACCUM_WIDTH-1:0] in_row, in_col;
//     reg computing;
    
//     // 数据缓冲
//     reg [DATA_WIDTH-1:0] a_buffer [0:31][0:15]; // A矩阵数据缓冲
//     reg [DATA_WIDTH-1:0] b_buffer [0:31][0:15]; // B矩阵数据缓冲
//     reg [ACCUM_WIDTH-1:0] c_buffer [0:15][0:15]; // C矩阵累积缓冲
    
//     // 状态机状态
//     typedef enum reg [2:0] {
//         IDLE,
//         LOAD_DATA,
//         COMPUTE,
//         OUTPUT,
//         NEXT_BLOCK
//     } state_t;
    
//     state_t current_state, next_state;
    
//     // 状态机时序逻辑
//     always @(posedge clk) begin
//         if (rst) begin
//             current_state <= IDLE;
//         end else begin
//             current_state <= next_state;
//         end
//     end
    
//     // 状态机组合逻辑
//     always @(*) begin
//         next_state = current_state;
//         case (current_state)
//             IDLE: begin
//                 if (start) next_state = LOAD_DATA;
//             end
//             LOAD_DATA: begin
//                 if (cycle_count == 12'd511) next_state = COMPUTE; // 32个周期加载数据
//             end
//             COMPUTE: begin
//                 if (cycle_count == 12'd47) next_state = OUTPUT; // 48个周期计算
//             end
//             OUTPUT: begin
//                 if (cycle_count == 12'd255) begin // 256个周期输出
//                     if (block_row == 8'd15 && block_col == 8'd15) 
//                         next_state = IDLE;
//                     else 
//                         next_state = NEXT_BLOCK;
//                 end
//             end
//             NEXT_BLOCK: begin
//                 next_state = LOAD_DATA;
//             end
//         endcase
//     end
    
//     // 控制逻辑
//     always @(posedge clk) begin
//         if (rst) begin
//             cycle_count <= 0;
//             block_row <= 0;
//             block_col <= 0;
//             in_row <= 0;
//             in_col <= 0;
//             computing <= 0;
//             done <= 0;
//             c_valid <= 0;
//         end else begin
//             case (current_state)
//                 IDLE: begin
//                     cycle_count <= 0;
//                     block_row <= 0;
//                     block_col <= 0;
//                     done <= 0;
//                     computing <= 0;
//                 end
                
//                 LOAD_DATA: begin
//                     cycle_count <= cycle_count + 1;
//                     // 加载A和B矩阵的16x16块数据
//                     if (a_valid && cycle_count < 256) begin
//                         a_buffer[cycle_count[8:4]][cycle_count[DATA_WIDTH-1:0]] <= a_data;
//                     end
//                     if (b_valid && cycle_count >= 256 && cycle_count < 512) begin
//                         b_buffer[cycle_count[8:4] - 16][cycle_count[DATA_WIDTH-1:0]] <= b_data;
//                     end
//                 end
                
//                 COMPUTE: begin
//                     cycle_count <= cycle_count + 1;
//                     computing <= 1;
//                 end
                
//                 OUTPUT: begin
//                     cycle_count <= cycle_count + 1;
//                     computing <= 0;
//                     c_valid <= 1;
//                     c_data <= c_buffer[cycle_count[ACCUM_WIDTH-1:4]][cycle_count[DATA_WIDTH-1:0]];
//                 end
                
//                 NEXT_BLOCK: begin
//                     cycle_count <= 0;
//                     if (block_col == 8'd15) begin
//                         block_col <= 0;
//                         block_row <= block_row + 1;
//                     end else begin
//                         block_col <= block_col + 1;
//                     end
//                     if (block_row == 8'd15 && block_col == 8'd15) begin
//                         done <= 1;
//                     end
//                     // 清零累积缓冲
//                     for (int i = 0; i < 16; i++) begin
//                         for (int j = 0; j < 16; j++) begin
//                             c_buffer[i][j] <= 0;
//                         end
//                     end
//                 end
//             endcase
//         end
//     end
    
//     // 为脉冲阵列提供边界输入
//     genvar i, j;
//     generate
//         // 左边界输入 (A矩阵数据)
//         for (i = 0; i < 16; i++) begin : left_boundary
//             always @(posedge clk) begin
//                 if (rst) begin
//                     h_data[i][0] <= 0;
//                 end else if (computing && cycle_count < 32) begin
//                     if (cycle_count >= i && cycle_count < (i + 16)) begin
//                         h_data[i][0] <= a_buffer[cycle_count - i][i];
//                     end else begin
//                         h_data[i][0] <= 0;
//                     end
//                 end else begin
//                     h_data[i][0] <= 0;
//                 end
//             end
//         end
        
//         // 上边界输入 (B矩阵数据)
//         for (j = 0; j < 16; j++) begin : top_boundary
//             always @(posedge clk) begin
//                 if (rst) begin
//                     v_data[0][j] <= 0;
//                 end else if (computing && cycle_count < 32) begin
//                     if (cycle_count >= j && cycle_count < (j + 16)) begin
//                         v_data[0][j] <= b_buffer[cycle_count - j][j];
//                     end else begin
//                         v_data[0][j] <= 0;
//                     end
//                 end else begin
//                     v_data[0][j] <= 0;
//                 end
//             end
//         end
//     endgenerate
    
//     // 实例化16x16 PE阵列
//     generate
//         for (i = 0; i < 16; i++) begin : pe_row
//             for (j = 0; j < 16; j++) begin : pe_col
//                 PE_unit pe_inst (
//                     .clk(clk),
//                     .rst(rst),
//                     .a_in(h_data[i][j]),
//                     .b_in(v_data[i][j]),
//                     .a_out(h_data[i][j+1]),
//                     .b_out(v_data[i+1][j]),
//                     .c_out(pe_sum[i][j])
//                 );
//             end
//         end
//     endgenerate
    
//     // 收集PE输出到缓冲区
//     always @(posedge clk) begin
//         if (computing) begin
//             for (int i = 0; i < 16; i++) begin
//                 for (int j = 0; j < 16; j++) begin
//                     c_buffer[i][j] <= c_buffer[i][j] + pe_sum[i][j];
//                 end
//             end
//         end
//     end

// endmodule

// // 处理单元 (PE)
// module PE_unit(
//     input wire clk,
//     input wire rst,
//     input wire [DATA_WIDTH-1:0] a_in,
//     input wire [DATA_WIDTH-1:0] b_in,
//     output reg [DATA_WIDTH-1:0] a_out,
//     output reg [DATA_WIDTH-1:0] b_out,
//     output wire [ACCUM_WIDTH-1:0] c_out
// );

//     reg [DATA_WIDTH-1:0] a_reg, b_reg;
//     wire [ACCUM_WIDTH-1:0] mult_result;
    
//     // 寄存器传递数据
//     always @(posedge clk) begin
//         if (rst) begin
//             a_out <= 0;
//             b_out <= 0;
//             a_reg <= 0;
//             b_reg <= 0;
//         end else begin
//             a_out <= a_in;
//             b_out <= b_in;
//             a_reg <= a_in;
//             b_reg <= b_in;
//         end
//     end
    
//     // 乘法器
//     assign mult_result = a_reg * b_reg;
//     assign c_out = mult_result;

// endmodule

`timescale 1ns / 1ps
module Top_systolic(
    clk, rst, en, in1, in2, out
);
parameter DATA_WIDTH = 4;
parameter ACCUM_WIDTH = 16;
parameter BS = 16;
parameter M = 256;
parameter NUMB = M / BS;
input clk;
input rst;
input en;
input [DATA_WIDTH*M*M-1:0] in1;
input [DATA_WIDTH*M*M-1:0] in2;
output reg [ACCUM_WIDTH*M*M-1:0] out;

reg [ACCUM_WIDTH-1:0] C [0:M*M-1];

reg [DATA_WIDTH-1:0] row [0:BS-1][0:2*BS-2];
reg [DATA_WIDTH-1:0] col [0:BS-1][0:2*BS-2];

// 应该是根据PE的分块决定的
reg [3:0] ib, jb;
reg [4:0] kb;
reg [3:0] state;
reg [4:0] flag;
reg [5:0] flush_cnt;
reg clear;

reg [DATA_WIDTH-1:0] left [0:BS-1];
reg [DATA_WIDTH-1:0] up [0:BS-1];

// always @(*) begin
//     if(rst) begin
//        left = 0;
//        up = 0;
//     end
// end

// PE wires
wire [DATA_WIDTH-1:0] right [0:BS-1][0:BS-1];
wire [DATA_WIDTH-1:0] down [0:BS-1][0:BS-1];
wire [ACCUM_WIDTH-1:0] sum_out [0:BS-1][0:BS-1];

// Generate PE array
genvar gi, gj;
generate
    for (gi = 0; gi < BS; gi = gi + 1) begin : row_gen
        for (gj = 0; gj < BS; gj = gj + 1) begin : col_gen
            module_PE pe (
                .clk    (clk),
                .rst    (rst),
                .clear  (clear),
                // .left   ((gj == 0) ? left[gi]   : row_gen[gi].col_gen[gj-1].pe.right[DATA_WIDTH-1:0]),
                // .up     ((gi == 0) ? up[gj]     : row_gen[gi-1].col_gen[gj].pe.down[DATA_WIDTH-1:0]),
                .left   ((gj == 0) ? left[gi]   : right[gi][gj-1]),
                .up     ((gi == 0) ? up[gj]     : down[gi-1][gj]),
                .right  (right[gi][gj]),
                .down   (down[gi][gj]),
                .sum_out(sum_out[gi][gj])
            );
        end
    end
endgenerate

always @(posedge clk) begin
    if (rst) begin
        out <= 0;
        state <= 0;
        flag <= 0;
        flush_cnt <= 0;
        ib <= 0;
        jb <= 0;
        kb <= 0;
        clear <= 1;
        // left <= 0;
        // up <= 0;
        begin : reset_C
            integer cc;
            for (cc = 0; cc < M*M; cc = cc + 1) begin
                C[cc] <= 8'b0;
            end
        end
        begin : reset_left_up
            integer i;
            for (i = 0; i < BS; i = i + 1) begin
                left[i] <= 4'b0;
                up[i]   <= 4'b0;
            end
        end
    end else if (en) begin
        case (state)
            0: begin // init
                clear <= 1;
                ib <= 0;
                jb <= 0;
                kb <= 0;
                state <= 1;
            end
            1: begin // load block
                clear <= 1;
                begin : load_row
                    integer li, lj;
                    integer a_row, a_col, aidx;
                    for (li = 0; li < BS; li = li + 1) begin
                        for (lj = 0; lj < 2*BS-1; lj = lj + 1) begin
                            if (lj < li || lj >= li + BS) begin
                                row[li][lj] <= 4'b0;
                            end else begin
                                a_row = ib * BS + li;
                                a_col = kb * BS + (lj - li);
                                aidx = a_row * M + a_col;
                                row[li][lj] <= in1[4*aidx +: 4];
                            end
                        end
                    end
                end
                begin : load_col
                    integer li2, lj2;
                    integer b_row, b_col, bidx;
                    for (li2 = 0; li2 < BS; li2 = li2 + 1) begin
                        for (lj2 = 0; lj2 < 2*BS-1; lj2 = lj2 + 1) begin
                            if (lj2 < li2 || lj2 >= li2 + BS) begin
                                col[li2][lj2] <= 4'b0;
                            end else begin
                                b_row = kb * BS + (lj2 - li2);
                                b_col = jb * BS + li2;
                                bidx = b_row * M + b_col;
                                col[li2][lj2] <= in2[4*bidx +: 4];
                            end
                        end
                    end
                end
                state <= 2;
            end
            2: begin // start streaming
                clear <= 0;
                flag <= 0;
                flush_cnt <= 0;
                state <= 3;
            end
            3: begin // streaming and flush
                if (flag < 2*BS - 1) begin
                    begin : set_inputs
                        integer rr;
                        for (rr = 0; rr < BS; rr = rr + 1) begin
                            left[rr] <= row[rr][flag];
                            up[rr] <= col[rr][flag];
                        end
                    end
                    flag <= flag + 1;
                end else if (flush_cnt < 2*BS - 1) begin
                    begin : set_zero_flush
                        integer rr2;
                        for (rr2 = 0; rr2 < BS; rr2 = rr2 + 1) begin
                            left[rr2] <= 4'b0;
                            up[rr2] <= 4'b0;
                        end
                    end
                    flush_cnt <= flush_cnt + 1;
                end else begin
                    flush_cnt <= 0;
                    state <= 4;
                end
            end
            4: begin // collect
                begin : collect_C
                    integer ci, cj;
                    integer cidx;
                    for (ci = 0; ci < BS; ci = ci + 1) begin
                        for (cj = 0; cj < BS; cj = cj + 1) begin
                            cidx = (ib * BS + ci) * M + (jb * BS + cj);
                            C[cidx] <= C[cidx] + sum_out[ci][cj];
                        end
                    end
                end
                state <= 5;
            end
            5: begin // next
                kb <= kb + 1;
                if (kb + 1 < NUMB) begin
                    state <= 1;
                end else begin
                    kb <= 0;
                    jb <= jb + 1;
                    if (jb + 1 < NUMB) begin
                        state <= 1;
                    end else begin
                        jb <= 0;
                        ib <= ib + 1;
                        if (ib + 1 < NUMB) begin
                            state <= 1;
                        end else begin
                            state <= 6;
                        end
                    end
                end
            end
            6: begin // output
                begin : set_out
                    integer oi;
                    for (oi = 0; oi < M*M; oi = oi + 1) begin
                        out[ACCUM_WIDTH*oi +: ACCUM_WIDTH] <= C[oi];
                    end
                end
                state <= 6;
            end
            default: begin
                state <= 0;
            end
        endcase
    end
end

endmodule

`timescale 1ns / 1ps

module module_PE#(
    parameter DATA_WIDTH = 4,
    parameter ACCUM_WIDTH = 16
)(
    clk,
    rst,
    clear,
    left,
    up,
    down,
    right,
    sum_out
);
    input clk;
    input rst;
    input clear;
    input [DATA_WIDTH-1:0] left;
    input [DATA_WIDTH-1:0] up;
    output reg [DATA_WIDTH-1:0] down;
    output reg [DATA_WIDTH-1:0] right;
    output reg [ACCUM_WIDTH-1:0] sum_out;

    wire [ACCUM_WIDTH-1:0] mult_out;

    always @(posedge clk) begin
        if (rst) begin
            right <= 0;
            down <= 0;
            sum_out <= 0;
        end else if (clear) begin
            sum_out <= 0;
            right <= left;
            down <= up;
        end else begin
            down <= up;
            right <= left;
            sum_out <= sum_out + mult_out;
        end
    end

    multiply u_mult(
        .a(left),
        .b(up),
        .out(mult_out)
    );

endmodule

module multiply#(
    parameter DATA_WIDTH = 4,
    parameter ACCUM_WIDTH = 16
)(a, b, out);
    input [DATA_WIDTH-1:0] a;
    input [DATA_WIDTH-1:0] b;
    output wire [ACCUM_WIDTH-1:0] out;
    assign out = a * b;
endmodule

