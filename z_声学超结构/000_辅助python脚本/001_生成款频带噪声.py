import numpy as np
from scipy.io.wavfile import write

# -------- 参数 --------
duration = 10           # 秒
fs = 44100              # 采样率
f_low = 200             # 低频截止频率 (Hz)
f_high = 2500           # 高频截止频率 (Hz)

# -------- 时间轴 --------
t = np.linspace(0, duration, int(fs * duration), endpoint=False)

# -------- 生成高斯白噪声 --------
np.random.seed(42)  # 设置随机种子保证可重复性
white_noise = np.random.normal(0, 1, len(t))

# -------- 设计带通滤波器 --------
from scipy import signal

# 设计巴特沃斯带通滤波器
nyquist = fs / 2
low_cutoff = f_low / nyquist
high_cutoff = f_high / nyquist
b, a = signal.butter(4, [low_cutoff, high_cutoff], btype='band')

# -------- 应用带通滤波器 --------
filtered_noise = signal.filtfilt(b, a, white_noise)

# -------- 归一化 --------
max_amplitude = np.max(np.abs(filtered_noise))
filtered_noise = filtered_noise / max_amplitude

# -------- 防止削波 --------
bandlimited_noise = filtered_noise * 0.8  # 将幅值缩放到[-0.8, 0.8]范围内

# -------- 转换为16bit PCM --------
audio = np.int16(bandlimited_noise * 32767)

# -------- 保存wav文件 --------
filename = f"bandlimited_noise_{f_low:.1f}Hz_to_{f_high:.1f}Hz_{duration}s.wav"
write(filename, fs, audio)

print(f"音频生成完成: {filename}")
print(f"参数: 持续时间={duration}s, 采样率={fs}Hz")
print(f"     频带范围={f_low:.2f}Hz - {f_high:.2f}Hz")
print(f"     幅值已归一化(×0.8)，确保16bit无削波")
print(f"     滤波器类型: 4阶巴特沃斯带通")