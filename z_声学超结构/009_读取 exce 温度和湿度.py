import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as mdates

# ================= 参数 =================

file_paths = [
    "/Volumes/Jokker/Code/Scad_for_stl/z_声学超结构/data/C0028001802D-SN号C0028001802D-历史记录-2026年04月20日14时14分.xlsx",
    "/Volumes/Jokker/Code/Scad_for_stl/z_声学超结构/data/C00280018035-SN号C00280018035-历史记录-2026年04月20日14时15分.xlsx"
]

labels = ["Sensor A", "Sensor B"]

start_time = "2026-04-20 11:34:43"
end_time   = "2026-04-20 12:20:43"

tick_interval = 120

# ================= 读取函数 =================

def load_data(file_path):
    df = pd.read_excel(file_path)
    df = df.iloc[27:].reset_index(drop=True)
    df.columns = ["序号", "温度", "湿度", "时间"]

    df["时间"] = pd.to_datetime(df["时间"])
    df["温度"] = pd.to_numeric(df["温度"], errors="coerce")
    df["湿度"] = pd.to_numeric(df["湿度"], errors="coerce")

    if start_time is not None:
        df = df[df["时间"] >= pd.to_datetime(start_time)]
    if end_time is not None:
        df = df[df["时间"] <= pd.to_datetime(end_time)]

    return df

# ================= 加载数据 =================

dfs = [load_data(fp) for fp in file_paths]

# ================= 画图 =================

fig, ax1 = plt.subplots(figsize=(12,5))
ax2 = ax1.twinx()

# 👉 颜色设计（同类不同色）
temp_colors = ['tab:red', 'lightcoral']
hum_colors  = ['tab:blue', 'deepskyblue']

lines = []
labels_all = []

for i, df in enumerate(dfs):
    # 温度
    l1, = ax1.plot(
        df["时间"],
        df["温度"],
        color=temp_colors[i],
        linewidth=1.5,
        marker='o',
        markersize=3,
        label=f"{labels[i]} Temp"
    )

    # 湿度
    l2, = ax2.plot(
        df["时间"],
        df["湿度"],
        color=hum_colors[i],
        linewidth=1.5,
        linestyle='--',
        marker='o',
        markersize=3,
        label=f"{labels[i]} Hum"
    )

    lines.extend([l1, l2])
    labels_all.extend([f"{labels[i]} Temp", f"{labels[i]} Hum"])

# ================= 坐标轴 =================

ax1.set_ylabel("Temperature (°C)")
ax2.set_ylabel("Humidity (%RH)")

# X轴格式
ax1.xaxis.set_major_formatter(mdates.DateFormatter('%H:%M'))
ax1.xaxis.set_major_locator(mdates.SecondLocator(interval=tick_interval))
ax1.xaxis.set_minor_locator(mdates.SecondLocator(interval=tick_interval // 2))

fig.autofmt_xdate(rotation=60)

# ================= 图例 =================
ax1.legend(lines, labels_all)

# ================= 网格 =================
ax1.grid(True, linestyle='--', alpha=0.5)

# ================= 标题 =================
plt.title("Temperature & Humidity Comparison")

plt.tight_layout()
plt.show()