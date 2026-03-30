#! /usr/bin/env python
# -*- coding: utf-8 -*-
"""
简化版主动降噪频响对比分析
输入：直接指定WAV文件路径，自动分析对比
"""

import numpy as np
import matplotlib
import matplotlib.pyplot as plt
from scipy.io import wavfile
from scipy.signal import stft, savgol_filter, find_peaks
import pandas as pd
import warnings
warnings.filterwarnings('ignore')

matplotlib.rcParams['font.sans-serif'] = ['PingFang SC', 'Heiti SC', 'STHeiti', 'SimHei', 'DejaVu Sans']
matplotlib.rcParams['axes.unicode_minus'] = False

matplotlib.use('Qt5Agg' if matplotlib.get_backend() == 'Qt5Agg' else 'TkAgg')

# ================= 核心算法函数 =================
def extract_steady_response(filepath, f_min, f_max):
    """提取稳态噪声频响"""
    fs, data = wavfile.read(filepath)
    if data.ndim > 1: 
        data = data[:, 0]  # 取左声道
    if data.dtype == np.int16:
        data = data / 32768.0
    elif data.dtype == np.int32:
        data = data / 2147483648.0

    f, t, Zxx = stft(data, fs=fs, nperseg=8192, noverlap=4096)
    amp_linear = np.abs(Zxx)
    amp_rms = np.sqrt(np.mean(amp_linear ** 2, axis=1))
    amp_db = 20 * np.log10(amp_rms + 1e-10)
    
    freq_mask = (f >= f_min) & (f <= f_max)
    return f[freq_mask], amp_db[freq_mask]

def extract_sweep_response(filepath, f_min, f_max, noise_floor=-80):
    """提取扫频信号频响"""
    fs, data = wavfile.read(filepath)
    if data.ndim > 1: 
        data = data[:, 0]
    if data.dtype == np.int16:
        data = data / 32768.0
    elif data.dtype == np.int32:
        data = data / 2147483648.0

    f, t, Zxx = stft(data, fs=fs, nperseg=8192, noverlap=4096)
    amp_db = 20 * np.log10(np.abs(Zxx) + 1e-10)
    
    freq_mask = (f >= f_min) & (f <= f_max)
    f_res, amp_db_res = f[freq_mask], amp_db[freq_mask, :]
    
    extracted_freqs, extracted_amps = [], []
    for i in range(len(t)):
        frame_amp = amp_db_res[:, i]
        max_idx = np.argmax(frame_amp)
        if frame_amp[max_idx] > noise_floor:
            extracted_freqs.append(f_res[max_idx])
            extracted_amps.append(frame_amp[max_idx])
    
    extracted_freqs, extracted_amps = np.array(extracted_freqs), np.array(extracted_amps)
    sorted_indices = np.argsort(extracted_freqs)
    return extracted_freqs[sorted_indices], extracted_amps[sorted_indices]

def get_third_octave_centers(f_min, f_max):
    """获取ISO标准1/3倍频程中心频率"""
    iso_centers = np.array([
        20, 25, 31.5, 40, 50, 63, 80, 100, 125, 160, 200, 250, 315,
        400, 500, 630, 800, 1000, 1250, 1600, 2000, 2500, 3150, 4000, 5000
    ])
    return iso_centers[(iso_centers >= f_min) & (iso_centers <= f_max)]

def calculate_third_octave_levels(freqs, amp_db, center_freqs):
    """计算1/3倍频程声压级"""
    band_amps = []
    energy = 10 ** (amp_db / 10.0)
    for fc in center_freqs:
        lower = fc / (2 ** (1/6))
        upper = fc * (2 ** (1/6))
        mask = (freqs >= lower) & (freqs < upper)
        if np.any(mask):
            band_energy = np.sum(energy[mask])
            band_amps.append(10 * np.log10(band_energy) if band_energy > 0 else -100)
        else:
            band_amps.append(-100)
    return np.array(band_amps)

