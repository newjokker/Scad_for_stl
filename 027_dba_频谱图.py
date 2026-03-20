#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import numpy as np
import matplotlib.pyplot as plt
from scipy.io import wavfile
from scipy import signal


def a_weighting_db(f_hz: np.ndarray) -> np.ndarray:
    """
    Return A-weighting values in dB for frequency array f_hz.
    Formula based on IEC/CD 1672.
    """
    f = np.asarray(f_hz, dtype=np.float64)
    f = np.maximum(f, 1e-12)  # avoid divide-by-zero

    ra_num = (12200.0 ** 2) * (f ** 4)
    ra_den = (
        (f ** 2 + 20.6 ** 2)
        * np.sqrt((f ** 2 + 107.7 ** 2) * (f ** 2 + 737.9 ** 2))
        * (f ** 2 + 12200.0 ** 2)
    )
    ra = ra_num / ra_den
    a_db = 20.0 * np.log10(ra) + 2.0
    return a_db


def load_wav_mono(wav_path: str):
    """
    Read wav and convert to mono float64 normalized signal.
    """
    sr, data = wavfile.read(wav_path)

    # Convert to float
    if data.dtype == np.int16:
        x = data.astype(np.float64) / 32768.0
    elif data.dtype == np.int32:
        x = data.astype(np.float64) / 2147483648.0
    elif data.dtype == np.uint8:
        x = (data.astype(np.float64) - 128.0) / 128.0
    else:
        x = data.astype(np.float64)

    # Stereo -> mono
    if x.ndim == 2:
        x = np.mean(x, axis=1)

    return sr, x


def compute_spectrum(x: np.ndarray, sr: int, nperseg: int = 65536):
    """
    Use Welch PSD estimate.
    Returns:
        f      : frequency axis
        psd    : power spectral density
    """
    f, psd = signal.welch(
        x,
        fs=sr,
        window="hann",
        nperseg=min(nperseg, len(x)),
        noverlap=min(nperseg, len(x)) // 2,
        detrend="constant",
        scaling="density"
    )
    return f, psd


def plot_a_weighted_spectrum(
    wav_path: str,
    out_path: str = "a_weighted_spectrum.png",
):
    sr, x = load_wav_mono(wav_path)
    f, psd = compute_spectrum(x, sr)

    # 转 dB
    psd_db = 10.0 * np.log10(np.maximum(psd, 1e-30))

    # A 加权
    a_db = a_weighting_db(f)
    psd_a_db = psd_db + a_db

    # ===== 只保留 100 Hz ~ 10 kHz =====
    fmin = 100.0
    fmax = 10000.0
    mask = (f >= fmin) & (f <= fmax)

    f_plot = f[mask]
    psd_db_plot = psd_db[mask]
    psd_a_db_plot = psd_a_db[mask]

    # ===== 绘图 =====
    plt.figure(figsize=(12, 6))
    plt.semilogx(f_plot, psd_db_plot, label="Original (dB)")
    plt.semilogx(f_plot, psd_a_db_plot, label="A-weighted (dB(A))")

    plt.xlim(fmin, fmax)
    plt.xlabel("Frequency (Hz)")
    plt.ylabel("Level (dB)")
    plt.title("Spectrum (100 Hz – 10 kHz)")
    plt.grid(True, which="both", alpha=0.3)
    plt.legend()
    plt.tight_layout()
    plt.savefig(out_path, dpi=200)
    plt.show()

if __name__ == "__main__":
    wav_path = "/Volumes/Jokker/Code/Scad_for_stl/bandlimited_noise_200.0Hz_to_2500.0Hz_10s.wav"   # 改成你的 wav 路径
    plot_a_weighted_spectrum(wav_path)