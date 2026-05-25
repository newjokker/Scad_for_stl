#! /bin/bash/env python
# -*- coding: utf-8 -*-
# ===== compiler flag =====
# distutils: language = c++
# cython: language_level = 3
# ===== compiler flag =====
import os
import glob
import re
import numpy as np
import matplotlib
import matplotlib.pyplot as plt
from scipy.io import wavfile
from scipy.signal import stft, savgol_filter, find_peaks, firwin2, lfilter, medfilt

import pandas as pd

from config import Config

matplotlib.rcParams['font.sans-serif'] = ['SimHei']
matplotlib.rcParams['axes.unicode_minus'] = False
matplotlib.use('Qt5Agg')


# ================= 1. 底层信号处理算法 =================
def extract_steady_response(filepath, f_min, f_max):
    fs, data = wavfile.read(filepath)

    if data.ndim > 1:
        data = data[:, 0]
    if data.dtype == np.int16:
        data = data / 32768.0
    elif data.dtype == np.int32:
        data = data / 2147483648.0

    f, t, Zxx = stft(data, fs=fs, nperseg=8192, noverlap=4096)
    amp_linear = np.abs(Zxx)

    # 修复点 1: 防止平方溢出，先限制极大值
    amp_linear = np.clip(amp_linear, 0, 1e10)

    amp_rms = np.sqrt(np.mean(amp_linear ** 2, axis=1))
    amp_db = 20 * np.log10(amp_rms + 1e-10)

    # 修复点 2: 替换无效值
    amp_db = np.nan_to_num(amp_db, nan=-100.0, posinf=100.0, neginf=-100.0)

    freq_mask = (f >= f_min) & (f <= f_max)
    return f[freq_mask], amp_db[freq_mask]


