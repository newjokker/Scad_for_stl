import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as mdates

# ================= 参数（你只需要改这里） =================

file_path = "/Volumes/Jokker/Code/Scad_for_stl/z_声学超结构/data/C00280018035-SN号C00280018035-历史记录-2026年04月20日11时43分.xlsx"

# 👉 时间筛选（None 表示不过滤）
start_time = "2026-04-20 09:30:00"
end_time   = "2026-04-20 10:00:00"

# 👉 横轴密度（秒）
tick_interval = 20   # 10 / 20 / 30 自己调

# ==========================================================

# === 读取 Excel ===
df = pd.read_excel(file_path)

# === 从第28行开始 ===
df = df.iloc[27:].reset_index(drop=True)

# === 重命名列 ===
df.columns = ["序号", "温度", "湿度", "时间"]

# === 类型转换 ===
df["时间"] = pd.to_datetime(df["时间"])
df["温度"] = pd.to_numeric(df["温度"], errors="coerce")

# === 时间筛选（核心）===
if start_time is not None:
    df = df[df["时间"] >= pd.to_datetime(start_time)]
if end_time is not None:
    df = df[df["时间"] <= pd.to_datetime(end_time)]

# === 画图 ===
plt.figure(figsize=(12,5))

# 👉 关键：加 marker='o' 就有小圆点
plt.plot(
    df["时间"],
    df["温度"],
    marker='o',        # 小圆点
    markersize=4,      # 点大小（可调 3~6）
    linewidth=1        # 线细一点更清晰
)

# === 横轴格式 ===
ax = plt.gca()
ax.xaxis.set_major_formatter(mdates.DateFormatter('%H:%M:%S'))
ax.xaxis.set_major_locator(mdates.SecondLocator(interval=tick_interval))

# === 标签 ===
plt.xlabel("Time")
plt.ylabel("Temperature (°C)")
plt.title("Temperature vs Time")

plt.xticks(rotation=45)
plt.grid(True, linestyle='--', alpha=0.5)

plt.tight_layout()
plt.show()