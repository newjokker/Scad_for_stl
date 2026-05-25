#! /bin/bash/env python
# -*- coding: utf-8 -*-
# ===== compiler flag =====
# distutils: language = c++
# cython: language_level = 3
# ===== compiler flag =====
import os
import glob
import numpy as np
import matplotlib.pyplot as plt
import soundfile as sf
import pandas as pd
from scipy.signal import stft
import matplotlib
from config import Config

matplotlib.use('Qt5Agg')
plt.rcParams['font.sans-serif'] = ['SimHei']
plt.rcParams['axes.unicode_minus'] = False


def get_a_weighting_gains(freqs):
    f_sq = freqs ** 2
    R_A = (12194 ** 2 * f_sq ** 2) / \
          ((f_sq + 20.6 ** 2) * np.sqrt((f_sq + 107.7 ** 2) * (f_sq + 737.9 ** 2)) * (f_sq + 12194 ** 2) + 1e-10)
    return 20 * np.log10(R_A + 1e-10) + 2.00


def calculate_A_weighted_levels(filepath, frame_ms=125):
    data, fs = sf.read(filepath)
    if data.ndim > 1: data = data[:, 0]
    nperseg = int(fs * (frame_ms / 1000.0))
    noverlap = int(nperseg * 0.5)
    f, t, Zxx = stft(data, fs=fs, nperseg=nperseg, noverlap=noverlap)

    power_spec = np.abs(Zxx) ** 2
    a_weights_db = get_a_weighting_gains(f)
    a_weights_linear = 10 ** (a_weights_db / 10.0)
    power_spec_A = power_spec * a_weights_linear[:, np.newaxis]

    rt_power = np.sum(power_spec_A, axis=0)
    L_A_t = 10 * np.log10(rt_power + 1e-12)
    L_Aeq = 10 * np.log10(np.mean(rt_power) + 1e-12)

    return t, L_A_t, L_Aeq


def plot_and_save_LAeq(results_dict, rep_files_dict, loc_name, output_dir, ref_name=None, calib_offset=100.0):
    """根据计算好的数据绘制并保存图表，彻底解耦界面展示"""
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 10))
    cmap = plt.get_cmap('tab10')
    colors = {label: cmap(i) for i, label in enumerate(results_dict.keys())}

    # 上图：选取每个结构的 Trial 1 绘制时间曲线代表
    for label, filepath in rep_files_dict.items():
        t, L_A_t, _ = calculate_A_weighted_levels(filepath, frame_ms=125)
        L_A_t += calib_offset
        avg_laeq = results_dict[label]
        ax1.plot(t, L_A_t, label=f"{label} (均值 LAeq={avg_laeq:.1f}dB)", color=colors[label], alpha=0.8, lw=1.5)

    ax1.set_title(f"[{loc_name}] 实时 A计权声级代表曲线 (Fast档)", fontsize=14)
    ax1.set_xlabel("时间 (秒)", fontsize=12)
    ax1.set_ylabel("声压级 (dBA)", fontsize=12)
    ax1.grid(True, linestyle='--', alpha=0.6)
    ax1.legend(loc='upper right')

    # 下图：绘制均值柱状图
    labels = list(results_dict.keys())
    laeq_values = [results_dict[lbl] for lbl in labels]
    bars = ax2.bar(labels, laeq_values, color=[colors[lbl] for lbl in labels], width=0.5, alpha=0.9)

    if ref_name and ref_name in results_dict:
        ref_laeq = results_dict[ref_name]
        for bar, lbl, val in zip(bars, labels, laeq_values):
            if lbl == ref_name:
                ax2.text(bar.get_x() + bar.get_width() / 2, val + 0.5, f"基准: {val:.1f} dB", ha='center', va='bottom',
                         fontweight='bold')
            else:
                il = ref_laeq - val
                color_text = 'green' if il > 0 else 'red'
                il_str = f"降噪: +{il:.1f} dB" if il > 0 else f"恶化: {il:.1f} dB"
                ax2.text(bar.get_x() + bar.get_width() / 2, val + 0.5, f"{val:.1f} dB\n({il_str})", ha='center',
                         va='bottom', color=color_text, fontweight='bold')

    ax2.set_ylim(min(laeq_values) - 15, max(laeq_values) + 8)
    ax2.set_title(f"[{loc_name}] 多次实验平均等效 A计权声级 (L_Aeq) 对比", fontsize=14)
    ax2.set_ylabel("平均等效声压级 (dBA)", fontsize=12)
    ax2.grid(True, axis='y', linestyle='--', alpha=0.6)

    plt.tight_layout()
    save_path = os.path.join(output_dir, f"{loc_name}-总体A计权对比.png")
    plt.savefig(save_path, dpi=300)
    plt.close()


