import subprocess
import os
import sys

def convert_m4a_to_wav(input_path, output_path=None, sample_rate=44100, channels=1):
    """
    使用 ffmpeg 将 M4A 文件转换为 WAV 格式
    
    参数:
        input_path: 输入 M4A 文件路径
        output_path: 输出 WAV 文件路径（如为None则自动生成）
        sample_rate: 采样率（默认44100Hz）
        channels: 声道数（1=单声道, 2=立体声）
    """
    # 检查输入文件是否存在
    if not os.path.exists(input_path):
        print(f"❌ 错误: 输入文件不存在: {input_path}")
        return None
    
    # 自动生成输出路径
    if output_path is None:
        base_name = os.path.splitext(input_path)[0]
        output_path = f"{base_name}.wav"
    
    # 确保输出目录存在
    output_dir = os.path.dirname(output_path)
    if output_dir and not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    try:
        print(f"🔄 正在转换: {os.path.basename(input_path)}")
        
        # 构建 ffmpeg 命令
        # -i: 输入文件
        # -ac: 声道数 (channels)
        # -ar: 采样率 (sample_rate)
        # -y: 覆盖输出文件（不询问）
        cmd = [
            'ffmpeg',
            '-i', input_path,
            '-ac', str(channels),
            '-ar', str(sample_rate),
            '-y',
            output_path
        ]
        
        # 执行转换，隐藏 ffmpeg 的详细输出
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            check=False
        )
        
        if result.returncode == 0:
            # 计算文件大小
            file_size = os.path.getsize(output_path) / (1024 * 1024)
            print(f"✅ 转换完成: {output_path}")
            print(f"📊 文件大小: {file_size:.2f} MB")
            print(f"📊 采样率: {sample_rate} Hz, 声道: {channels}")
            return output_path
        else:
            print(f"❌ ffmpeg 转换失败:")
            print(result.stderr)
            return None
            
    except FileNotFoundError:
        print("❌ 错误: 未找到 ffmpeg 命令")
        print("💡 请先安装 ffmpeg:")
        print("   macOS: brew install ffmpeg")
        print("   Ubuntu: sudo apt-get install ffmpeg")
        print("   Windows: 从 https://ffmpeg.org/download.html 下载")
        return None
    except Exception as e:
        print(f"❌ 转换失败: {str(e)}")
        return None


def batch_convert_m4a_to_wav(input_dir, output_dir=None, sample_rate=44100, channels=1):
    """
    批量转换目录下所有 M4A 文件
    
    参数:
        input_dir: 输入目录
        output_dir: 输出目录（如为None则与输入目录相同）
        sample_rate: 采样率
        channels: 声道数
    """
    if not os.path.exists(input_dir):
        print(f"❌ 错误: 输入目录不存在: {input_dir}")
        return
    
    # 查找所有 m4a 文件
    m4a_files = []
    for root, dirs, files in os.walk(input_dir):
        for file in files:
            if file.lower().endswith(('.m4a', '.mp4')):
                m4a_files.append(os.path.join(root, file))
    
    if not m4a_files:
        print(f"⚠️ 在 {input_dir} 中未找到任何 M4A 文件")
        return
    
    print(f"📁 找到 {len(m4a_files)} 个 M4A 文件")
    print("-" * 50)
    
    success_count = 0
    for i, input_path in enumerate(m4a_files, 1):
        print(f"\n[{i}/{len(m4a_files)}] 处理中...")
        
        # 生成输出路径
        if output_dir:
            relative_path = os.path.relpath(input_path, input_dir)
            output_path = os.path.join(output_dir, relative_path)
            output_path = os.path.splitext(output_path)[0] + '.wav'
        else:
            output_path = os.path.splitext(input_path)[0] + '.wav'
        
        # 执行转换
        result = convert_m4a_to_wav(input_path, output_path, sample_rate, channels)
        if result:
            success_count += 1
    
    print("\n" + "=" * 50)
    print(f"✅ 批量转换完成: 成功 {success_count}/{len(m4a_files)} 个文件")


# 使用示例
if __name__ == "__main__":
    # ====== 单文件转换 ======
    # 使用你的实际路径
    input_file = "/Volumes/Jokker/Code/Scad_for_stl/z_声学超结构/data/贤坤路60号 3.m4a"
    output_file = "主动排湿口.wav"
    
    convert_m4a_to_wav(input_file, output_file)
    
    # ====== 批量转换示例（如果你需要） ======
    # 取消注释下面的代码来批量转换整个目录
    # batch_convert_m4a_to_wav(
    #     input_dir="/Volumes/Jokker/Code/Scad_for_stl/z_声学超结构/data",
    #     output_dir="./converted_wav",
    #     sample_rate=44100,
    #     channels=1
    # )