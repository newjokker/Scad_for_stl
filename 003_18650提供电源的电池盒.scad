
use <lib/simple_box.scad>;
use <lib/corner_clips.scad>;
use <lib/bolt_post.scad>;
use <lib/lid.scad>;
use <lib/TERMINAL_BLOCK.scad>;
use <lib/port.scad>;
include <BOSL2/std.scad>

import("./stls/18650_battery_shell.stl");



// 展示电池电量的指示灯 + 指示灯的开关

// 将电池电压转为 3.3v 的 dcdc 模块

// 使用电池供电的人在传感器模块

// 将人在传感器信息上传到网络的 esp32-c3 模块


TP4056();

LD2401(pos=[30, 0, 0]);

TERMINAL_BLOCK_A(pos=[60, 0, 0]);

DCDC_A(pos=[0, 30, 0]);

BatteryLevelIndicator(pos=[30, 30, 0]);

Battery_18650(pos = [60, 30, 0]);

TERMINAL_BLOCK_C(pos=[0, 60, 0]);

