import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as mdates

# ================= 参数 =================

# file_paths = [
#     "/Volumes/Jokker/Code/Scad_for_stl/z_声学超结构/data/温湿度数据/0420-14-14/C0028001802D-SN号C0028001802D-历史记录-2026年04月20日14时14分.xlsx",
#     "/Volumes/Jokker/Code/Scad_for_stl/z_声学超结构/data/温湿度数据/0420-14-14/C00280018035-SN号C00280018035-历史记录-2026年04月20日14时15分.xlsx"
# ]

file_paths = [
    "/Volumes/Jokker/Code/Scad_for_stl/z_声学超结构/data/温湿度数据/0421-16-01/C0028001802D-SN号C0028001802D-历史记录-2026年04月21日16时01分.xlsx",
    "/Volumes/Jokker/Code/Scad_for_stl/z_声学超结构/data/温湿度数据/0421-16-01/C00280018035-SN号C00280018035-历史记录-2026年04月21日16时01分.xlsx"
]

labels = ["Sensor A", "Sensor B"]

start_time = "2026-04-21 10:56:30"
end_time   = "2026-04-21 11:16:30"

start_time = "2026-04-21 11:22:15"
end_time   = "2026-04-21 11:42:15"

start_time = "2026-04-21 11:46:00"
end_time   = "2026-04-21 12:06:00"

start_time = "2026-04-21 13:43:00"
end_time   = "2026-04-21 14:03:00"

start_time = "2026-04-21 14:08:30"
end_time   = "2026-04-21 14:28:30"

tick_interval = 120

# ================= 绝对湿度计算函数 =================

def calc_absolute_humidity(temp_c, rh):
    """
    根据温度(°C)和相对湿度(%RH)计算绝对湿度(g/m³)

    公式：
    Es = 6.112 * exp((17.67*T)/(T+243.5))   # 饱和水汽压 hPa
    E  = RH/100 * Es                        # 实际水汽压 hPa
    AH = 216.7 * E / (273.15 + T)           # 绝对湿度 g/m³
    """
    es = 6.112 * np.exp((17.67 * temp_c) / (temp_c + 243.5))
    e = rh / 100.0 * es
    ah = 216.7 * e / (273.15 + temp_c)
    return ah

# ================= 读取函数 =================

def load_data(file_path):
    df = pd.read_excel(file_path)

    # 跳过前27行并重置索引
    df = df.iloc[27:].reset_index(drop=True)
    df.columns = ["序号", "温度", "湿度", "时间"]

    # 数据类型转换
    df["时间"] = pd.to_datetime(df["时间"], errors="coerce")
    df["温度"] = pd.to_numeric(df["温度"], errors="coerce")
    df["湿度"] = pd.to_numeric(df["湿度"], errors="coerce")

    # 删除关键列为空的行
    df = df.dropna(subset=["时间", "温度", "湿度"]).copy()

    # 时间筛选
    if start_time is not None:
        df = df[df["时间"] >= pd.to_datetime(start_time)]
    if end_time is not None:
        df = df[df["时间"] <= pd.to_datetime(end_time)]

    # 计算绝对湿度
    df["绝对湿度"] = calc_absolute_humidity(df["温度"], df["湿度"])

    return df

# ================= 加载数据 =================

dfs = [load_data(fp) for fp in file_paths]

# ================= 画图 =================

fig, ax1 = plt.subplots(figsize=(12, 5))
ax2 = ax1.twinx()

# 同类不同色
temp_colors = ['tab:red', 'lightcoral']
ah_colors   = ['tab:blue', 'deepskyblue']

lines = []
labels_all = []

for i, df in enumerate(dfs):
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

# X轴格式
ax1.xaxis.set_major_formatter(mdates.DateFormatter('%H:%M'))
ax1.xaxis.set_major_locator(mdates.SecondLocator(interval=tick_interval))

minor_interval = max(1, tick_interval // 2)
ax1.xaxis.set_minor_locator(mdates.SecondLocator(interval=minor_interval))

fig.autofmt_xdate(rotation=60)

# ================= 图例 =================

ax1.legend(lines, labels_all, loc="best")

# ================= 网格 =================

ax1.grid(True, linestyle='--', alpha=0.5)

# ================= 标题 =================

plt.title("Temperature & Absolute Humidity Comparison")

plt.tight_layout()
plt.show()