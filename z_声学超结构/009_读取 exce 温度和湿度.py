import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import os
import re

# ================= Matplotlib 中文显示设置 =================
# 适用于 macOS，优先尝试常见中文字体
plt.rcParams['font.sans-serif'] = [
    'Arial Unicode MS',
    'PingFang SC',
    'Heiti SC',
    'STHeiti',
    'SimHei',
    'Noto Sans CJK SC'
]
plt.rcParams['axes.unicode_minus'] = False  # 解决负号显示问题

# ================= 参数 =================

file_paths = [
    # "/Volumes/Jokker/Code/Scad_for_stl/z_声学超结构/data/温湿度数据/0421-19-10/C0028001802D-SN号C0028001802D-历史记录-2026年04月21日19时01分.xlsx",
    # "/Volumes/Jokker/Code/Scad_for_stl/z_声学超结构/data/温湿度数据/0421-19-10/C00280018035-SN号C00280018035-历史记录-2026年04月21日19时01分.xlsx"
    "/Volumes/Jokker/Code/Scad_for_stl/z_声学超结构/data/温湿度数据/0422-13-40/C0028001802D-SN号C0028001802D-历史记录-2026年04月22日13时54分.xlsx",
    "/Volumes/Jokker/Code/Scad_for_stl/z_声学超结构/data/温湿度数据/0422-13-40/C00280018035-SN号C00280018035-历史记录-2026年04月22日13时53分.xlsx"
]

labels = ["Sensor A", "Sensor B"]

# 时间段列表：开始时间、结束时间、图片标题
time_ranges = [
    # ("2026-04-21 10:56:00", "2026-04-21 11:16:59", "主动排湿 5V"),
    # ("2026-04-21 11:22:00", "2026-04-21 11:42:59", "被动排湿 0V"),
    # ("2026-04-21 11:46:00", "2026-04-21 12:06:59", "被动排湿 0V"),
    # ("2026-04-21 13:43:00", "2026-04-21 14:03:59", "主动排湿 12V"),
    # ("2026-04-21 14:32:00", "2026-04-21 14:52:59", "被动排湿-拆除撸猫口"),
    # ("2026-04-21 14:59:00", "2026-04-21 15:19:59", "被动排湿-拆除撸猫口"),
    # ("2026-04-21 15:24:00", "2026-04-21 15:44:59", "主动排湿 12V"),
    # ("2026-04-21 15:52:00", "2026-04-21 16:12:59", "常规-撸猫口"),
    # ("2026-04-21 16:15:00", "2026-04-21 16:35:59", "常规-撸猫口"),
    # ("2026-04-21 16:55:00", "2026-04-21 17:15:59", "常规-撸猫口 35℃"),
    # ("2026-04-21 18:37:00", "2026-04-21 18:57:59", "常规-撸猫口"),
    
    ("2026-04-22 09:30:00", "2026-04-22 09:50:59", "-"),
    ("2026-04-22 09:56:00", "2026-04-22 10:16:59", "-"),
    ("2026-04-22 10:29:00", "2026-04-22 10:49:59", "-"),
    ("2026-04-22 11:07:00", "2026-04-22 11:27:59", "-"),
]

tick_interval = 120

# 输出目录
save_dir = "./output_imgs"
# os.makedirs(save_dir, exist_ok=True)

# ================= 工具函数 =================

def calc_absolute_humidity(temp_c, rh):
    """
    根据温度(°C)和相对湿度(%RH)计算绝对湿度(g/m³)
    """
    es = 6.112 * np.exp((17.67 * temp_c) / (temp_c + 243.5))
    e = rh / 100.0 * es
    ah = 216.7 * e / (273.15 + temp_c)
    return ah

def sanitize_filename(text):
    """
    清理文件名中的非法字符，保留中文、英文、数字、下划线、横线
    """
    text = text.strip()
    text = text.replace(" ", "_")
    text = re.sub(r'[\\/:\*\?"<>\|]', "_", text)
    return text

