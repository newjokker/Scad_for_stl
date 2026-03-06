import numpy as np
from scipy.io.wavfile import write

# -------- 参数 --------
duration = 50            # 秒
fs = 44100               # 采样率
f_start = 200            # 起始频率
f_end = 2500             # 结束频率

# -------- 时间轴 --------
t = np.linspace(0, duration, int(fs * duration))

# -------- 线性扫频 --------
freq = f_start + (f_end - f_start) * t / duration

# -------- 生成信号 --------
signal = np.sin(2 * np.pi * freq * t)

# -------- 防止削波 --------
signal = signal * 0.8

# -------- 转换为16bit --------
audio = np.int16(signal * 32767)

# -------- 保存wav --------
write(f"sweep_{f_start}_{f_end}.wav", fs, audio)
# write(f"200.wav", fs, audio)

print("音频生成完成: sweep_900_1418.wav")



