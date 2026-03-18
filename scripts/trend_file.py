#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# PEP 8 compliant
# Author: Jokker (refactored)

import os
import struct
import io
import numpy as np
from datetime import datetime
from scipy.io.wavfile import write as write_wav
from scipy.signal import resample

# 数据类型映射表
DATA_TYPES = {
    1: ('<?', 1, 'b', 'bool'),          # 布尔型（1字节）
    2: ('<i1', 1, 'b', 'int8'),         # 有符号8位整数
    3: ('<u1', 1, 'B', 'uint8'),        # 无符号8位整数
    4: ('<i2', 2, 'h', 'int16'),        # 有符号16位整数
    5: ('<u2', 2, 'H', 'uint16'),       # 无符号16位整数
    6: ('<i4', 4, 'i', 'int32'),        # 有符号32位整数
    7: ('<u4', 4, 'I', 'uint32'),       # 无符号32位整数
    8: ('<f4', 4, 'f', 'float32'),      # 32位浮点数（单精度）
    9: ('<f8', 8, 'd', 'float64'),      # 64位浮点数（双精度）
    10: ('<i8', 8, 'q', 'int64'),       # 有符号64位整数
    11: ('<u8', 8, 'Q', 'uint64'),      # 无符号64位整数
}

class TrendFile:
    """TREND 格式数据文件"""

    HEADER_FORMAT = '<5sBBxq'
    HEADER_SIZE = struct.calcsize(HEADER_FORMAT)
    CHANNEL_FORMAT = '<32s32sIIIII'
    CHANNEL_SIZE = struct.calcsize(CHANNEL_FORMAT)

    def __init__(self):
        self.magic = b'TREND'
        self.version = 3
        self.channels = []
        self.start_time = None

    # ----------------- 内部工具方法 -----------------
    @classmethod
    def _read_header(cls, f):
        header = f.read(cls.HEADER_SIZE)
        if len(header) != cls.HEADER_SIZE:
            raise ValueError("Invalid file header (too short)")
        magic, version, num_channels, start_time = struct.unpack(cls.HEADER_FORMAT, header)
        if magic != b'TREND':
            raise ValueError("Invalid file format (magic mismatch)")
        return magic, version, num_channels, start_time

    @classmethod
    def _read_channel_table(cls, f, num_channels):
        channels = []
        for _ in range(num_channels):
            channel_info = f.read(cls.CHANNEL_SIZE)
            if len(channel_info) != cls.CHANNEL_SIZE:
                raise ValueError("Invalid channel info (too short)")
            (device_id, channel_id, data_type, data_offset, data_size, sample_count, sample_rate) = struct.unpack(cls.CHANNEL_FORMAT, channel_info)
            
            # 这边检查一下 sample_count * data_type 对应的字节数 ?= data_size
            if sample_count * DATA_TYPES[data_type][1] != data_size:
                device_str = device_id.decode('utf-8').rstrip('\x00')
                channel_str = channel_id.decode('utf-8').rstrip('\x00')
                raise ValueError(f"{device_str}-{channel_str} 文件信息核对出错, sample_count * data_type 对应的字节数 != data_size, sample_count:{sample_count}, data_type 对应的字节数: {DATA_TYPES[data_type][1]}, data_size: {data_size}")
            
            channels.append({
                'device_id': device_id.decode('utf-8').rstrip('\x00'),
                'channel_id': channel_id.decode('utf-8').rstrip('\x00'),
                'data_type': data_type,
                'data_offset': data_offset,
                'data_size': data_size,
                'sample_count': sample_count,
                'sample_rate': sample_rate
            })
                        
        return channels

    @classmethod
    def _read_channel_data(cls, f, channels):
        for ch in channels:
            if ch['sample_count'] > 0:
                f.seek(ch['data_offset'])
                data_bytes = f.read(ch['data_size'])
                if len(data_bytes) != ch['data_size']:
                    raise ValueError(f"Data size mismatch for channel {ch['channel_id']}")
                dtype = DATA_TYPES[ch['data_type']][0]
                ch['data'] = np.frombuffer(data_bytes, dtype=dtype)
            else:
                ch['data'] = np.array([], dtype=DATA_TYPES[ch['data_type']][0])
        return channels

    @classmethod
    def _write_to_stream(cls, stream, tf):
        if tf.start_time is None:
            raise ValueError("start_time is None")
        if not tf.channels:
            raise ValueError("No channels to write")

        # 写头
        header = struct.pack(cls.HEADER_FORMAT, tf.magic, tf.version, len(tf.channels), tf.start_time)
        stream.write(header)

        # 写通道表
        data_offset = cls.HEADER_SIZE + cls.CHANNEL_SIZE * len(tf.channels)  
        channel_infos = []
        for ch in tf.channels:
            device_id = ch['device_id'].encode('utf-8').ljust(32, b'\x00')[:32]
            channel_id = ch['channel_id'].encode('utf-8').ljust(32, b'\x00')[:32]
            sample_count = len(ch['data'])
            item_size = DATA_TYPES[ch['data_type']][1]
            data_size = sample_count * item_size
            channel_infos.append({
                'device_id': device_id, 'channel_id': channel_id,
                'data_type': ch['data_type'], 'data_offset': data_offset,
                'data_size': data_size, 'sample_count': sample_count,
                'sample_rate': ch.get('sample_rate', 0)
            })
            data_offset += data_size

        for info in channel_infos:
            packed = struct.pack(cls.CHANNEL_FORMAT,
                                 info['device_id'], info['channel_id'],
                                 info['data_type'], info['data_offset'],
                                 info['data_size'], info['sample_count'], info['sample_rate'])
            stream.write(packed)

        # 写数据
        for ch in tf.channels:
            if len(ch['data']) > 0:
                data_bytes = ch['data'].astype(DATA_TYPES[ch['data_type']][0]).tobytes()
                stream.write(data_bytes)

    # ----------------- 公共 API -----------------
    @staticmethod
    def get_meta_from_bin(data):
        with io.BytesIO(data) as f:
            magic, version, num_channels, start_time = TrendFile._read_header(f)
            return {"magic": magic, "version": version,
                    "num_channels": num_channels, "start_time": start_time}

    @staticmethod
    def get_start_time_str(start_time, fmt: str = "%Y-%m-%d %H:%M:%S.%f") -> str:
        """将 start_time 从毫秒级时间戳转为格式化字符串"""
        if start_time is None:
            return "None"
        dt = datetime.fromtimestamp(start_time / 1000.0)
        return dt.strftime(fmt)[:-3]  

    @staticmethod
    def read(filename):
        with open(filename, 'rb') as f:
            return TrendFile._read_from_stream(f)

    @staticmethod
    def read_bin_data(data):
        with io.BytesIO(data) as f:
            return TrendFile._read_from_stream(f)

    @classmethod
    def _read_from_stream(cls, f):
        tf = TrendFile()
        tf.magic, tf.version, num_channels, tf.start_time = cls._read_header(f)
        tf.channels = cls._read_channel_table(f, num_channels)
        tf.channels = cls._read_channel_data(f, tf.channels)    
        tf._sort_channels_by_id()    
        return tf

    @staticmethod
    def read_assign_channel(filename, device_id, channel_id):
        with open(filename, 'rb') as f:
            return TrendFile._read_assign_channel_from_stream(f, device_id, channel_id)

    @staticmethod
    def read_assign_channel_from_bin_data(data, device_id, channel_id):
        with io.BytesIO(data) as f:
            return TrendFile._read_assign_channel_from_stream(f, device_id, channel_id)

    @classmethod
    def _read_assign_channel_from_stream(cls, f, device_id, channel_id):
        _, _, num_channels, _ = cls._read_header(f)
        for _ in range(num_channels):
            info = f.read(cls.CHANNEL_SIZE)
            (dev_id, ch_id, data_type, data_offset,
             data_size, sample_count, sample_rate) = struct.unpack(cls.CHANNEL_FORMAT, info)
            dev_id = dev_id.decode('utf-8').rstrip('\x00')
            ch_id = ch_id.decode('utf-8').rstrip('\x00')
            if dev_id == str(device_id) and ch_id == str(channel_id):
                target = {'device_id': dev_id, 'channel_id': ch_id,
                          'data_type': data_type, 'sample_rate': sample_rate,
                          'data_offset': data_offset, 'data_size': data_size,
                          'sample_count': sample_count}
                if sample_count > 0:
                    f.seek(data_offset)
                    data_bytes = f.read(data_size)
                    if len(data_bytes) != data_size:
                        raise ValueError("Data size mismatch")
                    dtype = DATA_TYPES[data_type][0]
                    target['data'] = np.frombuffer(data_bytes, dtype=dtype)
                else:
                    target['data'] = np.array([], dtype=DATA_TYPES[data_type][0])
                return target
        return None

    def add_channel(self, device_id, channel_id, data_type, sample_rate=0, data=None):
        if data_type not in DATA_TYPES:
            raise ValueError(f"Invalid data type: {data_type}")
        arr = np.array(data if data is not None else [], dtype=DATA_TYPES[data_type][0])
        self.channels.append({
            'device_id': str(device_id), 'channel_id': str(channel_id),
            'data_type': data_type, 'sample_rate': sample_rate, 'data': arr
        })

    @staticmethod
    def get_channel_table_from_bin(data):
        """从二进制数据中获取通道表信息（不解析实际数据）,返回包含所有通道信息的列表，但不包含实际数据"""
        
        with io.BytesIO(data) as f:
            # 读取文件头
            magic, version, num_channels, start_time = TrendFile._read_header(f)
            if magic != b'TREND':
                raise ValueError("Invalid file format (magic mismatch)")
            
            # 读取通道表
            channels = []
            for _ in range(num_channels):
                channel_info = f.read(TrendFile.CHANNEL_SIZE)
                if len(channel_info) != TrendFile.CHANNEL_SIZE:
                    raise ValueError("Invalid channel info (too short)")
                
                (device_id, channel_id, data_type, data_offset, 
                data_size, sample_count, sample_rate) = struct.unpack(TrendFile.CHANNEL_FORMAT, channel_info)
                
                channels.append({
                    'device_id': device_id.decode('utf-8').rstrip('\x00'),
                    'channel_id': channel_id.decode('utf-8').rstrip('\x00'),
                    'data_type': data_type,
                    'data_offset': data_offset,
                    'data_size': data_size,
                    'sample_count': sample_count,
                    'sample_rate': sample_rate
                })
            
            return {
                'magic': magic,
                'version': version,
                'start_time': start_time,
                'channels': channels
            }

    def get_data(self, device_id, channel_id):
        for ch in self.channels:
            if ch["device_id"] == str(device_id) and ch["channel_id"] == str(channel_id):
                return ch["data"]
        return None

    def write(self, filename):
        with open(filename, 'wb') as f:
            self._write_to_stream(f, self)

    def write_with_max_sample_rate(self, filename, max_sample_rate):
        """
        保存趋势文件，限制数据的最大采样率
        
        参数:
            filename: 输出文件名
            max_sample_rate: 最大允许的采样率(Hz)，超过此值的通道将被重采样
        """
        if max_sample_rate <= 0:
            raise ValueError("max_sample_rate must be positive")
        
        # 创建临时TrendFile对象用于修改数据
        temp_tf = TrendFile()
        temp_tf.magic = self.magic
        temp_tf.version = self.version
        temp_tf.start_time = self.start_time
        
        for ch in self.channels:
            original_sr = ch.get('sample_rate', 0)
            data = ch.get('data', np.array([]))
            
            if original_sr <= max_sample_rate or len(data) == 0:
                # 采样率已符合要求或没有数据，直接复制
                temp_tf.add_channel(
                    ch['device_id'], ch['channel_id'], ch['data_type'],
                    original_sr, data.copy()
                )
            else:                
                # 计算重采样后的点数
                original_length = len(data)
                new_length = int(original_length * max_sample_rate / original_sr)
                
                try:
                    # 执行重采样
                    resampled_data = resample(data, new_length)
                    
                    # 根据数据类型处理结果
                    if ch['data_type'] in [2, 3, 4, 5, 6, 7]:  # 整数类型
                        resampled_data = np.round(resampled_data).astype(DATA_TYPES[ch['data_type']][0])
                    
                    temp_tf.add_channel(
                        ch['device_id'], ch['channel_id'], ch['data_type'],
                        max_sample_rate, resampled_data
                    )
                except Exception as e:
                    print(f"Failed to resample channel {ch['device_id']}-{ch['channel_id']}: {str(e)}")
                    # 重采样失败，保留原始数据但降低采样率标记
                    temp_tf.add_channel(
                        ch['device_id'], ch['channel_id'], ch['data_type'],
                        max_sample_rate, data.copy()
                    )
        
        # 保存修改后的文件
        temp_tf.write(filename)

    def save_to_bin(self):
        buf = io.BytesIO()
        self._write_to_stream(buf, self)
        return buf.getvalue()

    def save_audio_channels_to_wav(self, output_dir, sample_rate=None, min_duration=0.1):
        """
        将趋势文件中的音频通道保存为WAV文件
        
        参数:
            output_dir: 输出目录路径
            sample_rate: 可选，指定目标采样率（如果None则使用通道的原始采样率）
            min_duration: 最小持续时间（秒），短于此值的音频将被忽略
            
        返回:
            成功保存的WAV文件路径列表
        """
        if not os.path.exists(output_dir):
            os.makedirs(output_dir)
        
        saved_files = []
        
        for ch in self.channels:
            # 检查数据类型是否适合音频（8/16/32位整数或32位浮点）
            if ch['data_type'] not in [2, 3, 4, 5, 6, 7, 8]:
                continue
                
            # 检查采样率是否合理
            sr = ch.get('sample_rate', 0)
            if sr <= 0:
                continue
                
            # 检查数据长度是否足够
            data = ch.get('data', np.array([]))
            if len(data) == 0:
                continue
                
            duration = len(data) / sr
            if duration < min_duration:
                continue
                
            # 确定目标采样率
            target_sr = sample_rate if sample_rate is not None else sr
            
            # 准备输出文件名
            filename = f"{ch['device_id']}_{ch['channel_id']}.wav"
            filepath = os.path.join(output_dir, filename)
            
            try:
                # 归一化并转换数据到适合WAV的格式
                if ch['data_type'] in [8]:  # 浮点数据
                    audio_data = np.float32(data)
                    # 确保数据在[-1, 1]范围内
                    if np.max(np.abs(audio_data)) > 1.0:
                        audio_data = audio_data / np.max(np.abs(audio_data))
                else:  # 整数数据
                    # 根据数据类型确定最大值
                    dtype_info = DATA_TYPES[ch['data_type']]
                    if dtype_info[2] in ['b', 'B', 'h', 'H', 'i', 'I']:
                        max_val = np.iinfo(dtype_info[0]).max
                        audio_data = np.int16(data / max_val * 32767)
                    else:
                        continue
                
                # 如果需要重采样
                if target_sr != sr:
                    from scipy.signal import resample
                    num_samples = int(len(audio_data) * target_sr / sr)
                    audio_data = resample(audio_data, num_samples)
                
                # 保存为WAV文件
                write_wav(filepath, target_sr, audio_data)
                saved_files.append(filepath)
                
            except Exception as e:
                print(f"Failed to save channel {ch['channel_id']} as WAV: {str(e)}")
                continue
                
        return saved_files

    def _sort_channels_by_id(self, numeric_sort=True):
        """根据 device_id（第一优先级）和 channel_id（第二优先级）对通道进行排序"""
        
        if not self.channels:
            return self
        
        def get_sort_key(channel, use_numeric=True):
            """生成排序键值"""
            device_id = str(channel.get('device_id', ''))
            channel_id = str(channel.get('channel_id', ''))
            
            if not use_numeric:
                # 纯字符串排序
                return (device_id, channel_id)
            
            # 尝试数字排序（数字ID排在前面）
            try:
                device_num = int(device_id)
                device_key = (0, device_num)  # 0表示数字，数字排在前面
            except (ValueError, TypeError):
                device_key = (1, device_id)   # 1表示非数字，排在后面
                
            try:
                channel_num = int(channel_id)
                channel_key = (0, channel_num)
            except (ValueError, TypeError):
                channel_key = (1, channel_id)
                
            return (device_key, channel_key, device_id, channel_id)
        
        # 执行排序
        self.channels.sort(key=lambda ch: get_sort_key(ch, numeric_sort))
                
        return self  

    def print_summary(self):
        print("-" * 100)
        print(f"File Format: {self.magic.decode()}, Version: {self.version}, "
              f"Start Time: {datetime.fromtimestamp(self.start_time / 1000).strftime('%Y-%m-%d %H:%M:%S.%f')[:-3]}, "
              f"Channels: {len(self.channels)}")
        print("-" * 100)
        print(f"{'Device ID':<15} {'Channel ID':<15} {'Type':<10} {'Rate(Hz)':<10} "
              f"{'Points':<10} {'Duration(s)':<12} {'DataSize':<10} {'Mean':<10}")
        for ch in self.channels:
            dtype_name = DATA_TYPES.get(ch['data_type'], ('unknown',))[3]
            sr = ch.get('sample_rate', 0)
            n = len(ch.get('data', []))
            data_size = ch.get('data_size', "None")
            duration = n / sr if sr > 0 else 0
            if n > 0 and ch['data'].dtype.kind in 'biufc':
                mean, std = np.mean(ch['data']), np.std(ch['data'])
            else:
                mean, std = 0, 0
            
            try:            
                print(f"{ch['device_id']:<15} {ch['channel_id']:<15} {dtype_name:<10} {sr:<10} "
                    f"{n:<10} {duration:<12.3f} {data_size:<10.4g} {mean:<10.4g}")
            except Exception as e:
                print(f"{ch['device_id']:<15} {ch['channel_id']:<15} {dtype_name:<10} {sr:<10} "
                    f"{n:<10} {duration:<12.3f}  {data_size} {mean}")
        print("-" * 100)

    def drop_channel(self, channel_id, device_id):
        for i, each in enumerate(self.channels):
            if (
                each["channel_id"] == str(channel_id)
                and each["device_id"] == str(device_id)
            ):
                del self.channels[i]
                return True
        return False

    def save_assign_channel_to_wav(self, save_path, assign_device=None, assign_channel=None):
        """
        将趋势文件中的音频通道保存为WAV文件
        
        参数:
            output_dir: 输出目录路径
            sample_rate: 可选，指定目标采样率（如果None则使用通道的原始采样率）
            min_duration: 最小持续时间（秒），短于此值的音频将被忽略
            
        返回:
            成功保存的WAV文件路径列表
        """
        saved_files = []
        
        for ch in self.channels:
            
            device_id, channel_id = ch['device_id'], ch['channel_id']
            if assign_device is not None:
                if str(device_id) != str(assign_device):
                    continue
                
            if assign_channel is not None:
                if str(channel_id) != str(assign_channel):
                    continue

            # 检查数据类型是否适合音频（8/16/32位整数或32位浮点）
            if ch['data_type'] not in [2, 3, 4, 5, 6, 7, 8]:
                raise ValueError("当前通道类型无法转为 .wav ")
            
            # 检查采样率是否合理
            sr = ch.get('sample_rate', 0)
            if sr <= 0:
                continue
                
            # 检查数据长度是否足够
            data = ch.get('data', np.array([]))
            if len(data) == 0:
                continue
                            
            try:
                # 归一化并转换数据到适合WAV的格式
                if ch['data_type'] in [8]:  # 浮点数据
                    audio_data = np.float32(data)
                    # 确保数据在[-1, 1]范围内
                    if np.max(np.abs(audio_data)) > 1.0:
                        audio_data = audio_data / np.max(np.abs(audio_data))
                else:  # 整数数据
                    # 根据数据类型确定最大值
                    dtype_info = DATA_TYPES[ch['data_type']]
                    if dtype_info[2] in ['b', 'B', 'h', 'H', 'i', 'I']:
                        max_val = np.iinfo(dtype_info[0]).max
                        audio_data = np.int16(data / max_val * 32767)
                    else:
                        continue
                
                # 保存为WAV文件
                write_wav(save_path, sr, audio_data)
                saved_files.append(save_path)
                
            except Exception as e:
                # print(f"Failed to save channel {ch['channel_id']} as WAV: {str(e)}")
                continue
                
        return saved_files


