# save_matrices.py
import numpy as np
import csv

M = 256
# 示例：矩阵 A 每个元素为 (i + j) % 16
A = np.fromfunction(lambda i, j: (i + j) % 16, (M, M), dtype=int)

# 示例：矩阵 B 为单位矩阵（可修改为其他内容）
# B = np.eye(M, dtype=int)
B = np.fromfunction(lambda i, j: (i + j) % 16, (M, M), dtype=int)

# 将 A 写入 CSV
with open("matrix_A.csv", "w", newline='') as f:
    writer = csv.writer(f)
    writer.writerows(A.astype(int))

# 将 B 写入 CSV
with open("matrix_B.csv", "w", newline='') as f:
    writer = csv.writer(f)
    writer.writerows(B.astype(int))