def load_data(file_path, start_time, end_time):
    df = pd.read_excel(file_path)

    # 跳过前 27 行并重置索引
    df = df.iloc[27:].reset_index(drop=True)
    df.columns = ["序号", "温度", "湿度", "时间"]

    # 转换类型
    df["时间"] = pd.to_datetime(df["时间"], errors="coerce")
    df["温度"] = pd.to_numeric(df["温度"], errors="coerce")
    df["湿度"] = pd.to_numeric(df["湿度"], errors="coerce")

    # 删除无效行
    df = df.dropna(subset=["时间", "温度", "湿度"]).copy()

    # 按时间范围筛选
    df = df[
        (df["时间"] >= pd.to_datetime(start_time)) &
        (df["时间"] <= pd.to_datetime(end_time))
    ].copy()

    # 计算绝对湿度
    df["绝对湿度"] = calc_absolute_humidity(df["温度"], df["湿度"])

    return df

# ================= 主循环 =================

for idx, (start_time, end_time, title_desc) in enumerate(time_ranges, start=1):

    dfs = [load_data(fp, start_time, end_time) for fp in file_paths]

    # 如果两个文件都没数据，就跳过
    if all(df.empty for df in dfs):
        print(f"跳过：{title_desc} ({start_time} ~ {end_time})，没有数据")
        continue

    fig, ax1 = plt.subplots(figsize=(12, 5))
    ax2 = ax1.twinx()

    temp_colors = ['tab:red', 'lightcoral']
    ah_colors   = ['tab:blue', 'deepskyblue']

    lines = []
    labels_all = []

    for i, df in enumerate(dfs):
        if df.empty:
            print(f"提示：{labels[i]} 在时间段 {start_time} ~ {end_time} 内无数据")
            continue

        # 温度曲线
        l1, = ax1.plot(
            df["时间"],
            df["温度"],
            color=temp_colors[i],
            linewidth=1.5,
            marker='o',
            markersize=3,
            label=f"{labels[i]} Temp"
        )

        # 绝对湿度曲线
        l2, = ax2.plot(
            df["时间"],
            df["绝对湿度"],
            color=ah_colors[i],
            linewidth=1.5,
            linestyle='--',
            marker='o',
            markersize=3,
            label=f"{labels[i]} AH"
        )

        lines.extend([l1, l2])
        labels_all.extend([f"{labels[i]} Temp", f"{labels[i]} AH"])

    # ================= 坐标轴 =================

    ax1.set_ylabel("Temperature (°C)")
    ax2.set_ylabel("Absolute Humidity (g/m³)")

    ax1.set_ylim(20, 40)
    ax2.set_ylim(5, 30)

    # X 轴格式
    ax1.xaxis.set_major_formatter(mdates.DateFormatter('%H:%M'))
    ax1.xaxis.set_major_locator(mdates.SecondLocator(interval=tick_interval))

    minor_interval = max(1, tick_interval // 2)
    ax1.xaxis.set_minor_locator(mdates.SecondLocator(interval=minor_interval))

    fig.autofmt_xdate(rotation=60)

    # 图例
    if lines:
        ax1.legend(lines, labels_all, loc="best")

    # 网格
    ax1.grid(True, linestyle='--', alpha=0.5)

    # 标题：使用列表最后一个元素
    plt.title(f"{title_desc}\n({start_time} ~ {end_time})")

    plt.tight_layout()

    # ================= 保存 =================

    safe_title = sanitize_filename(title_desc)
    safe_start = sanitize_filename(start_time.replace(":", "-"))
    safe_end   = sanitize_filename(end_time.replace(":", "-"))

    file_name = f"{idx:02d}_{safe_title}_{safe_start}__{safe_end}.png"
    save_path = os.path.join(save_dir, file_name)

    plt.savefig(save_path, dpi=150, bbox_inches='tight')
    plt.close()

    print(f"Saved: {save_path}")

print("全部图片生成完成。")