def merge_trend_files(trend_files):
    if not trend_files:
        raise ValueError("Empty trend_files list")
    base = {(ch['device_id'], ch['channel_id'], ch['data_type'], ch['sample_rate'])
            for ch in trend_files[0].channels}
    for tf in trend_files[1:]:
        now = {(ch['device_id'], ch['channel_id'], ch['data_type'], ch['sample_rate']) for ch in tf.channels}
        if now != base:
            raise ValueError("Channels mismatch")
    merged = TrendFile()
    merged.magic, merged.version, merged.start_time = (trend_files[0].magic,
                                                       trend_files[0].version,
                                                       trend_files[0].start_time)
    for dev, ch, dt, sr in base:
        data_list = []
        for tf in trend_files:
            for c in tf.channels:
                if (c['device_id'], c['channel_id'], c['data_type'], c['sample_rate']) == (dev, ch, dt, sr):
                    data_list.append(c['data'])
                    break
        merged.add_channel(dev, ch, dt, sr, np.concatenate(data_list) if data_list else [])
    return merged

def split_trend_object(tf, n_parts):
    """
    将TrendFile对象平均切分为N个部分
    
    参数:
        tf: 输入的TrendFile对象
        n_parts: 要切分的份数
        
    返回:
        包含N个TrendFile对象的列表
    """
    if not isinstance(tf, TrendFile):
        raise TypeError("Input must be a TrendFile object")
    
    if n_parts <= 0:
        raise ValueError("n_parts must be positive")
    
    # 计算每个通道在每个分片中的样本数
    split_points = {}
    for ch in tf.channels:
        total_samples = len(ch['data'])
        samples_per_part = total_samples // n_parts
        remainder = total_samples % n_parts
        
        # 计算每个分片的起始和结束索引
        indices = []
        start = 0
        for i in range(n_parts):
            end = start + samples_per_part + (1 if i < remainder else 0)
            indices.append((start, end))
            start = end
        split_points[(ch['device_id'], ch['channel_id'])] = indices
    
    # 创建分片对象列表
    output_trends = []
    for i in range(n_parts):
        new_tf = TrendFile()
        new_tf.magic = tf.magic
        new_tf.version = tf.version
        new_tf.start_time = tf.start_time
        
        for ch in tf.channels:
            dev_id = ch['device_id']
            ch_id = ch['channel_id']
            start, end = split_points[(dev_id, ch_id)][i]
            data_slice = ch['data'][start:end]
            item_size = DATA_TYPES[ch['data_type']][1]  # 获取每个样本的字节数
            new_tf.add_channel(
                dev_id, ch_id, ch['data_type'], ch['sample_rate'],
                data_slice
            )
            # 显式更新data_size（如果add_channel未处理）
            new_tf.channels[-1]['data_size'] = len(data_slice) * item_size
            new_tf.channels[-1]['sample_count'] = len(data_slice)
        
        output_trends.append(new_tf)
    return output_trends

