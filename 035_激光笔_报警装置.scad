include <BOSL2/std.scad>
use <lib/bolt_post.scad>;
use <lib/lid.scad>;
use <lib/port.scad>;

/*
    激光笔报警装置

    修改方法：
    1. 优先改下面的“参数区”，不要到各个模块里找数字。
    2. 只想看某个零件时，改 view_part：
       "all" / "layout" / "shell" / "lid" / "holders" / "esp32" / "tp4056" / "battery"
    3. 下面所有尺寸单位都是 mm。
    4. 坐标说明：
       X 方向：左负右正；Y 方向：前负后正；Z 方向：向上为正。
*/

view_part = "all";              // 当前显示内容；调试位置时推荐先改成 "layout"
$fn = $preview ? 96 : 180;      // 圆弧精度；预览低一点更快，导出时更圆滑

// ===== 外壳参数 =====
case_inner = [100, 50, 20];     // 外壳内部可用空间：[长, 宽, 高]
wall = 2;                       // 外壳侧壁厚度
floor_thickness = wall;         // 外壳底板厚度，默认和侧壁一样厚
shell_drop = 1;                 // 外壳整体向下沉一点，保留你原来的底部结构
case_outer = [
    case_inner[0] + wall * 2,
    case_inner[1] + wall * 2,
    case_inner[2] + floor_thickness
];
case_left_x = -case_inner[0] / 2;    // 内腔左侧 X 坐标，用来派生孔位
case_right_x = case_inner[0] / 2;    // 内腔右侧 X 坐标，激光出光孔在这一侧
case_front_y = -case_inner[1] / 2;   // 内腔前侧 Y 坐标，开关靠这一侧

// ===== 盖子参数 =====
lid_gap_y = 70;                 // 盖子摆在外壳旁边预览，方便一起导出/检查
lid_size = [case_outer[0], case_outer[1], 2];  // 盖子外形尺寸，默认跟外壳外尺寸一致
lid_plug_thickness = 2.5;       // 盖子插入外壳的内塞壁厚
lid_plug_depth = 2.5;           // 盖子内塞伸入外壳的深度
lid_chamfer = 0.5;              // 盖子倒角大小
lid_hand_direction = "left";    // 盖子把手方向："left" 或 "right"

// ===== 螺丝柱和盖子螺丝孔 =====
screw_type = "m3";              // 螺丝规格，传给 lib/bolt_post.scad 的 boss()
screw_hole_d = 2.5;             // 盖子上的螺丝孔直径
screw_positions = [
    [-30, -13, 0],
    [40, 2, 0]
];                              // 外壳内部螺丝柱位置
lid_screw_hole_positions = [
    [-30, 13, 0],
    [40, -2, 0]
];                              // 盖子上的孔位；盖子单独摆放/翻面时可和螺丝柱位置不同

// ===== 开关 =====
switch_size = [7.6, 13, 10];    // 开关安装座内部尺寸：[长, 宽, 高]
switch_y = case_front_y + 12.8 / 2 + 5;       // 开关中心离前侧内壁的位置
switch_holder_x = case_left_x + 6.5 / 2 + 1;  // 开关安装座中心 X 坐标
switch_side_cut_x = case_left_x + 6.5 / 2;    // 开关侧面开孔中心 X 坐标
switch_holder_pos = [
    switch_holder_x,
    switch_y,
    0
];
switch_side_cut_pos = [
    switch_side_cut_x,
    switch_y,
    2.5
];
switch_top_cut_pos = [0, switch_y, 4.5];

// ===== 内部部件尺寸和位置 =====
esp32_size = [51.5, 21.5, 3];   // ESP32-C3 板子参考尺寸
tp4056_size = [27, 17.5, 1];    // TP4056 充电板参考尺寸
battery_size = [70, 19, 10];    // 电池座参考尺寸

parts_origin = [15, 10, 0];     // 内部部件整体基准点；想整体搬动内部布局可以改这里
esp32_pos = parts_origin + [-8, 2, 0];        // ESP32 安装座中心位置
laser_mount_offset = [35, 0, 0];              // 激光头固定块相对 ESP32 安装座的位置
laser_mount_pos = esp32_pos + laser_mount_offset;
tp4056_gap_to_esp32 = 11;       // TP4056 和 ESP32 两块板之间的 X 方向间距
tp4056_pos = [
    esp32_pos[0] - esp32_size[0] / 2 - tp4056_size[0] / 2 - tp4056_gap_to_esp32 + 8,
    parts_origin[1] + 2,
    0
];                              // TP4056 位置由 ESP32 位置和间距推导，避免手算坐标
battery_pos = parts_origin + [-5, -23, 0];    // 电池座中心位置

