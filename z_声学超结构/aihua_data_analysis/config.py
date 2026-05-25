#! /bin/bash/env python
# -*- coding: utf-8 -*-
# ===== compiler flag =====
# distutils: language = c++
# cython: language_level = 3
# ===== compiler flag =====
import os


class Config:
    # ================= 核心模式切换 =================
    # 可选值: "FOLDER" (文件夹直读) 或 "EXCEL" (表格解析重命名)
    DATA_MODE = "FOLDER"

    # --- 公共配置 ---
    RAW_DATA_DIR = r"/Volumes/Jokker/Code/Scad_for_stl/z_声学超结构/data/2026-05-16_泡沫铝/重构/内"
    FREQ_MIN = 200  # 分析频率下限
    FREQ_MAX = 4500  # 分析频率上线
    IS_STEADY_NOISE = True  # True对应稳定声源，False对应扫频声源
    ref_list = ['一块泡沫铝']  # 对比结构列表，不限元素个数

    # --- 文件夹模式专用配置 ---
    FOLDER_LOCATION_NAME = "箱内测点"

    # --- Excel模式专用配置 ---
    EXCEL_NAME = "新建 XLSX 工作表.xlsx"
    EXCEL_PATH = os.path.join(RAW_DATA_DIR, EXCEL_NAME)  # excel路径
    SHEET_NAME = "背板降噪"

    # --- 配置保存路径 ---
    if DATA_MODE == "FOLDER":
        OUTPUT_DIR = RAW_DATA_DIR + "-分析结果"
    elif DATA_MODE == "EXCEL":
        OUTPUT_DIR = RAW_DATA_DIR + "-" + SHEET_NAME
    else:
        raise 'MODE is wrong'
    # --- 产物生成开关 ---
    ENABLE_RESULT_PLOTS = True
    ENABLE_DIAG_PLOTS = True
    GENERATE_AUDIO_DEMOS = False
    wav_duration = 100