def validate_trend_format(file_path):
    """验证趋势数据格式是否符合规范。"""
    from prettytable import PrettyTable

    
    a = TrendFile.read(file_path)
    
    # 将最高采样率的数据的时间作为最精准的时间，进行对比
    max_sr = -1
    max_data_length = -1
    max_sr_device = -1
    max_sr_channel = -1
    
    # 找出最高采样率的通道作为参考
    for each_channel in a.channels:
        data = each_channel["data"]
        sr = each_channel["sample_rate"]
        device_id = each_channel["device_id"]
        channel_id = each_channel["channel_id"]

        if sr > max_sr:
            max_sr = sr
            max_sr_device = device_id
            max_sr_channel = channel_id
            max_data_length = data.shape[0]
    
    # 计算参考通道的时间长度
    reference_time = max_data_length / max_sr if max_sr > 0 else 0
    
    # 创建结果表格
    table = PrettyTable()
    table.field_names = [
        "设备ID", "通道ID", "采样率(Hz)", "数据点数", 
        "持续时间(s)", "最大允许误差(s)", "实际误差(s)", "状态"
    ]
    table.align = "r"  # 右对齐
    table.align["状态"] = "c"  # 状态列居中对齐
    
    # 添加参考通道信息
    table.add_row([
        f"{max_sr_device} (参考)",
        max_sr_channel,
        f"{max_sr:,}",
        f"{max_data_length:,}",
        f"{reference_time:.6f}",
        "N/A",
        "N/A",
        "参考基准"
    ])
    
    # 添加分隔行
    table.add_row(["-"*8, "-"*8, "-"*10, "-"*8, "-"*12, "-"*10, "-"*10, "-"*4])
    
    # 检查所有通道的时间对齐情况
    for each_channel in a.channels:
        data = each_channel["data"]
        sr = each_channel["sample_rate"]
        device_id = each_channel["device_id"]
        channel_id = each_channel["channel_id"]

        # 跳过参考通道
        if device_id == max_sr_device and channel_id == max_sr_channel:
            continue

        if sr == 0:
            # 非时间序列数据
            table.add_row([
                device_id,
                channel_id,
                "0",
                f"{len(data):,}",
                "N/A",
                "N/A", 
                "N/A",
                "非时间序列"
            ])
            continue

        # 计算当前通道的时间信息
        data_length = len(data)
        channel_time = data_length / sr
        max_allowed_error = 1.0 / sr  # 最大允许误差（一个采样间隔）
        actual_error = abs(channel_time - reference_time)
        
        # 判断是否对齐
        if actual_error <= max_allowed_error:
            status = "✅"
        else:
            status = "❌"
        
        table.add_row([
            device_id,
            channel_id,
            f"{sr:,}",
            f"{data_length:,}",
            f"{channel_time:.6f}",
            f"{max_allowed_error:.6f}",
            f"{actual_error:.6f}",
            status
        ])

    print(table)


if __name__ == "__main__":
    
    file_path = "/home/txkj/Code/dcu_escalator/data/H1开梯/2026-01-08_07_08_01.141.trend"

    tf = TrendFile.read(file_path)
    tf.print_summary()
    
    # info = TrendFile.read_assign_channel(filename=file_path, device_id=1, channel_id=1)

    # tf.save_audio_channels_to_wav("./")

    # print(info)
    
    # validate_trend_format(file_path)
    
    
    
    