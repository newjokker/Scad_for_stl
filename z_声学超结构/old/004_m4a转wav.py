from pydub import AudioSegment
import os

def convert_m4a_to_wav(input_path, output_path=None, sample_rate=44100, channels=1):
    """
    将 M4A 文件转换为 WAV 格式
    
    参数:
        input_path: 输入 M4A 文件路径
        output_path: 输出 WAV 文件路径（如为None则自动生成）
        sample_rate: 采样率（默认44100Hz）
        channels: 声道数（1=单声道, 2=立体声）
    """
    try:
        # 自动生成输出路径
        if output_path is None:
            base_name = os.path.splitext(input_path)[0]
            output_path = f"{base_name}.wav"
        
        # 加载 M4A 文件
        print(f"正在转换: {input_path}")
        audio = AudioSegment.from_file(input_path, format="m4a")
        
        # 设置参数
        audio = audio.set_frame_rate(sample_rate)
        audio = audio.set_channels(channels)
        
        # 导出为 WAV
        audio.export(output_path, format="wav")
        print(f"转换完成: {output_path}")
        print(f"文件大小: {os.path.getsize(output_path) / 1024:.2f} KB")
        
        return output_path
        
    except Exception as e:
        print(f"转换失败: {str(e)}")
        return None

# 使用示例
if __name__ == "__main__":
    # 单个文件转换
    convert_m4a_to_wav("/Volumes/Jokker/Code/Scad_for_stl/没有整流板.m4a", "没有整流板.wav")
    convert_m4a_to_wav("/Volumes/Jokker/Code/Scad_for_stl/有整流板.m4a", "有整流板.wav")
    