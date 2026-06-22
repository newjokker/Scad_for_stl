include <BOSL2/std.scad>
use <lib/bolt_post.scad>;
use <lib/lid.scad>;
use <lib/port.scad>;

/*
    激光笔报警装置 - 简单架构版

    这个文件只分 3 层：
    1. 参数区：平时主要改这里。
    2. 零件模块：每个零件怎么长出来。
    3. 装配入口：决定显示哪个零件。

    单位都是 mm。
    坐标方向：X 左负右正，Y 前负后正，Z 向上为正。
*/

view_part = "all";           // ["all","layout","shell","lid","holders","esp32","tp4056","battery"]
$fn = $preview ? 96 : 180;  // 预览时圆弧少一点更快，导出时更圆


// ---------- 外壳 ----------
case_inner = [100, 50, 20]; /* [test] */ 
wall = 2;                   // 侧壁厚度
floor_thickness = 2;        // [0.5:5]
shell_drop = 1;             // 外壳向下沉 1mm，保留原来的底部效果

case_outer = [
    case_inner[0] + wall * 2,
    case_inner[1] + wall * 2,
    case_inner[2] + floor_thickness
];


// ---------- 盖子 ----------
lid_preview_pos = [0, 70, -wall]; // view_part="all" 时，盖子摆在外壳旁边看
lid_size = [case_outer[0], case_outer[1], 2];
lid_plug_thickness = 2.5;
lid_plug_depth = 2.5;
lid_chamfer = 0.5;
lid_hand_direction = "left";      // "left" 或 "right"


// ---------- 螺丝 ----------
screw_type = "m3";                  /* [螺丝] */
screw_hole_d = 2.5;               // 盖子螺丝孔直径

screw_post_positions = [
    [-30, -13, 0],
    [40, 2, 0]
];                                // 外壳里的螺丝柱位置

lid_hole_positions = [
    [-30, 13, 0],
    [40, -2, 0]
];                                // 盖子上的螺丝孔位置


// ---------- 开关 ----------
switch_size = [7.6, 13, 10];      /* [开关] */
switch_holder_pos = [-45.75, -13.6, 0];

switch_side_hole_pos = [-46.75, -13.6, 2.5];
switch_side_hole_size = [case_inner[0], 10.5, 5];

switch_top_hole_pos = [0, -13.6, 4.5];
switch_top_hole_size = [90, 13, 10];


// ---------- ESP32 ----------
esp32_size = [51.5, 21.5, 3];
esp32_pos = [7, 12, 0];
esp32_clip_height = 10;
esp32_clip_open_z = 5;


// ---------- TP4056 ----------
tp4056_size = [27, 17.5, 1];
tp4056_pos = [-35.25, 12, 0];
tp4056_clip_height = 5;
tp4056_clip_open_z = 3;


// ---------- 电池 ----------
battery_size = [70, 19, 10];
battery_pos = [10, -13, 0];


// ---------- 激光头 ----------
laser_mount_size = [18, 12, 16];  // 内部激光头固定块大小
laser_mount_pos = [42, 12, 0];    // 内部激光头固定块位置

laser_mount_hole_d = 8;           // 内部固定块夹激光头的孔径
laser_mount_hole_z = 10;          // 内部固定块孔中心高度
laser_mount_hole_depth = 30;      // 内部固定块孔切割深度

laser_hole_pos = [50, 12, 10];    // 外壳上的激光出光孔中心位置
laser_hole_d = 8;                 // 外壳激光出光孔直径：想让光通过的孔变大/变小就改这里
laser_hole_depth = 50;            // 出光孔切割深度，足够穿透外壳即可


// ---------- Type-C 充电口 ----------
type_c_hole_pos = [-58.25, 12, 5]; // 外壳 Type-C 开孔中心位置
type_c_offset = 0.8;               // Type-C 孔余量，插不进去就加大一点
type_c_depth = 30;


// ==================== 2. 零件模块：一般不用改 ====================