def extract_sweep_response_strict(filepath, f_min, f_max, diag_dir=None):
    """
    【极严苛模式】只在严格拟合的数学扫频直线上进行窄带拾取，彻底屏蔽宽带及窄带干扰
    """
    fs, data = wavfile.read(filepath)
    if data.ndim > 1: data = data[:, 0]
    if data.dtype == np.int16:
        data = data / 32768.0
    elif data.dtype == np.int32:
        data = data / 2147483648.0

    # 使用超高分辨率 STFT (约 1.34Hz 的频率分辨率)
    f, t, Zxx = stft(data, fs=fs, nperseg=8192, noverlap=6144, nfft=32768)
    amp_db = 20 * np.log10(np.abs(Zxx) + 1e-10)

    freq_mask = (f >= f_min) & (f <= f_max)
    f_res = f[freq_mask]
    amp_db_res = amp_db[freq_mask, :]

    # ================= 1. 粗提取以寻找“主力扫频军” =================
    raw_freqs = np.zeros(len(t))
    raw_amps = np.zeros(len(t))
    for i in range(len(t)):
        max_idx = np.argmax(amp_db_res[:, i])
        raw_freqs[i] = f_res[max_idx]
        raw_amps[i] = amp_db_res[max_idx, i]

    global_max_amp = np.max(raw_amps)

    # ================= 2. 严苛的数学直线拟合 =================
    # 步骤 A: 只要能量极高的点（最不可能是干扰的点）
    mask_energy = raw_amps > (global_max_amp - 20.0)
    t_high = t[mask_energy]
    f_high = raw_freqs[mask_energy]

    if len(t_high) < 10:
        print(f"⚠️ {os.path.basename(filepath)} 信号极弱，退回原始粗提取")
        sorted_indices = np.argsort(raw_freqs)
        return raw_freqs[sorted_indices], raw_amps[sorted_indices]

    # 步骤 B: 第一次粗拟合
    p1 = np.polyfit(t_high, f_high, 1)
    expected_f1 = np.polyval(p1, t_high)

    # 步骤 C: 第二次极严苛拟合 (只信任偏离粗线不到 100Hz 的点，彻底抛弃飞点)
    inliers = np.abs(f_high - expected_f1) < 100
    t_inliers = t_high[inliers]
    f_inliers = f_high[inliers]

    # 得到 100% 纯净的扫频方程式
    p_robust = np.polyfit(t_inliers, f_inliers, 1)
    expected_f_all = np.polyval(p_robust, t)

    # ================= 3. 极窄带限制拾取 (Strict Tunnel) =================
    final_freqs = []
    final_amps = []
    final_times = []

    # ⭐ 严格限制频率拾取范围：只允许在理论直线的上下 50Hz 内找！
    # 因为信号是严格扫频的，真实响应绝对跑不出这个范围
    search_bandwidth = 50

    for i in range(len(t)):
        expected_f = expected_f_all[i]

        # 如果理论扫频线超出了我们需要分析的范围，直接忽略（切断长尾）
        if expected_f < f_min or expected_f > f_max:
            continue

        search_min = expected_f - search_bandwidth
        search_max = expected_f + search_bandwidth

        idx_min = np.searchsorted(f_res, search_min)
        idx_max = np.searchsorted(f_res, search_max)

        tunnel_amps = amp_db_res[idx_min:idx_max, i]

        if len(tunnel_amps) == 0:
            continue

        local_max_idx = np.argmax(tunnel_amps)
        best_f = f_res[idx_min + local_max_idx]
        best_amp = tunnel_amps[local_max_idx]

        # ⭐ 宁缺毋滥原则：即使在隧道内，如果能量低于极值 50dB（说明那是纯底噪），也不要拾取
        if best_amp > (global_max_amp - 50.0):
            final_freqs.append(best_f)
            final_amps.append(best_amp)
            final_times.append(t[i])

    final_freqs = np.array(final_freqs)
    final_amps = np.array(final_amps)
    final_times = np.array(final_times)

    # ================= 4. 生成诊断图 =================
    if diag_dir is not None and len(final_times) > 0:
        os.makedirs(diag_dir, exist_ok=True)
        basename = os.path.basename(filepath)

        plt.figure(figsize=(10, 4))
        # 灰色：让你看看有多少脏信号被屏蔽了
        plt.scatter(t, raw_freqs, color='gray', s=1, alpha=0.3, label='全局最高点(含干扰)')

        # 蓝色虚线带：严格的拾取范围 (可以直观看到算法设定的“围墙”)
        plt.fill_between(t, expected_f_all - search_bandwidth, expected_f_all + search_bandwidth,
                         color='blue', alpha=0.1, label='极窄带拾取隧道 (±50Hz)')
        plt.plot(t, expected_f_all, color='blue', linestyle='--', linewidth=1, alpha=0.8)

        # 红色：最终选取的干净数据
        plt.plot(final_times, final_freqs, color='#d62728', marker='.', markersize=4, linestyle='-', linewidth=1.5,
                 label='严格过滤后的真实响应')

        plt.ylim(max(0, f_min - 200), f_max + 200)
        plt.title(f"严格窄带限制抗干扰提取 - {basename}", fontsize=12)
        plt.xlabel("时间 (秒)", fontsize=10)
        plt.ylabel("主频 (Hz)", fontsize=10)
        plt.legend()
        plt.grid(True, linestyle='--', alpha=0.6)
        plt.tight_layout()

        plt.savefig(os.path.join(diag_dir, f"Diag_{basename.replace('.wav', '.png')}"), dpi=150)
        plt.close()

    sorted_indices = np.argsort(final_freqs)
    return final_freqs[sorted_indices], final_amps[sorted_indices]


