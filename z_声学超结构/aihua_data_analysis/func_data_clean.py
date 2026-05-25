#! /bin/bash/env python
# -*- coding: utf-8 -*-
# ===== compiler flag =====
# distutils: language = c++
# cython: language_level = 3
# ===== compiler flag =====
# ! /bin/bash/env python
# -*- coding: utf-8 -*-
import os
import pandas as pd
import shutil
from config import Config


def data_rename(raw_data_dir, excel_path, output_dir, sheet_name='Sheet1'):
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    # 读取表格数据
    df = pd.read_excel(excel_path, sheet_name=sheet_name)

    # 自适应解析列信息
    col_struct = df.columns[0]  # 第1列：结构名称
    # col_freq = df.columns[1]  # 第2列：频带 (改名脚本中可以暂不使用，主要在分析脚本用)
    exp_columns = df.columns[2:]  # 第3列开始：全部视为独立实验/测点

    trial_counters = {}

    for index, row in df.iterrows():
        struct_name = str(row[col_struct]).strip()
        if pd.isna(struct_name) or struct_name == 'nan':
            continue

        # 初始化当前结构的计数器字典
        if struct_name not in trial_counters:
            trial_counters[struct_name] = {exp_col: 1 for exp_col in exp_columns}

        # 动态遍历所有实验/测点列
        for exp_col in exp_columns:
            file_loc = str(row[exp_col]).strip()

            # 只有当单元格里确实填了文件名时才处理
            if file_loc and file_loc != 'nan':
                if not file_loc.endswith(".wav"):
                    file_loc += ".wav"

                src_path = os.path.join(raw_data_dir, file_loc)
                trial_num = trial_counters[struct_name][exp_col]

                # 清洗列名作为文件名的一部分 (替换掉可能导致路径错误的特殊字符)
                safe_exp_name = exp_col.replace("/", "_").replace("\\", "_")

                new_name = f"{struct_name}_{safe_exp_name}_Trial{trial_num}.wav"
                dst_path = os.path.join(output_dir, new_name)

                if os.path.exists(src_path):
                    shutil.copy2(src_path, dst_path)
                    print(f"✅ [{exp_col}] {file_loc} -> {new_name}")
                    trial_counters[struct_name][exp_col] += 1
                else:
                    print(f"⚠️ 找不到原始文件: {file_loc}")

    print(f"\n✅ 重命名流水线执行完毕！规范化文件已存入: {output_dir}")


if __name__ == '__main__':
    # 路径配置
    RAW_DATA_DIR = Config.RAW_DATA_DIR  # 数据存放路径
    EXCEL_PATH = Config.EXCEL_PATH
    OUTPUT_DIR = Config.OUTPUT_DIR
    SHEET_NAME = Config.SHEET_NAME

    data_rename(RAW_DATA_DIR, EXCEL_PATH, OUTPUT_DIR, sheet_name=SHEET_NAME)