// 通用卡座：用来做 ESP32、TP4056、电池、开关的固定框。
module clip_holder(inner_size, outer_wall = 2, inner_wall = 1.5, height = 10, open_z = 5) {
    difference() {
        cuboid(
            [inner_size[0] + outer_wall * 2, inner_size[1] + outer_wall * 2, height],
            anchor = [0, 0, -1]
        );

        cuboid(
            [inner_size[0] - inner_wall * 2, inner_size[1] - inner_wall * 2, height],
            anchor = [0, 0, -1]
        );

        translate([0, 0, open_z])
            cuboid([inner_size[0], inner_size[1], height], anchor = [0, 0, -1]);
    }
}

// 板子侧边 USB 避让槽。
// direction = -1 从左边切，direction = 1 从右边切。
module usb_clearance(direction = 1, z = 2, width = 9.5) {
    translate([0, 0, z])
        cuboid([100, width, 50], anchor = [direction, 0, -1]);
}

module esp32_holder() {
    difference() {
        clip_holder(esp32_size, outer_wall = 2, inner_wall = 1.5, height = esp32_clip_height, open_z = esp32_clip_open_z);
        usb_clearance(direction = -1, z = 2);
    }
}

module tp4056_holder() {
    difference() {
        clip_holder(tp4056_size, outer_wall = 2, inner_wall = 2, height = tp4056_clip_height, open_z = tp4056_clip_open_z);
        usb_clearance(direction = 1, z = 1.5);
    }
}

module battery_holder() {
    clip_holder(
        [battery_size[0], battery_size[1], 1],
        outer_wall = 2,
        inner_wall = 1,
        height = battery_size[2],
        open_z = 0
    );
}

module switch_holder() {
    clip_holder([switch_size[0], switch_size[1], 1], outer_wall = 2, inner_wall = 2, height = switch_size[2], open_z = 1);
}

module laser_mount() {
    difference() {
        cuboid(laser_mount_size, anchor = [0, 0, -1]);

        translate([0, 0, laser_mount_hole_z])
            rotate([0, 90, 0])
                cylinder(d = laser_mount_hole_d, h = laser_mount_hole_depth, center = true);
    }
}

module screw_posts() {
    for (p = screw_post_positions) {
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

        translate(switch_side_hole_pos)
            cuboid(switch_side_hole_size, anchor = [0, 0, -1]);

        translate(switch_top_hole_pos)
            cuboid(switch_top_hole_size, anchor = [0, 0, -1]);

        translate(laser_hole_pos)
            rotate([0, 90, 0])
                cylinder(d = laser_hole_d, h = laser_hole_depth, center = true);

        translate(type_c_hole_pos)
            rotate([90, 0, 90])
                type_c_hole(offset = type_c_offset, depth = type_c_depth, pos = [0, 0, 0]);
    }

    screw_posts();
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

            for (p = lid_hole_positions) {
                translate(p)
                    cylinder(d = screw_hole_d, h = 20);
            }
        }
}

module internal_holders() {
    translate(esp32_pos)
        esp32_holder();

    translate(tp4056_pos)
        tp4056_holder();

    translate(battery_pos)
        battery_holder();

    translate(laser_mount_pos)
        laser_mount();
}

// layout 模式里的透明参考块，用来确认真实电子件的大概占位。
module reference_layout() {
    %translate(esp32_pos)
        cuboid(esp32_size, anchor = [0, 0, -1]);

    %translate(tp4056_pos)
        cuboid(tp4056_size, anchor = [0, 0, -1]);

    %translate(battery_pos)
        cuboid(battery_size, anchor = [0, 0, -1]);

    %translate(switch_holder_pos)
        cuboid(switch_size, anchor = [0, 0, -1]);

    %translate(laser_hole_pos)
        rotate([0, 90, 0])
            cylinder(d = laser_hole_d, h = laser_hole_depth, center = true);
}


// ==================== 3. 装配入口：决定显示什么 ====================

module assembly() {
    if (view_part == "shell") {
        shell_body();
    } else if (view_part == "lid") {
        top_lid();
    } else if (view_part == "holders") {
        internal_holders();
    } else if (view_part == "esp32") {
        esp32_holder();
    } else if (view_part == "tp4056") {
        tp4056_holder();
    } else if (view_part == "battery") {
        battery_holder();
    } else if (view_part == "layout") {
        shell_body();
        top_lid(lid_preview_pos);
        internal_holders();
        reference_layout();
    } else {
        shell_body();
        top_lid(lid_preview_pos);
        internal_holders();
    }
}

assembly();
