import numpy as np
from scipy.io.wavfile import write

# -------- 参数 --------
duration = 50           # 秒
fs = 44100              # 采样率
f_start = 200           # 起始频率 (Hz)
f_end = 2500            # 结束频率 (Hz)

# -------- 时间轴 --------
t = np.linspace(0, duration, int(fs * duration), endpoint=False)

# -------- 生成幅值平坦的线性扫频信号 --------
# 正确的相位计算：相位 = 2π * ∫f(t)dt
# 对于线性扫频 f(t) = f_start + (f_end - f_start) * t / duration
# 积分得：phase = 2π * [f_start * t + 0.5 * (f_end - f_start) * t² / duration]
phase = 2 * np.pi * (f_start * t + 0.5 * (f_end - f_start) * t**2 / duration)
signal = np.sin(phase)

# -------- 防止削波 --------
signal = signal * 0.8  # 将幅值缩放到[-0.8, 0.8]范围内

# -------- 转换为16bit PCM --------
audio = np.int16(signal * 32767)

# -------- 保存wav文件 --------
filename = f"sweep_{f_start:.1f}Hz_to_{f_end:.1f}Hz_{duration}s.wav"
write(filename, fs, audio)

print(f"音频生成完成: {filename}")
print(f"参数: 持续时间={duration}s, 采样率={fs}Hz")
print(f"     起始频率={f_start:.2f}Hz, 结束频率={f_end:.2f}Hz")
print(f"     幅值已归一化(×0.8)，确保16bit无削波")