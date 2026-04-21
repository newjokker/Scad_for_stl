import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import os

# ================= 参数 =================

file_paths = [
    "/Volumes/Jokker/Code/Scad_for_stl/z_声学超结构/data/温湿度数据/0421-16-01/C0028001802D-SN号C0028001802D-历史记录-2026年04月21日16时01分.xlsx",
    "/Volumes/Jokker/Code/Scad_for_stl/z_声学超结构/data/温湿度数据/0421-16-01/C00280018035-SN号C00280018035-历史记录-2026年04月21日16时01分.xlsx"
]

labels = ["Sensor A", "Sensor B"]

# 👉 时间段列表
time_ranges = [
    ("2026-04-21 10:56:30", "2026-04-21 11:16:30", "主动排湿 5v"),
    ("2026-04-21 11:22:15", "2026-04-21 11:42:15", "被动排湿 0v"),
    ("2026-04-21 11:46:00", "2026-04-21 12:06:00", "被动排湿 0v"),
    ("2026-04-21 13:43:00", "2026-04-21 14:03:00", "主动排湿 12v"),
    ("2026-04-21 14:32:15", "2026-04-21 14:52:15", "被动排湿-拆除撸猫口"),
    ("2026-04-21 14:59:50", "2026-04-21 15:19:50", "被动排湿-拆除撸猫口"),
    ("2026-04-21 15:24:10", "2026-04-21 15:44:10", "主动排湿 12v"),
    ("2026-04-21 15:52:00", "2026-04-21 16:12:00", "常规-撸猫口"),
    ("2026-04-21 16:15:10", "2026-04-21 16:35:10", "常规-撸猫口"),
]

tick_interval = 120

# 👉 输出目录
save_dir = "./output_imgs"
os.makedirs(save_dir, exist_ok=True)

# ================= 绝对湿度计算 =================

def calc_absolute_humidity(temp_c, rh):
    es = 6.112 * np.exp((17.67 * temp_c) / (temp_c + 243.5))
    e = rh / 100.0 * es
    ah = 216.7 * e / (273.15 + temp_c)
    return ah

# ================= 读取函数 =================

def load_data(file_path, start_time, end_time):
    df = pd.read_excel(file_path)

    df = df.iloc[27:].reset_index(drop=True)
    df.columns = ["序号", "温度", "湿度", "时间"]

    df["时间"] = pd.to_datetime(df["时间"], errors="coerce")
    df["温度"] = pd.to_numeric(df["温度"], errors="coerce")
    df["湿度"] = pd.to_numeric(df["湿度"], errors="coerce")

    df = df.dropna(subset=["时间", "温度", "湿度"]).copy()

    df = df[(df["时间"] >= pd.to_datetime(start_time)) &
            (df["时间"] <= pd.to_datetime(end_time))]

    df["绝对湿度"] = calc_absolute_humidity(df["温度"], df["湿度"])

    return df

# ================= 主循环 =================

for idx, (start_time, end_time) in enumerate(time_ranges):

    dfs = [load_data(fp, start_time, end_time) for fp in file_paths]

    fig, ax1 = plt.subplots(figsize=(12, 5))
    ax2 = ax1.twinx()

    temp_colors = ['tab:red', 'lightcoral']
    ah_colors   = ['tab:blue', 'deepskyblue']

    lines = []
    labels_all = []

    for i, df in enumerate(dfs):
        l1, = ax1.plot(
            df["时间"], df["温度"],
            color=temp_colors[i],
            linewidth=1.5,
            marker='o',
            markersize=3,
            label=f"{labels[i]} Temp"
        )

        l2, = ax2.plot(
            df["时间"], df["绝对湿度"],
            color=ah_colors[i],
            linewidth=1.5,
            linestyle='--',
            marker='o',
            markersize=3,
            label=f"{labels[i]} AH"
        )

        lines.extend([l1, l2])
        labels_all.extend([f"{labels[i]} Temp", f"{labels[i]} AH"])

    # 坐标轴
    ax1.set_ylabel("Temperature (°C)")
    ax2.set_ylabel("Absolute Humidity (g/m³)")

    ax1.set_ylim(20, 40)
    ax2.set_ylim(5, 30)

    ax1.xaxis.set_major_formatter(mdates.DateFormatter('%H:%M'))
    ax1.xaxis.set_major_locator(mdates.SecondLocator(interval=tick_interval))

    minor_interval = max(1, tick_interval // 2)
    ax1.xaxis.set_minor_locator(mdates.SecondLocator(interval=minor_interval))

    fig.autofmt_xdate(rotation=60)

    ax1.legend(lines, labels_all, loc="best")
    ax1.grid(True, linestyle='--', alpha=0.5)

    plt.title(f"Temp & AH ({start_time} ~ {end_time})")

    plt.tight_layout()

    # ================= 保存 =================

    file_name = f"{start_time.replace(':','-')}__{end_time.replace(':','-')}.png"
    save_path = os.path.join(save_dir, file_name)

    plt.savefig(save_path, dpi=150)
    plt.close()

    print(f"Saved: {save_path}")