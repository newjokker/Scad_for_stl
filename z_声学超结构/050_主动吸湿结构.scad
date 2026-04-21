include <BOSL2/std.scad>

$fn = 200;


// ==========================
// 参数区
// ==========================

// ---- 顶部开口 ----
top_open_x = 120;
top_open_y = 120;

// ---- 外壳 ----
wall = 3;
outer_x = top_open_x + wall * 2;
outer_y = top_open_y + wall * 2;

// ---- 高度 ----
top_plenum_h   = 25;   // 顶部扩压腔
tray_count     = 4;    // 托盘层数
tray_gap       = 24;   // 托盘间距
tray_thickness = 2.4;  // 托盘厚度
bottom_sump_h  = 35;   // 底部集液仓高度
bottom_thick   = 3;    // 底板厚度

total_h = bottom_thick + bottom_sump_h + tray_count * tray_gap + top_plenum_h + 10;

// ---- 托盘参数 ----
tray_margin = 6;       // 托盘距侧壁边距
tray_frame_w = 4;      // 托盘边框宽度
slot_w = 5;            // 条孔宽度
slot_l = 28;           // 条孔长度
slot_pitch = 12;       // 条孔间距

// ---- 导流帽 ----
cap_size = 40;
cap_h = 14;

// ---- 排风孔 ----
vent_w = 8;
vent_h = 18;
vent_pitch = 14;
vent_rows = 2;

// ---- 风扇安装 ----
fan_hole_spacing = 105;    // 常见120风扇孔距
fan_screw_d = 4.5;


// ==========================
// 基础模块
// ==========================

// 外壳
module shell_box() {
    difference() {
        cuboid([outer_x, outer_y, total_h], anchor=BOTTOM);

        // 内腔
        translate([0, 0, bottom_thick])
            cuboid([top_open_x, top_open_y, total_h], anchor=BOTTOM);

        // 顶部完全打开
        translate([0, 0, total_h - 1])
            cuboid([top_open_x + 0.5, top_open_y + 0.5, 5], anchor=BOTTOM);
    }
}

// 风扇安装顶板（可选）
module fan_plate() {
    plate_t = 3;

    difference() {
        translate([0, 0, total_h])
            cuboid([outer_x, outer_y, plate_t], anchor=BOTTOM);

        // 中间进风口
        translate([0, 0, total_h - 0.1])
            cuboid([100, 100, plate_t + 0.2], anchor=BOTTOM);

        // 4个风扇安装孔
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx * fan_hole_spacing/2, sy * fan_hole_spacing/2, total_h - 0.1])
                cyl(d=fan_screw_d, h=plate_t + 0.2, anchor=BOTTOM);
        }
    }
}

// 顶部导流帽，避免中间气流直冲到底
module center_deflector() {
    z0 = total_h - top_plenum_h - cap_h - 2;

    translate([0, 0, z0])
    hull() {
        translate([0, 0, 0])
            cuboid([cap_size, cap_size, 2], anchor=BOTTOM);
        translate([0, 0, cap_h])
            cuboid([cap_size * 0.45, cap_size * 0.45, 2], anchor=BOTTOM);
    }
}

// 十字导流片
module plenum_cross_vanes() {
    z0 = total_h - top_plenum_h + 2;
    vane_t = 2;
    vane_h = top_plenum_h - 8;
    vane_len = 90;

    translate([0, 0, z0])
    union() {
        cuboid([vane_len, vane_t, vane_h], anchor=BOTTOM);
        cuboid([vane_t, vane_len, vane_h], anchor=BOTTOM);
    }
}


// ==========================
// 托盘模块
// 3种开孔模式轮换
// ==========================

module slot_array(area_x, area_y, mode=0) {
    // mode 0: 中间带状开孔
    // mode 1: 两侧开孔，中间保留
    // mode 2: 棋盘偏移区开孔

    if (mode == 0) {
        for (x = [-area_x/2 + slot_l/2 : slot_pitch : area_x/2 - slot_l/2]) {
            for (y = [-18 : 12 : 18]) {
                translate([x, y, 0])
                    cuboid([slot_l, slot_w, 5], anchor=CENTER);
            }
        }
    }

