// 多阶并联环形海姆霍兹管道结构。
// 结构理解：沿管道轴向布置多个环形侧支腔，每个腔体的长度、深度和入口宽度不同。
// 多个不同共振频率并联作用，可形成多峰或较宽的吸声频带。

$fn = 180;

// ---------------- 可调参数 ----------------
// 中心管道半径，单位 mm
duct_radius = 28;             // [10:1:80]
// 单阶环形共振腔数量
order_count = 4;              // [2:1:6]
// 每阶腔体轴向基础长度，单位 mm
cavity_length = 16;           // [8:1:50]
// 相邻腔体之间的隔板厚度，单位 mm
wall_thickness = 1.4;         // [0.8:0.1:5]
// 第一阶腔体径向深度，单位 mm
base_depth = 14;              // [6:1:45]
// 每增加一阶的径向深度增量，单位 mm
depth_step = 4;               // [0:1:16]
// 第一阶入口宽度，单位 mm
base_neck_width = 3.2;        // [1:0.1:12]
// 每增加一阶的入口宽度增量，单位 mm
neck_width_step = 0.8;        // [0:0.1:5]
// 管道两端伸出长度，单位 mm
pipe_extension = 24;          // [0:1:100]

// 显示模式：solid 为完整实体，cutaway 为剖视，print_set 为开口主体与盖板排布
display_mode = "cutaway";     // [solid, cutaway, print_set]
// print_set 模式下主体和盖板间距，单位 mm
print_part_gap = 8;           // [2:1:40]
// 是否显示各阶估算频率
show_frequency = true;
// 频率文字大小
frequency_text_size = 2.5;    // [1:0.1:8]
// 文字浮雕高度
text_emboss_height = 0.4;     // [0.1:0.1:2]
// 声速，单位 m/s
sound_speed = 343;

// ---------------- 派生尺寸 ----------------
stage_pitch = cavity_length + wall_thickness;
body_length = order_count * cavity_length + (order_count + 1) * wall_thickness;
total_length = body_length + 2 * pipe_extension;
z0 = -body_length / 2;
pipe_z0 = -total_length / 2;
max_depth = base_depth + (order_count - 1) * depth_step;
inner_wall_radius = duct_radius + wall_thickness;
outer_radius = inner_wall_radius + max_depth + wall_thickness;

function stage_z0(i) = z0 + wall_thickness + i * stage_pitch;
function stage_z1(i) = stage_z0(i) + cavity_length;
function stage_depth(i) = base_depth + i * depth_step;
function stage_outer_r(i) = inner_wall_radius + stage_depth(i);
function stage_neck_width(i) = base_neck_width + i * neck_width_step;
function stage_volume_mm3(i) = PI * (pow(stage_outer_r(i), 2) - pow(inner_wall_radius, 2)) * cavity_length;
function stage_neck_area_mm2(i) = 2 * PI * duct_radius * stage_neck_width(i);
function stage_freq(i) =
    let(
        v = stage_volume_mm3(i) / 1000000000,
        a = stage_neck_area_mm2(i) / 1000000,
        le = (wall_thickness + 1.7 * stage_neck_width(i)) / 1000
    )
    (sound_speed / (2 * PI)) * sqrt(a / (v * le));

echo("====================");
for (i = [0:order_count - 1])
    echo(str("第 ", i + 1, " 阶频率 = "), round(stage_freq(i) * 10) / 10, "Hz");
echo("====================");

// ---------------- 基础模块 ----------------
module annular_solid(z_start, z_len, r_outer, r_inner) {
    difference() {
        translate([0, 0, z_start])
            cylinder(h = z_len, r = r_outer, center = false);
        translate([0, 0, z_start - 0.5])
            cylinder(h = z_len + 1, r = r_inner, center = false);
    }
}

module all_cavity_voids() {
    for (i = [0:order_count - 1]) {
        difference() {
            translate([0, 0, stage_z0(i)])
                cylinder(h = cavity_length, r = stage_outer_r(i), center = false);
            translate([0, 0, stage_z0(i) - 0.5])
                cylinder(h = cavity_length + 1, r = inner_wall_radius, center = false);
        }

        translate([0, 0, stage_z0(i) + cavity_length / 2 - stage_neck_width(i) / 2])
            cylinder(h = stage_neck_width(i), r = inner_wall_radius + 0.02, center = false);
    }
}

module pipe_shell() {
    annular_solid(pipe_z0, total_length, inner_wall_radius, duct_radius);
}

module body_solid() {
    difference() {
        union() {
            translate([0, 0, z0])
                cylinder(h = body_length, r = outer_radius, center = false);
            pipe_shell();
        }

        translate([0, 0, pipe_z0 - 0.5])
            cylinder(h = total_length + 1, r = duct_radius, center = false);
        all_cavity_voids();
    }
}

module cutaway_cavity_volume() {
    color("Orange", 0.45)
        intersection() {
            all_cavity_voids();
            translate([-outer_radius - 1, -outer_radius - 1, z0 - 1])
                cube([2 * outer_radius + 2, outer_radius + 1, body_length + 2], center = false);
        }
}

module body_cutaway() {
    difference() {
        body_solid();
        translate([-outer_radius - 1, -outer_radius - 1, pipe_z0 - 1])
            cube([2 * outer_radius + 2, outer_radius + 1, total_length + 2], center = false);
    }
}

module printable_body() {
    intersection() {
        body_solid();
        translate([-outer_radius - 1, -outer_radius - 1, pipe_z0 - 1])
            cube([2 * outer_radius + 2, 2 * outer_radius + 2, total_length / 2 + body_length / 2 + 1 - wall_thickness], center = false);
    }
}

module printable_lid() {
    annular_solid(z0, wall_thickness, outer_radius, duct_radius);
}

module printable_set() {
    printable_body();
    translate([2 * outer_radius + print_part_gap, 0, -z0])
        printable_lid();
}

module frequency_text_emboss() {
    freq_text = str(round(stage_freq(0)), "/", round(stage_freq(order_count - 1)), " Hz");
    linear_extrude(height = text_emboss_height, center = false)
        text(text = freq_text, size = frequency_text_size, font = "Arial:style=Bold", halign = "center", valign = "center");
}

module top_label() {
    if (show_frequency)
        translate([0, -outer_radius * 0.58, body_length / 2 + 0.01])
            frequency_text_emboss();
}

module model() {
    if (display_mode == "cutaway") {
        color("Gainsboro") body_cutaway();
        cutaway_cavity_volume();
        color("Black") top_label();
    } else if (display_mode == "print_set") {
        printable_set();
    } else {
        union() {
            body_solid();
            color("Black") top_label();
        }
    }
}

model();
