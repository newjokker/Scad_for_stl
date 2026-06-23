#! /bin/bash/env python
# -*- coding: utf-8 -*-
# ===== compiler flag =====
# distutils: language = c++
# cython: language_level = 3
# ===== compiler flag =====
import numpy as np
import matplotlib.pyplot as plt


def naca_thickness(x, t):
    """
    NACA 四位数字翼型的半厚度分布。
    t: 最大相对厚度 (例如 0.12 对应 12% 弦长)
    """
    # 标准系数，尾缘闭合采用 -0.1036 使 y(1)=0 更精确
    a0, a1, a2, a3, a4 = 0.2969, -0.1260, -0.3516, 0.2843, -0.1036
    yt = 5 * t * (a0 * np.sqrt(x) + a1 * x + a2 * x ** 2 + a3 * x ** 3 + a4 * x ** 4)
    return yt


def camber_line(x, m, p):
    """
    抛物线型中弧线（NACA 四位数字弯度定义）。
    m: 最大弯度 (占弦长比例)
    p: 最大弯度位置 (占弦长比例)
    返回: y_c, dy_c/dx (用于垂直叠加厚度时的角度修正)
    """
    yc = np.zeros_like(x)
    dyc = np.zeros_like(x)
    # 前段 (0 <= x <= p)
    mask1 = x <= p
    yc[mask1] = m / p ** 2 * (2 * p * x[mask1] - x[mask1] ** 2)
    dyc[mask1] = 2 * m / p ** 2 * (p - x[mask1])
    # 后段 (p < x <= 1)
    mask2 = x > p
    yc[mask2] = m / (1 - p) ** 2 * ((1 - 2 * p) + 2 * p * x[mask2] - x[mask2] ** 2)
    dyc[mask2] = 2 * m / (1 - p) ** 2 * (p - x[mask2])
    return yc, dyc


def centrifugal_blade_airfoil(m=0.06, p=0.4, t=0.12, num_points=200):
    """
    生成带弯度的离心风机叶片翼型坐标。
    参数:
        m : 最大相对弯度
        p : 最大弯度位置
        t : 最大相对厚度
        num_points : 沿弦向点数
    返回:
        x_up, y_up : 上表面 (吸力面)
        x_low, y_low : 下表面 (压力面)
        x_c, y_c : 中弧线
    """
    # 弦向位置（包含前缘和尾缘点）
    x = np.linspace(0, 1, num_points)

    # 计算中弧线及其斜率
    yc, dyc = camber_line(x, m, p)

    # 计算半厚度
    yt = naca_thickness(x, t)

    # 厚度方向垂直于中弧线（严格做法），这里用斜率近似垂直
    theta = np.arctan(dyc)  # 中弧线切线与 x 轴夹角
    cos_th = np.cos(theta)
    sin_th = np.sin(theta)

    # 上表面坐标：从中弧线沿法向向外（厚度垂直于中弧线）
    x_up = x - yt * sin_th
    y_up = yc + yt * cos_th

    # 下表面坐标
    x_low = x + yt * sin_th
    y_low = yc - yt * cos_th

    # 中弧线
    x_c, y_c = x, yc

    # 为了绘制封闭图形，将下表面逆序连接
    return x_up, y_up, x_low[::-1], y_low[::-1], x_c, y_c


def plot_centrifugal_blade(m, p, t, show_camber=True):
    """
    绘制离心风机叶片翼型。
    """
    x_up, y_up, x_low, y_low, x_c, y_c = centrifugal_blade_airfoil(m, p, t)

    fig, ax = plt.subplots(figsize=(10, 4))

    # 填充翼型内部
    ax.fill(np.concatenate([x_up, x_low]),
            np.concatenate([y_up, y_low]),
            color='lightgray', edgecolor='black', linewidth=1.5,
            label=f'Blade profile (m={m:.0%}, p={p:.0%}, t={t:.0%})')

    if show_camber:
        ax.plot(x_c, y_c, '--', color='blue', linewidth=1.2, label='Camber line')

    # 标注最大厚度、最大弯度位置
    max_camber_pos = p
    max_thick_pos = 0.3  # NACA 厚度最大在 30% 弦长
    ax.plot(max_camber_pos, m, 'ro', markersize=5, label=f'Max camber @ x={p:.0%}')
    ax.plot(max_thick_pos, y_c[np.argmin(np.abs(x_c - max_thick_pos))],
            'gs', markersize=5, label=f'Max thickness @ x=30%')

    ax.set_title('Centrifugal Fan Blade Profile (NACA Thickness + Camber)', fontsize=14)
    ax.set_xlabel('Chordwise coordinate, x/c', fontsize=12)
    ax.set_ylabel('Normal coordinate, y/c', fontsize=12)
    ax.grid(True, linestyle='--', alpha=0.6)
    ax.axis('equal')
    ax.legend(loc='upper left')
    plt.tight_layout()
    plt.show()


def compare_with_symmetric(m, p, t):
    """
    将带弯度翼型与原始对称翼型对比。
    """
    # 生成带弯度翼型
    x_up, y_up, x_low, y_low, x_c, y_c = centrifugal_blade_airfoil(m, p, t)
    # 生成对称翼型（相同厚度）
    from scipy.interpolate import interp1d
    x_sym = np.linspace(0, 1, 200)
    yt_sym = naca_thickness(x_sym, t)
    # 对称翼型中弧线为 y=0
    x_sym_up, y_sym_up = x_sym, yt_sym
    x_sym_low, y_sym_low = x_sym[::-1], -yt_sym[::-1]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # 左图：对称翼型
    ax1.fill(np.concatenate([x_sym_up, x_sym_low]),
             np.concatenate([y_sym_up, y_sym_low]),
             color='lightblue', edgecolor='navy', linewidth=1.5)
    ax1.set_title(f'Symmetric NACA 00{int(t * 100):02d} (for reference)')
    ax1.set_xlabel('x/c')
    ax1.set_ylabel('y/c')
    ax1.grid(True, alpha=0.5)
    ax1.axis('equal')

    # 右图：带弯度翼型
    ax2.fill(np.concatenate([x_up, x_low]),
             np.concatenate([y_up, y_low]),
             color='lightcoral', edgecolor='darkred', linewidth=1.5)
    ax2.plot(x_c, y_c, '--', color='black', linewidth=1)
    ax2.set_title(f'Cambered Blade (m={m:.0%}, p={p:.0%}, t={t:.0%})')
    ax2.set_xlabel('x/c')
    ax2.set_ylabel('y/c')
    ax2.grid(True, alpha=0.5)
    ax2.axis('equal')

    plt.tight_layout()
    plt.show()


if __name__ == "__main__":
    # 示例：m标识弯度，p表示最大弯度位置，t表示厚度 12%
    plot_centrifugal_blade(m=0.06, p=0.4, t=0.12, show_camber=True)

    # 对比展示
    # compare_with_symmetric(m=0.06, p=0.4, t=0.12)