def extract_sweep_response(filepath, f_min, f_max, noise_floor=-80, diag_dir=None):
    """
    自动截取扫频时间段，剔除首尾底噪和突变飞点，提取平滑的频响曲线
    """
    fs, data = wavfile.read(filepath)
    if data.ndim > 1:
        data = data[:, 0]
    if data.dtype == np.int16:
        data = data / 32768.0
    elif data.dtype == np.int32:
        data = data / 2147483648.0

    # ⭐ 优化1：增加 nfft=32768 补零，大幅提高频率分辨率，彻底消除图中的“阶梯状”毛刺
    f, t, Zxx = stft(data, fs=fs, nperseg=8192, noverlap=6144, nfft=32768)
    amp_db = 20 * np.log10(np.abs(Zxx) + 1e-10)

    freq_mask = (f >= f_min) & (f <= f_max)
    f_res = f[freq_mask]
    amp_db_res = amp_db[freq_mask, :]

    # 1. 粗提取每一帧的主频和幅值
    raw_freqs = np.zeros(len(t))
    raw_amps = np.zeros(len(t))
    for i in range(len(t)):
        max_idx = np.argmax(amp_db_res[:, i])
        raw_freqs[i] = f_res[max_idx]
        raw_amps[i] = amp_db_res[max_idx, i]
    # ================= ⭐ 核心：自动识别扫频时间段 =================
    # 规则A：能量达标。将动态及格线放宽到 40dB，甚至 50dB，只要比纯底噪高就行
    energy_threshold = np.max(raw_amps) - 45.0
    energy_mask = raw_amps > energy_threshold

    valid_indices = np.where(energy_mask)[0]

    if len(valid_indices) > 0:
        # 规则B：寻找“最长连续高能量段”（允许中间有长达 100 帧（约几百毫秒）的掉线不断开）
        breaks = np.where(np.diff(valid_indices) > 100)[0] + 1
        segments = np.split(valid_indices, breaks)
        longest_segment = max(segments, key=len)  # 挑出最长的那一段，这就是真实的扫频区间！

        start_idx = longest_segment[0]
        end_idx = longest_segment[-1]

        crop_t = t[start_idx:end_idx + 1]
        crop_freqs = raw_freqs[start_idx:end_idx + 1]
        crop_amps = raw_amps[start_idx:end_idx + 1]
    else:
        # 极小概率防御：如果没有找到符合要求的，退化为原始全量数据
        crop_t, crop_freqs, crop_amps = t, raw_freqs, raw_amps

    # ================= ⭐ 核心：剔除区间内的突变飞点 =================
    # 规则C：线性扫频的主频应该是连续的，突变往往是噪声抢了风头
    # 使用中值滤波找到“趋势线”
    trend_freqs = medfilt(crop_freqs, kernel_size=21)

    # 允许真实频率偏离趋势线上下 50Hz，超过则认为是飞点予以剔除
    clean_mask = np.abs(crop_freqs - trend_freqs) < 50

    final_times = crop_t[clean_mask]
    final_freqs = crop_freqs[clean_mask]
    final_amps = crop_amps[clean_mask]
    # ===============================================================

    # 生成诊断图
    if diag_dir is not None and len(final_times) > 0:
        os.makedirs(diag_dir, exist_ok=True)
        basename = os.path.basename(filepath)

        plt.figure(figsize=(10, 4))
        # 绘制清洗后的最终数据点
        plt.plot(final_times, final_freqs, color='#d62728', marker='.', markersize=4, linestyle='-', linewidth=1.5,
                 label='自动识别有效段')

        # 背景淡淡地画出原始所有数据，方便对比“代码帮你裁掉了什么”
        plt.scatter(t, raw_freqs, color='gray', s=1, alpha=0.3, label='原始粗提取')

        plt.title(f"自动扫频截取诊断 - {basename}", fontsize=12)
        plt.xlabel("时间 (秒)", fontsize=10)
        plt.ylabel("追踪到的主频 (Hz)", fontsize=10)
        plt.legend()
        plt.grid(True, linestyle='--', alpha=0.6)
        plt.tight_layout()

        diag_save_path = os.path.join(diag_dir, f"Diag_{basename.replace('.wav', '.png')}")
        plt.savefig(diag_save_path, dpi=150)
        plt.close()

    # 排序以备后续插值使用
    sorted_indices = np.argsort(final_freqs)
    return final_freqs[sorted_indices], final_amps[sorted_indices]


def get_third_octave_centers(f_min, f_max):
    iso_centers = np.array([
        20, 25, 31.5, 40, 50, 63, 80, 100, 125, 160, 200, 250, 315,
        400, 500, 630, 800, 1000, 1250, 1600, 2000, 2500, 3150, 4000, 5000
    ])
    return iso_centers[(iso_centers >= f_min) & (iso_centers <= f_max)]