    if (mode == 1) {
        for (band_y = [-28, 28]) {
            for (x = [-area_x/2 + slot_l/2 : slot_pitch : area_x/2 - slot_l/2]) {
                for (y = [band_y - 8 : 12 : band_y + 8]) {
                    translate([x, y, 0])
                        cuboid([slot_l, slot_w, 5], anchor=CENTER);
                }
            }
        }
    }

    if (mode == 2) {
        for (x = [-area_x/2 + 12 : 18 : area_x/2 - 12]) {
            for (y = [-area_y/2 + 12 : 18 : area_y/2 - 12]) {
                if ((floor((x+100)/18) + floor((y+100)/18)) % 2 == 0)
                    translate([x, y, 0])
                        cuboid([12, 12, 5], anchor=CENTER);
            }
        }
    }
}

// 单层托盘
module tray_layer(z=0, mode=0) {
    tray_x = top_open_x - 2 * tray_margin;
    tray_y = top_open_y - 2 * tray_margin;

    difference() {
        translate([0, 0, z])
            cuboid([tray_x, tray_y, tray_thickness], anchor=BOTTOM);

        // 挖掉中间，只留边框与开孔承载区
        translate([0, 0, z - 0.1])
            cuboid([tray_x - 2*tray_frame_w, tray_y - 2*tray_frame_w, tray_thickness + 0.2], anchor=BOTTOM);

        // 在内区里重新做开孔板
        translate([0, 0, z + tray_thickness/2])
            slot_array(tray_x - 2*tray_frame_w, tray_y - 2*tray_frame_w, mode);
    }

    // 再补一层真正的薄板框架，避免上面 difference 后变成空框
    difference() {
        translate([0, 0, z])
            cuboid([tray_x - 2*tray_frame_w, tray_y - 2*tray_frame_w, tray_thickness], anchor=BOTTOM);

        translate([0, 0, z + tray_thickness/2])
            slot_array(tray_x - 2*tray_frame_w, tray_y - 2*tray_frame_w, mode);
    }

    // 简单导流筋
    rib_h = 6;
    rib_t = 2;
    for (yy = [-25, 0, 25]) {
        translate([0, yy, z - rib_h])
            cuboid([tray_x - 10, rib_t, rib_h], anchor=BOTTOM);
    }
}


// ==========================
// 底部漏液隔板
// ==========================
module drain_plate() {
    z0 = bottom_thick + bottom_sump_h;

    difference() {
        translate([0, 0, z0])
            cuboid([top_open_x - 8, top_open_y - 8, 2.4], anchor=BOTTOM);

        // 漏液孔
        for (x = [-45 : 15 : 45]) {
            for (y = [-45 : 15 : 45]) {
                translate([x, y, z0 - 0.1])
                    cyl(d=5, h=3, anchor=BOTTOM);
            }
        }
    }
}


// ==========================
// 侧下方排风孔
// ==========================
module side_vents_cut() {
    z_base = bottom_thick + 8;

    // 四个侧面都开一点
    for (row = [0 : vent_rows-1]) {
        zc = z_base + row * (vent_h + 6);

        // X 正负面
        for (xsign = [-1, 1]) {
            for (yy = [-42 : vent_pitch : 42]) {
                translate([xsign * outer_x/2, yy, zc])
                    rotate([0, 90, 0])
                        cuboid([wall + 1, vent_w, vent_h], anchor=CENTER);
            }
        }

        // Y 正负面
        for (ysign = [-1, 1]) {
            for (xx = [-42 : vent_pitch : 42]) {
                translate([xx, ysign * outer_y/2, zc])
                    rotate([90, 0, 0])
                        cuboid([vent_w, wall + 1, vent_h], anchor=CENTER);
            }
        }
    }
}


// ==========================
// 总装
// ==========================
difference() {
    union() {
        shell_box();
        fan_plate();
        center_deflector();
        plenum_cross_vanes();
        drain_plate();

        // 多层托盘
        for (i = [0 : tray_count-1]) {
            zt = bottom_thick + bottom_sump_h + 8 + i * tray_gap;
            tray_layer(z=zt, mode=i % 3);
        }
    }

    side_vents_cut();
}