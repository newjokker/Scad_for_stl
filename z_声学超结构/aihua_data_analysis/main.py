#! /bin/bash/env python
# -*- coding: utf-8 -*-
# ===== compiler flag =====
# distutils: language = c++
# cython: language_level = 3
# ===== compiler flag =====
# ! /bin/bash/env python
# -*- coding: utf-8 -*-
import os
import glob
import pandas as pd
from config import Config
from func_data_clean import data_rename
from func_freq_and_audio import run_analysis_pipeline
from func_A_weighting_cal import run_a_weighting_pipeline


def load_data_dictionary():
    """
    统一数据装载器：
    返回格式 -> { "测点名称": { "结构名称": ["路径1.wav", "路径2.wav"] } }
    """
    experiments = {}

    if Config.DATA_MODE == "FOLDER":
        print("📁 检测到 [FOLDER 文件夹模式]...")
        loc_name = Config.FOLDER_LOCATION_NAME
        experiments[loc_name] = {}

        structs = [d for d in os.listdir(Config.RAW_DATA_DIR) if os.path.isdir(os.path.join(Config.RAW_DATA_DIR, d))]
        for struct in structs:
            files = glob.glob(os.path.join(Config.RAW_DATA_DIR, struct, "*.wav"))
            if files:
                experiments[loc_name][struct] = files

    elif Config.DATA_MODE == "EXCEL":
        print("📊 检测到 [EXCEL 表格模式]...")
        # 1. 强制执行数据清洗落盘
        data_rename(Config.RAW_DATA_DIR, Config.EXCEL_PATH, Config.OUTPUT_DIR, Config.SHEET_NAME)

        # 2. 读取 Excel 获取测点列，反向解析生成标准字典
        df = pd.read_excel(Config.EXCEL_PATH, sheet_name=Config.SHEET_NAME)
        exp_columns = df.columns[2:]  # 第3列开始是测点

        for loc_name in exp_columns:
            safe_loc_name = loc_name.replace("/", "_").replace("\\", "_")
            experiments[loc_name] = {}

            # 从清洗后的输出目录抓取该测点的文件
            search_pattern = os.path.join(Config.OUTPUT_DIR, f"*_{safe_loc_name}_Trial*.wav")
            all_trial_files = glob.glob(search_pattern)
            structs_in_this_exp = set([os.path.basename(f).split(f"_{safe_loc_name}_")[0] for f in all_trial_files])

            for struct in structs_in_this_exp:
                struct_files = [f for f in all_trial_files if
                                os.path.basename(f).startswith(f"{struct}_{safe_loc_name}_")]
                if struct_files:
                    experiments[loc_name][struct] = struct_files

    return experiments


if __name__ == '__main__':
    print("=" * 50)
    print(f" 🚀 工业降噪分析自动化流水线启动 (当前模式: {Config.DATA_MODE})")
    print("=" * 50)

    os.makedirs(Config.OUTPUT_DIR, exist_ok=True)

    # 核心解耦：提取统一的数据字典
    experiment_data = load_data_dictionary()

    if not experiment_data:
        print("⚠️ 未找到任何有效数据，请检查配置路径或模式选择。")
        exit()

    # 遍历所有测点（文件夹模式只有1个，Excel模式可能有多个）
    for loc_name, struct_dict in experiment_data.items():
        print(f"\n" + "=" * 40)
        print(f" 🎯 开始处理测点: {loc_name}")
        print("=" * 40)

        print(f">>> [步骤 1/2] 提取窄带/1/3倍频程特征，执行多极值寻优...")
        run_analysis_pipeline(
            struct_file_dict=struct_dict,
            output_dir=Config.OUTPUT_DIR,
            is_steady_noise=Config.IS_STEADY_NOISE,
            ref_list=Config.ref_list,
            f_min=Config.FREQ_MIN,
            f_max=Config.FREQ_MAX,
            loc_name=loc_name
        )

        print(f"\n>>> [步骤 2/2] 计算等效A计权声级 (LAeq) 与总体评价...")
        run_a_weighting_pipeline(
            struct_file_dict=struct_dict,
            output_dir=Config.OUTPUT_DIR,
            ref_list=Config.ref_list,
            loc_name=loc_name
        )

    print("\n✅ 全部分析流程执行完毕！请前往输出目录查看 CSV 数据与图表。")
