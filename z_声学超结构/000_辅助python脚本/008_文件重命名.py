
import os
import pandas as pd

# ===================== 配置 =====================
csv_path = "/Volumes/Jokker/Code/Scad_for_stl/z_声学超结构/data/2026-03-30/文件名信息.csv"

# 原始 wav 文件所在目录
wav_dir = "/Volumes/Jokker/Code/Scad_for_stl/z_声学超结构/data/2026-03-30"

# ===================== 读取 CSV =====================
df = pd.read_csv(csv_path)

# 第一列是结构名称
structure_col = df.columns[0]

# 测点列
measure_cols = df.columns[2:]   # 跳过“风机”列

# ===================== 重命名 =====================
for _, row in df.iterrows():
    structure_name = str(row[structure_col]).strip()

    for col in measure_cols:
        file_name = str(row[col]).strip()

        if file_name == "" or file_name == "nan" or file_name.endswith(".csv"):
            continue

        # 原文件名（补.wav）
        old_name = file_name + ".wav"
        old_path = os.path.join(wav_dir, old_name)

        # 新文件名
        new_name = f"{col}-{structure_name}.wav"
        new_path = os.path.join(wav_dir, new_name)

        if not os.path.exists(old_path):
            print(f"⚠️ 文件不存在: {old_path}")
            continue

        print(f"重命名: {old_name} -> {new_name}")
        os.rename(old_path, new_path)

print("✅ 全部处理完成")