# ================= 可视化函数 =================
def plot_comparison_results(filenames, labels, f_min=200, f_max=2500, is_steady=False, 
                           reference_idx=0, output_prefix="频响对比分析"):
    """
    主分析函数
    
    参数:
    ----------
    filenames : list
        WAV文件路径列表
    labels : list
        对应的标签/结构名称列表
    f_min/f_max : int
        分析频率范围(Hz)
    is_steady : bool
        True=稳态噪声, False=扫频信号
    reference_idx : int
        作为基准的参考结构索引(默认为第一个)
    output_prefix : str
        输出文件前缀
    """
    
    print("="*60)
    print("频响对比分析系统")
    print(f"分析频率范围: {f_min}-{f_max} Hz")
    print(f"分析模式: {'稳态噪声' if is_steady else '扫频信号'}")
    print(f"参考基准: {labels[reference_idx]} (索引{reference_idx})")
    print("="*60)
    
    # 1. 提取所有文件数据
    all_data = {}
    common_freqs = np.linspace(f_min, f_max, 1000)
    
    for i, (filename, label) in enumerate(zip(filenames, labels)):
        print(f"\n📁 处理文件 {i+1}/{len(filenames)}: {label}")
        print(f"   文件: {filename}")
        
        try:
            if is_steady:
                f_raw, amp_raw = extract_steady_response(filename, f_min, f_max)
            else:
                f_raw, amp_raw = extract_sweep_response(filename, f_min, f_max)
            
            # 插值到统一频率轴
            amp_interp = np.interp(common_freqs, f_raw, amp_raw, left=-100, right=-100)
            # 平滑处理
            window_len = min(51, len(amp_interp)//2 * 2+1)  # 确保为奇数
            if window_len > 3:
                amp_smoothed = savgol_filter(amp_interp, window_length=window_len, polyorder=3)
            else:
                amp_smoothed = amp_interp
                
            all_data[label] = amp_smoothed
            print(f"   ✅ 成功提取，频点数量: {len(amp_smoothed)}")
            
        except Exception as e:
            print(f"   ❌ 处理失败: {e}")
            all_data[label] = None
    
    # 检查数据有效性
    valid_labels = [label for label, data in all_data.items() if data is not None]
    if len(valid_labels) < 2:
        print("\n❌ 错误: 需要至少2个有效文件进行对比!")
        return
    
    # 2. 创建对比图表
    fig, axes = plt.subplots(3, 1, figsize=(14, 12))
    cmap = plt.get_cmap('tab10')
    
    # --- 子图1: 绝对频响对比 ---
    ax1 = axes[0]
    for i, label in enumerate(valid_labels):
        color = cmap(i % 10)
        ax1.plot(common_freqs, all_data[label], color=color, linewidth=2, label=label)
    
    ax1.set_title(f"绝对频响对比 ({'稳态' if is_steady else '扫频'})", fontsize=14, fontweight='bold')
    ax1.set_xlabel("频率 (Hz)", fontsize=12)
    ax1.set_ylabel("幅值 (dB)", fontsize=12)
    ax1.grid(True, which="both", ls="--", alpha=0.6)
    ax1.legend(loc='upper right')
    
    # --- 子图2: 相对降噪量 ---
    ax2 = axes[1]
    if valid_labels[reference_idx] in all_data and all_data[valid_labels[reference_idx]] is not None:
        ref_data = all_data[valid_labels[reference_idx]]
        
        for i, label in enumerate(valid_labels):
            if i == reference_idx:
                continue
            color = cmap(i % 10)
            relative_diff = ref_data - all_data[label]
            ax2.plot(common_freqs, relative_diff, color=color, linewidth=2, 
                    label=f"{label} 相对 {valid_labels[reference_idx]}")
        
        ax2.axhline(y=0, color='gray', linestyle='--', linewidth=1, alpha=0.7)
        ax2.fill_between(common_freqs, 0, relative_diff.max(), alpha=0.1, color='green')
        ax2.fill_between(common_freqs, relative_diff.min(), 0, alpha=0.1, color='red')
    
    ax2.set_title(f"相对降噪量 (基准: {valid_labels[reference_idx]})", fontsize=14, fontweight='bold')
    ax2.set_xlabel("频率 (Hz)", fontsize=12)
    ax2.set_ylabel("降噪量 (dB)", fontsize=12)
    ax2.grid(True, which="both", ls="--", alpha=0.6)
    ax2.legend(loc='upper right')
    
    # --- 子图3: 1/3倍频程分析 ---
    ax3 = axes[2]
    center_freqs = get_third_octave_centers(f_min, f_max)
    
    for i, label in enumerate(valid_labels):
        if all_data[label] is not None:
            color = cmap(i % 10)
            third_oct = calculate_third_octave_levels(common_freqs, all_data[label], center_freqs)
            ax3.plot(center_freqs, third_oct, color=color, linewidth=2, marker='o', 
                    markersize=6, label=label, drawstyle='steps-mid')
    
    ax3.set_title("1/3倍频程声压级", fontsize=14, fontweight='bold')
    ax3.set_xlabel("中心频率 (Hz)", fontsize=12)
    ax3.set_ylabel("声压级 (dB)", fontsize=12)
    ax3.set_xscale('log')
    ax3.set_xticks(center_freqs)
    ax3.get_xaxis().set_major_formatter(matplotlib.ticker.ScalarFormatter())
    ax3.tick_params(axis='x', rotation=45)
    ax3.grid(True, which="both", ls="--", alpha=0.6)
    ax3.legend(loc='upper right')
    
    plt.tight_layout()
    
    # 保存图片
    output_image = f"{output_prefix}.png"
    # plt.savefig(output_image, dpi=300, bbox_inches='tight')
    print(f"\n✅ 对比图表已保存: {output_image}")
    plt.show()
    
    # 3. 极值点分析
    print("\n📊 极值点分析:")
    print("-"*50)
    
    if valid_labels[reference_idx] in all_data and all_data[valid_labels[reference_idx]] is not None:
        ref_data = all_data[valid_labels[reference_idx]]
        results = []
        
        for i, label in enumerate(valid_labels):
            if i == reference_idx:
                continue
                
            data = all_data[label]
            relative_data = ref_data - data
            
            # 寻找峰值（降噪明显的频率点）
            peaks_idx, properties = find_peaks(relative_data, prominence=3, distance=30)
            
            for idx in peaks_idx[:5]:  # 只显示前5个最明显的峰值
                freq = common_freqs[idx]
                gain = relative_data[idx]
                results.append({
                    '结构': label,
                    '优势频率(Hz)': round(freq, 1),
                    '降噪量(dB)': round(gain, 2),
                    '相对基准': valid_labels[reference_idx]
                })
                print(f"  {label}: 在 {freq:.1f} Hz 处降噪 {gain:.1f} dB")
    

# ================= 使用示例 =================
if __name__ == "__main__":
    # ================ 配置区 ================
    # 1. 输入WAV文件列表（完整路径）
    WAV_FILES = [
        # r"/Volumes/Jokker/Code/Scad_for_stl/z_声学超结构/data/2026-03-30/测点3-结构角点-4块吸音板.wav",     
        # r"/Volumes/Jokker/Code/Scad_for_stl/z_声学超结构/data/2026-03-30/测点3-结构角点-4块吸音板反面.wav",     
        # r"/Volumes/Jokker/Code/Scad_for_stl/z_声学超结构/data/2026-03-30/测点3-结构角点-结构+布+1块.wav",     
        # r"/Volumes/Jokker/Code/Scad_for_stl/z_声学超结构/data/2026-03-30/测点3-结构角点-结构+布+2块.wav",      
        # r"/Volumes/Jokker/Code/Scad_for_stl/z_声学超结构/data/2026-03-30/测点3-结构角点-结构+1块.wav",      
        r"/Volumes/Jokker/Code/Scad_for_stl/z_声学超结构/data/2026-03-30/测点3-结构角点-结构+2块.wav",      
        # r"/Volumes/Jokker/Code/Scad_for_stl/z_声学超结构/data/2026-03-30/测点3-结构角点-结构胶布堵孔+1块.wav",      
        r"/Volumes/Jokker/Code/Scad_for_stl/z_声学超结构/data/2026-03-30/测点3-结构角点-结构胶布堵孔+2块.wav",      
        # r"/Volumes/Jokker/Code/Scad_for_stl/z_声学超结构/data/2026-03-30/测点3-结构角点-无结构.wav",      
    ]
    
    # WAV_FILES = [
    #     # r"/Volumes/Jokker/Code/Scad_for_stl/z_声学超结构/data/2026-03-30/测点2-面中心-4块吸音板.wav",     
    #     # r"/Volumes/Jokker/Code/Scad_for_stl/z_声学超结构/data/2026-03-30/测点2-面中心-4块吸音板反面.wav",     
    #     # r"/Volumes/Jokker/Code/Scad_for_stl/z_声学超结构/data/2026-03-30/测点2-面中心-结构+布+1块.wav",     
    #     # r"/Volumes/Jokker/Code/Scad_for_stl/z_声学超结构/data/2026-03-30/测点2-面中心-结构+布+2块.wav",      
    #     # r"/Volumes/Jokker/Code/Scad_for_stl/z_声学超结构/data/2026-03-30/测点2-面中心-结构+1块.wav",      
    #     r"/Volumes/Jokker/Code/Scad_for_stl/z_声学超结构/data/2026-03-30/测点2-面中心-结构+2块.wav",      
    #     # r"/Volumes/Jokker/Code/Scad_for_stl/z_声学超结构/data/2026-03-30/测点2-面中心-结构胶布堵孔+1块.wav",      
    #     r"/Volumes/Jokker/Code/Scad_for_stl/z_声学超结构/data/2026-03-30/测点2-面中心-结构胶布堵孔+2块.wav",      
    #     # r"/Volumes/Jokker/Code/Scad_for_stl/z_声学超结构/data/2026-03-30/测点2-面中心-无结构.wav",      
    # ]
    
    # WAV_FILES = [
    #     # r"/Volumes/Jokker/Code/Scad_for_stl/z_声学超结构/data/2026-03-30/测点1-中心-4块吸音板.wav",     
    #     # r"/Volumes/Jokker/Code/Scad_for_stl/z_声学超结构/data/2026-03-30/测点1-中心-4块吸音板反面.wav",     
    #     # r"/Volumes/Jokker/Code/Scad_for_stl/z_声学超结构/data/2026-03-30/测点1-中心-结构+布+1块.wav",     
    #     # r"/Volumes/Jokker/Code/Scad_for_stl/z_声学超结构/data/2026-03-30/测点1-中心-结构+布+2块.wav",      
    #     # r"/Volumes/Jokker/Code/Scad_for_stl/z_声学超结构/data/2026-03-30/测点1-中心-结构+1块.wav",      
    #     r"/Volumes/Jokker/Code/Scad_for_stl/z_声学超结构/data/2026-03-30/测点1-中心-结构+2块.wav",      
    #     # r"/Volumes/Jokker/Code/Scad_for_stl/z_声学超结构/data/2026-03-30/测点1-中心-结构胶布堵孔+1块.wav",      
    #     r"/Volumes/Jokker/Code/Scad_for_stl/z_声学超结构/data/2026-03-30/测点1-中心-结构胶布堵孔+2块.wav",      
    #     # r"/Volumes/Jokker/Code/Scad_for_stl/z_声学超结构/data/2026-03-30/测点1-中心-无结构.wav",      
    # ]
    
    # 2. 对应的标签/结构名称
    LABELS = [  
        # "4块吸音板",
        # "4块吸音板反面",
        # "结构+布+1块",
        # "结构+布+2块",  
        # "结构+1块",  
        "结构+2块",  
        # "结构胶布堵孔+1块",  
        "结构胶布堵孔+2块",  
        # "无结构",  
    ]
    
    # 3. 分析参数
    FREQ_MIN = 200      # 分析最低频率(Hz)
    FREQ_MAX = 14500     # 分析最高频率(Hz)
    IS_STEADY = True   # True=稳态噪声, False=扫频信号
    REF_IDX = 1         # 参考结构索引（0表示第一个文件作为基准）
    OUTPUT_PREFIX = "/Volumes/Jokker/Code/Scad_for_stl/z_声学超结构/data/res"  # 输出文件名前缀
    
    # ================ 执行分析 ================
    plot_comparison_results(
        filenames=WAV_FILES,
        labels=LABELS,
        f_min=FREQ_MIN,
        f_max=FREQ_MAX,
        is_steady=IS_STEADY,
        reference_idx=REF_IDX,
        output_prefix=OUTPUT_PREFIX
    )