laser_mount_size = [18, 12, 16]; // 内部激光头固定块外形尺寸
laser_mount_hole_d = 8;        // 内部固定块里夹激光头的孔径，不是外壳出光孔
laser_mount_hole_z = 10;         // 固定块孔中心高度
laser_mount_hole_depth = 30;     // 固定块孔的切割深度

// ===== 外部接口开孔 =====
laser_hole_pos = [case_right_x, 12, 10]; // 外壳激光出光孔中心位置
laser_hole_d = 8;                        // 外壳激光出光孔直径；想让激光通过的孔变大/变小就改这里
laser_hole_depth = 50;                   // 出光孔切穿外壳的深度，通常不用改，只要足够穿透外壳即可

tp4056_usb_to_case_hole = 9.5;   // Type-C 外壳开孔相对 TP4056 板边的距离
type_c_shell_z = 5;              // Type-C 外壳开孔中心高度
type_c_shell_pos = [
    tp4056_pos[0] - tp4056_size[0] / 2 - tp4056_usb_to_case_hole,
    tp4056_pos[1],
    type_c_shell_z
];                              // Type-C 开孔位置跟着 TP4056 位置自动计算
type_c_offset = 0.8;             // Type-C 孔的装配余量，插不进去就加大一点
type_c_depth = 30;               // Type-C 孔切割深度，通常保持能穿透外壳即可


// ===== 通用小模块 =====
// 做一个“外框 + 中间掏空 + 上方避让”的板子卡座。
// inner_size 是要放进去的板子/部件尺寸；wall_out 控制外圈厚度；pocket_z 控制从多高开始挖开。
module board_clip(inner_size, wall_out = 2, wall_in = 1.5, height = 10, pocket_z = 5) {
    difference() {
        cuboid(
            [inner_size[0] + wall_out * 2, inner_size[1] + wall_out * 2, height],
            anchor = [0, 0, -1]
        );

        cuboid(
            [inner_size[0] - wall_in * 2, inner_size[1] - wall_in * 2, height],
            anchor = [0, 0, -1]
        );

        translate([0, 0, pocket_z])
            cuboid([inner_size[0], inner_size[1], height], anchor = [0, 0, -1]);
    }
}

// 给板子 USB 口留一条侧向避让槽。
// direction = -1 表示从左侧切，direction = 1 表示从右侧切。
module usb_side_cut(direction = 1, z = 2, width = 9.5) {
    translate([0, 0, z])
        cuboid([100, width, 50], anchor = [direction, 0, -1]);
}

// ESP32 安装座：板子坐在卡座里，侧边给 USB 口留出避让空间。
module esp32_holder() {
    difference() {
        board_clip(esp32_size, wall_out = 2, wall_in = 1.5, height = 10, pocket_z = 5);
        usb_side_cut(direction = -1, z = 2);
    }
}

// TP4056 安装座：比 ESP32 座更矮，右侧留 USB/Type-C 位置。
module tp4056_holder() {
    difference() {
        board_clip(tp4056_size, wall_out = 2, wall_in = 2, height = 5, pocket_z = 3);
        usb_side_cut(direction = 1, z = 1.5);
    }
}

// 电池座：用同一个 board_clip 结构，只是把口袋从底部开始打开。
module battery_holder() {
    board_clip(
        [battery_size[0], battery_size[1], 1],
        wall_out = 2,
        wall_in = 1,
        height = battery_size[2],
        pocket_z = 0
    );
}

// 开关座：安装在外壳前侧，同时外壳上会再切出开关拨动/伸出的避让孔。
module switch_holder() {
    board_clip([switch_size[0], switch_size[1], 1], wall_out = 2, wall_in = 2, height = switch_size[2], pocket_z = 1);
}

