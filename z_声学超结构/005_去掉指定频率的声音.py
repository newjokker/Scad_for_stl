import numpy as np
import soundfile as sf

def remove_frequency_band(input_wav, output_wav, freq_min, freq_max):
    """
    Remove a specific frequency band from a WAV file.

    Parameters:
        input_wav: str, path to input WAV file
        output_wav: str, path to save processed WAV
        freq_min: float, lower bound of frequency range to remove (Hz)
        freq_max: float, upper bound of frequency range to remove (Hz)
    """
    # 1. 读取 WAV 文件
    data, sr = sf.read(input_wav)
    if data.ndim > 1:
        # 处理多通道，只用第 0 通道
        data = data[:, 0]
    
    # 2. FFT
    N = len(data)
    fft_data = np.fft.fft(data)
    freqs = np.fft.fftfreq(N, d=1/sr)
    
    # 3. 找到指定频率范围索引
    mask = (np.abs(freqs) >= freq_min) & (np.abs(freqs) <= freq_max)
    
    # 4. 将这些频率置零
    fft_data[mask] = 0
    
    # 5. IFFT
    processed_data = np.fft.ifft(fft_data)
    processed_data = np.real(processed_data)  # 去掉虚部残留
    
    # 6. 保存为 WAV
    sf.write(output_wav, processed_data, sr)
    print(f"Saved processed WAV to {output_wav}")

# --------------------------
# 示例用法
# --------------------------
input_wav = "自己买的风机.wav"
output_wav = "output_filtered_自己买的风机2.wav.wav"
freq_min = 1080    # Hz
freq_max = 1084   # Hz

remove_frequency_band(input_wav, output_wav, freq_min, freq_max)

remove_frequency_band(output_wav, output_wav, freq_min *2, freq_max*2)