def calculate_third_octave_levels(freqs, amp_db, center_freqs):
    band_amps = []
    energy = 10 ** (amp_db / 10.0)
    for fc in center_freqs:
        mask = (freqs >= fc / (2 ** (1 / 6))) & (freqs < fc * (2 ** (1 / 6)))
        band_amps.append(10 * np.log10(np.sum(energy[mask])) if np.any(mask) else -100)
    return np.array(band_amps)


# ================= 2. 定制展示音频生成引擎 (新增核心功能) =================
def generate_pink_noise(num_samples):
    white = np.random.randn(num_samples)
    b = [0.049922035, -0.095993537, 0.050612699, -0.004408786]
    a = [1, -2.494956002, 2.017265875, -0.522189400]
    pink = lfilter(b, a, white)
    return pink / np.max(np.abs(pink))


def get_a_weighting_gains(freqs):
    f_sq = freqs ** 2
    R_A = (12194 ** 2 * f_sq ** 2) / \
          ((f_sq + 20.6 ** 2) * np.sqrt((f_sq + 107.7 ** 2) * (f_sq + 737.9 ** 2)) * (f_sq + 12194 ** 2))
    return 20 * np.log10(R_A + 1e-10) + 2.00


def export_demo_audio_suite(struct_name, center_freqs, extra_il_db, output_dir, fs=44100):
    """
    为特定结构生成【现场展示用】和【耳机预览用】双套音频 (外科手术级靶向优化)
    """
    os.makedirs(output_dir, exist_ok=True)

    duration_source = Config.wav_duration
    num_samples_source = int(duration_source * fs)
    pink_noise = generate_pink_noise(num_samples_source)

    # ⭐ 修复点：保留 positive_il 的定义，供后续产物2使用
    positive_il = np.clip(extra_il_db, 0, None)

    # ================= 1. 核心算法：定制靶向源噪声 =================
    # 【目标声学塑造 - 外科手术级优化】：严格的扬长避短！
    a_weights_db = get_a_weighting_gains(center_freqs)
    target_gain_db = np.zeros_like(extra_il_db)

    # 设定动态门限：只挑选该结构降噪能力最强的那一小撮频段
    peak_il = np.max(extra_il_db)
    threshold_il = max(3.0, peak_il * 0.3)  # 至少要有 3dB 的降噪量，或者达到峰值的 30%

    for i in range(len(extra_il_db)):
        if extra_il_db[i] >= threshold_il:
            # 核心优势频段：疯狂放大 (自身降噪量加权 + A计权)
            target_gain_db[i] = extra_il_db[i] * 2.0 + a_weights_db[i]
        else:
            # 劣势/负降噪频段：彻底抹杀！将其增益拉低到 -80dB
            target_gain_db[i] = -80.0

    target_gain_db = target_gain_db - np.max(target_gain_db) + 6.0

    nyq = fs / 2.0
    freqs_ext = np.concatenate(([0.0], center_freqs, [nyq]))
    gain_ext = np.concatenate(([-40.0], target_gain_db, [-40.0]))
    freqs_ext = np.clip(freqs_ext, 0, nyq)

    mag_target = 10 ** (gain_ext / 20.0)
    fir_target = firwin2(2049, freqs_ext, mag_target, fs=fs)

    # 【文件1：现场播放用源噪声】
    source_noise = lfilter(fir_target, 1.0, pink_noise)
    source_noise = np.roll(source_noise, -1024)
    source_audio_int16 = np.int16((source_noise / np.max(np.abs(source_noise))) * 32767)
    source_save_path = os.path.join(output_dir, f"[现场播放用]-{struct_name}-专属靶向噪声.wav")
    wavfile.write(source_save_path, fs, source_audio_int16)

    # ================= 2. 模拟实际降噪效果 =================
    # 产物2：耳机预览用 A/B 切换音频 (这里现在不会报错了)
    reduction_gain_db = -positive_il
    reduction_gain_ext = np.concatenate(([0.0], reduction_gain_db, [0.0]))
    mag_reduction = 10 ** (reduction_gain_ext / 20.0)
    fir_reduction = firwin2(2049, freqs_ext, mag_reduction, fs=fs)

    reduced_noise = lfilter(fir_reduction, 1.0, source_noise)
    reduced_noise = np.roll(reduced_noise, -1024)

    # ================= 3. 制作 A/B 切换预览音频 =================
    duration_ab = 8.0
    num_samples_ab = int(duration_ab * fs)
    segment_samples = int(2.0 * fs)
    demo_audio = np.zeros(num_samples_ab)

    for i in range(0, num_samples_ab, segment_samples):
        end = min(i + segment_samples, num_samples_ab)
        if (i // segment_samples) % 2 == 0:
            demo_audio[i:end] = source_noise[i:end]
        else:
            demo_audio[i:end] = reduced_noise[i:end]

    demo_audio = demo_audio / np.max(np.abs(source_noise[:num_samples_ab]))
    demo_audio_int16 = np.int16(demo_audio * 32767)
    ab_save_path = os.path.join(output_dir, f"[耳机预览用]-{struct_name}-AB切换模拟.wav")
    wavfile.write(ab_save_path, fs, demo_audio_int16)
    print(f"    🎵 成功导出定制音频套件: {struct_name}")


def generate_all_audio_demos(location_name, struct_data_dict, freqs, f_min, f_max, existing_refs, output_dir):
    """自动处理所有结构的多数据点融合，并批量生成展示音频"""
    if not existing_refs:
        return
    # 默认选取第一个找到的参考结构作为基准（通常是"纯挡风结构"）
    ref_name = existing_refs[0]
    print(f"\n" + "=" * 20 + f" [{location_name}] 开始生成定制展示音频 (基准: {ref_name}) " + "=" * 20)

    center_freqs = get_third_octave_centers(f_min, f_max)
    audio_output_dir = os.path.join(output_dir, f"{location_name}_现场展示音频库")

    # 【多数据点最优融合】：取所有 Trial 的均值来代表该结构的最稳定性能期望值
    mean_amps = {lbl: np.mean(np.array(amps), axis=0) for lbl, amps in struct_data_dict.items()}
    third_oct_dict = {lbl: calculate_third_octave_levels(freqs, amp, center_freqs) for lbl, amp in mean_amps.items()}

    if ref_name not in third_oct_dict:
        return
    ref_avg = third_oct_dict[ref_name]

    for label, band_amps in third_oct_dict.items():
        if label in existing_refs:
            continue  # 不为基准结构自己生成音频
        extra_il_band = ref_avg - band_amps
        export_demo_audio_suite(label, center_freqs, extra_il_band, audio_output_dir)


# ================= 3. 图表与数据分析引擎 =================
def get_dynamic_subplots(num_plots):
    fig, axes = plt.subplots(num_plots, 1, figsize=(12, 4.5 * num_plots))
    if num_plots == 1:
        axes = [axes]
    return fig, axes


def plot_location_data(location_name, struct_data_dict, freqs, existing_refs, output_dir):
    num_plots = 1 + len(existing_refs)
    fig, axes = get_dynamic_subplots(num_plots)
    cmap = plt.get_cmap('tab10')
    colors = {label: cmap(i) for i, label in enumerate(struct_data_dict.keys())}

    ax_abs = axes[0]
    for label, amps in struct_data_dict.items():
        amp_array = np.array(amps)
        amp_mean = np.mean(amp_array, axis=0)
        ax_abs.plot(freqs, amp_mean, color=colors[label], linewidth=2, label=label)
        if amp_array.shape[0] > 1:
            ax_abs.fill_between(freqs, np.min(amp_array, axis=0), np.max(amp_array, axis=0), color=colors[label],
                                alpha=0.2, edgecolor='none')

    ax_abs.set_title(f"[{location_name}] 频响绝对幅值 (实线为均值，阴影为包络)", fontsize=14)
    ax_abs.set_xlabel("频率 (Hz)", fontsize=12)
    ax_abs.set_ylabel("幅值 (dB)", fontsize=12)
    ax_abs.grid(True, which="both", ls="--", alpha=0.6)
    ax_abs.legend(bbox_to_anchor=(1.02, 1), loc='upper left', borderaxespad=0.)

    for i, ref_name in enumerate(existing_refs):
        ax_il = axes[i + 1]
        ref_avg = np.mean(struct_data_dict[ref_name], axis=0)
        for label, amps in struct_data_dict.items():
            if label in existing_refs[:i + 1]:
                continue
            amp_array = np.array(amps)
            ax_il.plot(freqs, ref_avg - np.mean(amp_array, axis=0), color=colors[label], linewidth=2,
                       label=f"{label} 相对降噪")
            if amp_array.shape[0] > 1:
                ax_il.fill_between(freqs, ref_avg - np.max(amp_array, axis=0), ref_avg - np.min(amp_array, axis=0),
                                   color=colors[label], alpha=0.2)
        ax_il.axhline(0, color='black', ls='-', lw=1, alpha=0.5)
        ax_il.set_title(f"[{location_name}] 相对【{ref_name}】的降噪量", fontsize=14)
        ax_il.set_xlabel("频率 (Hz)", fontsize=12)
        ax_il.set_ylabel("相对降噪量 (dB)", fontsize=12)
        ax_il.grid(True, which="both", ls="--", alpha=0.6)
        ax_il.legend(bbox_to_anchor=(1.02, 1), loc='upper left', borderaxespad=0.)

    plt.tight_layout(rect=[0, 0, 0.82, 1])
    save_path = os.path.join(output_dir, f"{location_name}-窄带包络线分析.png")
    plt.savefig(save_path, dpi=300)
    plt.close()


def plot_third_octave_data(location_name, struct_data_dict, freqs, f_min, f_max, existing_refs, output_dir):
    num_plots = 1 + len(existing_refs)
    fig, axes = get_dynamic_subplots(num_plots)
    center_freqs = get_third_octave_centers(f_min, f_max)
    third_oct_dict = {lbl: calculate_third_octave_levels(freqs, np.mean(np.array(amps), axis=0), center_freqs) for
                      lbl, amps in struct_data_dict.items()}
    cmap = plt.get_cmap('tab10')
    colors = {label: cmap(i) for i, label in enumerate(struct_data_dict.keys())}

    ax_abs = axes[0]
    for label, band_amps in third_oct_dict.items():
        ax_abs.plot(center_freqs, band_amps, color=colors[label], lw=2, marker='o', ms=4, drawstyle='steps-mid',
                    label=label)
    ax_abs.set_title(f"[{location_name}] 1/3倍频程 绝对频带声压级", fontsize=14)
    ax_abs.set_ylabel("频带能量 (dB)", fontsize=12)

    for i, ref_name in enumerate(existing_refs):
        ax_il = axes[i + 1]
        ref_avg = third_oct_dict[ref_name]
        for label, band_amps in third_oct_dict.items():
            if label in existing_refs[:i + 1]:
                continue
            ax_il.plot(center_freqs, ref_avg - band_amps, color=colors[label], lw=2, marker='o', ms=4,
                       drawstyle='steps-mid', label=f"{label} 相对降噪")
        ax_il.axhline(0, color='black', ls='-', lw=1, alpha=0.5)
        ax_il.set_title(f"[{location_name}] 1/3倍频程 相对【{ref_name}】的降噪量", fontsize=14)
        ax_il.set_ylabel("相对降噪量 (dB)", fontsize=12)

    for ax in axes:
        ax.set_xscale('log')
        ax.set_xticks(center_freqs)
        ax.get_xaxis().set_major_formatter(matplotlib.ticker.ScalarFormatter())
        ax.tick_params(axis='x', rotation=45)
        ax.set_xlabel("1/3 倍频程中心频率 (Hz)", fontsize=12)
        ax.grid(True, which="major", ls="-", alpha=0.6)
        ax.grid(True, which="minor", ls="--", alpha=0.2)
        ax.legend(bbox_to_anchor=(1.02, 1), loc='upper left', borderaxespad=0.)

    plt.tight_layout(rect=[0, 0, 0.82, 1])
    save_path = os.path.join(output_dir, f"{location_name}-三分之一倍频程阶梯图.png")
    plt.savefig(save_path, dpi=300)
    plt.close()


def extract_multi_peaks_analysis(location_name, struct_data_dict, freqs, existing_refs, output_dir, prominence=1.5,
                                 distance=30):
    mean_amps = {label: np.mean(np.array(amps), axis=0) for label, amps in struct_data_dict.items()}

    def process_peaks(data_dict, ref_name):
        all_peaks, best_in_class = [], []
        for tgt_struct, tgt_array in data_dict.items():
            peaks_idx, _ = find_peaks(tgt_array, prominence=prominence, distance=distance)
            for idx in peaks_idx:
                val = tgt_array[idx]
                row = {"分析结构": tgt_struct, "极值频率 (Hz)": round(freqs[idx], 1),
                       f"相对{ref_name}降噪 (dB)": round(val, 2)}
                is_best, comp_vals = True, []
                for oth_struct, oth_array in data_dict.items():
                    if oth_struct != tgt_struct:
                        oth_val = oth_array[idx]
                        row[f"对比: {oth_struct} (dB)"] = round(oth_val, 2)
                        comp_vals.append(oth_val)
                        if oth_val >= val:
                            is_best = False
                row["是否为全场最优?"] = "⭐ 是" if is_best else "否"
                all_peaks.append(row)

                if is_best:
                    adv = val - max(comp_vals) if comp_vals else 0
                    best_in_class.append({"最优结构": tgt_struct, "统治频率 (Hz)": round(freqs[idx], 1),
                                          f"相对{ref_name}降噪 (dB)": round(val, 2),
                                          "领先第二名优势 (dB)": round(adv, 2)})

        df_all, df_best = pd.DataFrame(all_peaks), pd.DataFrame(best_in_class)
        if not df_all.empty and "是否为全场最优?" in df_all.columns:
            cols = list(df_all.columns)
            cols.remove("是否为全场最优?")
            cols.append("是否为全场最优?")
            df_all = df_all[cols]
        return df_all, df_best

    print(f"\n" + "=" * 20 + f" [{location_name}] 极值点分析 " + "=" * 20)
    for ref_name in existing_refs:
        if ref_name in mean_amps:
            ref_avg = mean_amps[ref_name]
            relative_dict = {lbl: ref_avg - amp for lbl, amp in mean_amps.items() if lbl != ref_name}
            df_all, df_best = process_peaks(relative_dict, ref_name)

            all_csv_path = os.path.join(output_dir, f"{location_name}-相对[{ref_name}]-全部极值点.csv")
            best_csv_path = os.path.join(output_dir, f"{location_name}-相对[{ref_name}]-最优频率.csv")

            df_all.to_csv(all_csv_path, index=False, encoding='utf-8-sig')
            df_best.to_csv(best_csv_path, index=False, encoding='utf-8-sig')
            print(f"✅ 成功提取相对【{ref_name}】的最优频率特征，CSV已保存。")


def extract_third_octave_analysis(location_name, struct_data_dict, freqs, f_min, f_max, existing_refs, output_dir):
    """
    提取 1/3 倍频程降噪性能统计表，并自动标记每个频段的最优降噪结构
    """
    # 1. 计算 1/3 倍频程中心频率和各个结构的频带能量
    center_freqs = get_third_octave_centers(f_min, f_max)
    mean_amps = {lbl: np.mean(np.array(amps), axis=0) for lbl, amps in struct_data_dict.items()}
    third_oct_dict = {lbl: calculate_third_octave_levels(freqs, amp, center_freqs) for lbl, amp in mean_amps.items()}

    print(f"\n" + "=" * 20 + f" [{location_name}] 1/3倍频程性能分析 " + "=" * 20)

    for ref_name in existing_refs:
        if ref_name not in third_oct_dict:
            continue

        ref_bands = third_oct_dict[ref_name]
        tgt_structs = [s for s in third_oct_dict.keys() if s != ref_name]

        if not tgt_structs:
            continue

        rows = []
        for i, fc in enumerate(center_freqs):
            row = {"中心频率 (Hz)": round(fc, 1)}

            best_struct = "无"
            best_il = -999.9

            # 计算每个结构的降噪量
            for tgt in tgt_structs:
                tgt_bands = third_oct_dict[tgt]
                # 降噪量 = 参考结构的频带能量 - 目标结构的频带能量
                il = ref_bands[i] - tgt_bands[i]
                row[f"{tgt} 降噪量 (dB)"] = round(il, 2)

                # 寻找当前频段的最优结构
                if il > best_il:
                    best_il = il
                    best_struct = tgt

            # 标记最优结果
            if best_il > 0:
                row["⭐ 冠军结构"] = best_struct
                row["🏆 最大降噪量 (dB)"] = round(best_il, 2)
            else:
                row["⭐ 冠军结构"] = "无正向降噪"
                row["🏆 最大降噪量 (dB)"] = "-"

            rows.append(row)

        # 保存为 CSV
        df = pd.DataFrame(rows)
        csv_path = os.path.join(output_dir, f"{location_name}-相对[{ref_name}]-三分之一倍频程降噪统计.csv")
        df.to_csv(csv_path, index=False, encoding='utf-8-sig')
        print(f"✅ 成功提取相对【{ref_name}】的1/3倍频程降噪统计表，CSV已保存。")


# ====================================================
# 外部调用的总控接口
# ====================================================
def run_analysis_pipeline(struct_file_dict, output_dir, is_steady_noise, ref_list, f_min=200, f_max=4500,
                          loc_name="默认测点"):
    print(f"✅ 使用频率范围: {f_min}Hz - {f_max}Hz")
    common_freqs = np.linspace(f_min, f_max, 1000)
    struct_data_dict = {}

    for struct, struct_files in struct_file_dict.items():
        print(f" -> 提取 [{struct}] 的 {len(struct_files)} 组数据特征...")
        struct_data_dict[struct] = []
        for file in struct_files:
            try:
                if is_steady_noise:
                    f_raw, amp_raw = extract_steady_response(file, f_min, f_max)
                else:
                    diag_folder = os.path.join(output_dir, f"{loc_name}_扫频诊断图")
                    f_raw, amp_raw = extract_sweep_response_strict(file, f_min, f_max, diag_dir=diag_folder)

                amp_interp = np.interp(common_freqs, f_raw, amp_raw)
                amp_smoothed = savgol_filter(amp_interp, window_length=51, polyorder=3)
                struct_data_dict[struct].append(amp_smoothed)
            except Exception as e:
                print(f"    ❌ 失败: {os.path.basename(file)} | {e}")

    if struct_data_dict:
        existing_refs = [ref for ref in ref_list if ref in struct_data_dict]
        if not existing_refs:
            print("⚠️ 警告：当前实验未找到配置列表中的任何参考结构，部分图表将无法生成。")

        # 绘图与分析
        plot_location_data(loc_name, struct_data_dict, common_freqs, existing_refs, output_dir)
        plot_third_octave_data(loc_name, struct_data_dict, common_freqs, f_min, f_max, existing_refs, output_dir)
        extract_multi_peaks_analysis(loc_name, struct_data_dict, common_freqs, existing_refs, output_dir)
        extract_third_octave_analysis(loc_name, struct_data_dict, common_freqs, f_min, f_max, existing_refs, output_dir)

        # 生成定制音频
        if Config.GENERATE_AUDIO_DEMOS:
            generate_all_audio_demos(loc_name, struct_data_dict, common_freqs, f_min, f_max, existing_refs, output_dir)


if __name__ == "__main__":
    # ==================== 统一配置区 ====================
    excel_path = Config.EXCEL_PATH
    sheet_name = Config.SHEET_NAME
    data_dir = Config.OUTPUT_DIR

    is_steady_noise = Config.IS_STEADY_NOISE

    ref_list = Config.ref_list

    run_analysis_pipeline(excel_path, sheet_name, data_dir, is_steady_noise, ref_list)