// 内部激光头固定块：laser_mount_hole_d 控制这里夹住激光头的孔径。
module laser_head_mount() {
    difference() {
        cuboid(laser_mount_size, anchor = [0, 0, -1]);

        translate([0, 0, laser_mount_hole_z])
            rotate([0, 90, 0])
                cylinder(d = laser_mount_hole_d, h = laser_mount_hole_depth, center = true);
    }
}

// 外壳内部螺丝柱。位置由 screw_positions 控制。
module screw_bosses() {
    for (p = screw_positions) {
        boss(
            screw = screw_type,
            mode = "self_tap",
            height = case_inner[2] - 3,
            rib_height = 10,
            rib_thickness = 1,
            thick = 2,
            pos = p
        );
    }
}

// 只在 layout 模式下作为透明参考体显示，帮助确认真实电子件大概占位。
module part_reference(size, pos) {
    %translate(pos)
        cuboid(size, anchor = [0, 0, -1]);
}

// layout 模式下显示 ESP32、TP4056、电池、开关和激光出光孔的参考位置。
module layout_reference_parts() {
    part_reference(esp32_size, esp32_pos);
    part_reference(tp4056_size, tp4056_pos);
    part_reference(battery_size, battery_pos);
    part_reference(switch_size, switch_holder_pos);

    %translate(laser_hole_pos)
        rotate([0, 90, 0])
            cylinder(d = laser_hole_d, h = laser_hole_depth, center = true);
}


// ===== 外壳和盖子 =====
// 外壳主体：先做空盒子，再切开关孔、激光出光孔、Type-C 孔，最后加螺丝柱。
module shell_body() {
    difference() {
        union() {
            translate([0, 0, -shell_drop])
                difference() {
                    cuboid(case_outer, anchor = [0, 0, -1]);

                    translate([0, 0, floor_thickness + 0.01])
                        cuboid(case_inner, anchor = [0, 0, -1]);
                }

            translate(switch_holder_pos)
                switch_holder();
        }

        // 开关侧面开口
        translate(switch_side_cut_pos)
            cuboid([case_inner[0], 10.5, 5], anchor = [0, 0, -1]);

        // 开关上方避让
        translate(switch_top_cut_pos)
            cuboid([90, 13, 10], anchor = [0, 0, -1]);

        // 激光头出光孔
        translate(laser_hole_pos)
            rotate([0, 90, 0])
                cylinder(d = laser_hole_d, h = laser_hole_depth, center = true);

        // TP4056 Type-C 充电口
        translate(type_c_shell_pos)
            rotate([90, 0, 90])
                type_c_hole(offset = type_c_offset, depth = type_c_depth, pos = [0, 0, 0]);
    }

    screw_bosses();
}

module top_lid(pos = [0, 0, 0]) {
    translate(pos)
        difference() {
            lid(
                lid_size = lid_size,
                plug_thickness = lid_plug_thickness,
                plug_depth = lid_plug_depth,
                wall_thickness = wall,
                chamfer = lid_chamfer,
                hand_direction = lid_hand_direction,
                pos = [0, 0, 0]
            );

            for (p = lid_screw_hole_positions) {
                translate([p[0], p[1], 0])
                    cylinder(d = screw_hole_d, h = 20);
            }
        }
}


// ===== 内部安装件 =====
// 所有内部安装座的装配位置；一般调顶部的 esp32_pos / tp4056_pos / battery_pos 即可。
module internal_holders() {
    translate(esp32_pos) {
        esp32_holder();
        translate(laser_mount_pos - esp32_pos)
            laser_head_mount();
    }

    translate(tp4056_pos)
        tp4056_holder();

    translate(battery_pos)
        battery_holder();
}

// 总入口。view_part 决定显示整机、布局参考，还是单独零件。
module assembly() {
    if (view_part == "shell") {
        shell_body();
    } else if (view_part == "lid") {
        top_lid();
    } else if (view_part == "layout") {
        shell_body();
        top_lid([0, lid_gap_y, -wall]);
        internal_holders();
        layout_reference_parts();
    } else if (view_part == "holders") {
        internal_holders();
    } else if (view_part == "esp32") {
        esp32_holder();
    } else if (view_part == "tp4056") {
        tp4056_holder();
    } else if (view_part == "battery") {
        battery_holder();
    } else {
        shell_body();
        top_lid([0, lid_gap_y, -wall]);
        internal_holders();
    }
}

assembly();
