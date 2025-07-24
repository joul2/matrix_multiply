import numpy as np
import csv

# 读取矩阵 A、B
A = np.loadtxt("matrix_A.csv", delimiter=",", dtype=int)
B = np.loadtxt("matrix_B.csv", delimiter=",", dtype=int)

# 计算 C = A × B
C_python = np.matmul(A, B)

# 读取 Verilog 输出的矩阵 C
try:
    C_verilog = np.loadtxt("matrix_C_verilog.csv", delimiter=",", dtype=int)
except Exception as e:
    print("读取 Verilog 结果失败:", e)
    exit(1)

# 确保维度一致
if C_python.shape != C_verilog.shape:
    print(f"维度不一致: Python结果{C_python.shape}, Verilog结果{C_verilog.shape}")
    exit(1)

# 比较两个矩阵
diffs = []
rows, cols = C_python.shape
for i in range(rows):
    for j in range(cols):
        py_val = C_python[i, j]
        verilog_val = C_verilog[i, j]
        if py_val != verilog_val:
            diffs.append((i, j, py_val, verilog_val))

# 输出结果
if diffs:
    print(f"共有 {len(diffs)} 个不一致项：")
    for i, j, py_val, verilog_val in diffs[:10]:  # 只展示前10个
        print(f"差异位置 row={i}, col={j} | Python: {py_val}, Verilog: {verilog_val}")
    print("...")
    # 可选：保存差异报告
    with open("matrix_diff.csv", "w", newline='') as f:
        writer = csv.writer(f)
        writer.writerow(["row", "col", "python_value", "verilog_value"])
        writer.writerows(diffs)
    print("完整差异报告保存在 matrix_diff.csv")
else:
    print("✅ 所有结果一致！")
