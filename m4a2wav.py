
import subprocess
from pathlib import Path

def m4a_to_wav(input_file: str, output_file: str, sample_rate: int = 16000, channels: int = 1):
    cmd = [
        "ffmpeg",
        "-y",                  # 覆盖输出文件
        "-i", input_file,      # 输入文件
        "-ar", str(sample_rate),
        "-ac", str(channels),
        output_file
    ]
    subprocess.run(cmd, check=True)

# 示例
m4a_to_wav("/Volumes/Jokker/Code/Scad_for_stl/中新大道 6.m4a", "output.wav")