def plot_trial_stability_check(struct_name, struct_files, loc_name, output_dir, calib_offset=100.0):
    """绘制同一结构下所有样本的实时A计权声压级曲线，用于剔除异常波动数据"""
    if len(struct_files) <= 1:
        return  # 只有一个样本，无需对比稳定性

    plt.figure(figsize=(10, 5))
    cmap = plt.get_cmap('tab10')

    for i, filepath in enumerate(struct_files):
        t, L_A_t, L_Aeq = calculate_A_weighted_levels(filepath, frame_ms=125)
        L_A_t += calib_offset
        filename = os.path.basename(filepath)

        # 绘制每条测试数据的曲线
        plt.plot(t, L_A_t, label=f"Trial {i + 1} ({filename}) - 均值: {L_Aeq + calib_offset:.1f} dBA",
                 color=cmap(i % 10), alpha=0.8, lw=1.5)

    plt.title(f"[{loc_name}] 结构: {struct_name} - 样本稳定性诊断 (剔除异常数据参考)", fontsize=14)
    plt.xlabel("时间 (秒)", fontsize=12)
    plt.ylabel("实时 A计权声压级 (dBA)", fontsize=12)
    plt.grid(True, linestyle='--', alpha=0.6)

    # 将图例放在图表外部右侧，防止挡住声压级曲线
    plt.legend(bbox_to_anchor=(1.02, 1), loc='upper left', borderaxespad=0., fontsize=9)
    plt.tight_layout()

    # 存放到专门的诊断文件夹中，保持输出目录整洁
    diag_dir = os.path.join(output_dir, f"{loc_name}_稳定性诊断图")
    os.makedirs(diag_dir, exist_ok=True)
    save_path = os.path.join(diag_dir, f"Stability_{struct_name}.png")

    # 使用 bbox_inches='tight' 确保图例不会被裁剪
    plt.savefig(save_path, dpi=200, bbox_inches='tight')
    plt.close()


def run_a_weighting_pipeline(struct_file_dict, output_dir, ref_list, loc_name="默认测点", calib_offset=100.0):
    """A计权总控引擎：处理外部传入的数据字典、计算均值、落盘数据、按需绘图"""
    results_dict = {}
    rep_files_dict = {}  # 用于画图的代表性文件集合
    csv_rows = []

    for struct, struct_files in struct_file_dict.items():
        if not struct_files:
            continue

        # ================= 新增：稳定性诊断图 =================
        if Config.ENABLE_DIAG_PLOTS:
            plot_trial_stability_check(struct, struct_files, loc_name, output_dir, calib_offset)
        # ===================================================

        rep_files_dict[struct] = struct_files[0]  # 取第一个文件作为画波形图的代表
        laeq_list = []

        for file in struct_files:
            _, _, L_Aeq = calculate_A_weighted_levels(file, frame_ms=125)
            laeq_list.append(L_Aeq + calib_offset)

        avg_laeq = np.mean(laeq_list)
        results_dict[struct] = avg_laeq
        print(f"  [{struct}] 实验次数: {len(struct_files)} -> 平均 LAeq = {avg_laeq:.2f} dBA")

        csv_rows.append(
            {"结构名称": struct, "平均 LAeq (dBA)": round(avg_laeq, 2), "实验样本数": len(struct_files)})

    if not results_dict:
        return

    # 1. 永远执行纯数据落盘
    import pandas as pd
    df_res = pd.DataFrame(csv_rows)
    csv_path = os.path.join(output_dir, f"{loc_name}-A计权声级统计.csv")
    df_res.to_csv(csv_path, index=False, encoding='utf-8-sig')

    # 2. 根据开关决定是否执行耗时的绘图与 I/O 操作
    if Config.ENABLE_RESULT_PLOTS:
        existing_refs = [ref for ref in ref_list if ref in results_dict]
        current_ref = existing_refs[0] if existing_refs else None
        plot_and_save_LAeq(results_dict, rep_files_dict, loc_name, output_dir, current_ref, calib_offset)
