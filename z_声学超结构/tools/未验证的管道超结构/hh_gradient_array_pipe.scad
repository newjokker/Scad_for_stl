// 周向梯度多阶海姆霍兹阵列管道。
// 结构理解：管道周向布置多个侧支腔，腔体深度和颈管半径按角度渐变。
// 每个单元对应不同共振频率，组合后形成宽频带响应。

$fn = 160;

// ---------------- 可调参数 ----------------
// 中心管道半径，单位 mm
duct_radius = 32;             // [12:1:80]
// 周向单元数量
unit_count = 20;              // [8:1:48]
// 腔体轴向长度，单位 mm
cavity_length = 26;           // [8:1:90]
// 最小腔体径向深度，单位 mm
min_depth = 8;                // [5:1:40]
// 最大腔体径向深度，单位 mm
max_depth = 40;               // [8:1:70]
// 最小颈管半径，单位 mm
min_neck_radius = 1.6;        // [0.6:0.1:6]
// 最大颈管半径，单位 mm
max_neck_radius = 2.4;        // [0.8:0.1:10]
// 颈管径向长度，单位 mm
neck_length = 6;              // [2:0.5:25]
// 壁厚，单位 mm
wall_thickness = 1.4;         // [0.8:0.1:5]
// 管道两端伸出长度，单位 mm
pipe_extension = 20;          // [0:1:100]

// 显示模式：solid 为完整实体，cutaway 为剖视，print_set 为开口主体与盖板排布
display_mode = "cutaway";     // [solid, cutaway, print_set]
// print_set 模式下主体和盖板间距，单位 mm
print_part_gap = 8;           // [2:1:40]
// 是否显示频率范围
show_frequency = true;
// 频率文字大小
frequency_text_size = 2.8;    // [1:0.1:8]
// 文字浮雕高度
text_emboss_height = 0.4;     // [0.1:0.1:2]
// 声速，单位 m/s
sound_speed = 343;

// ---------------- 派生尺寸 ----------------
cell_angle = 360 / unit_count;
partition_angle = 2 * asin(min(0.95, wall_thickness / (2 * (duct_radius + wall_thickness + neck_length))));
cavity_angle = max(0.1, cell_angle - partition_angle);
inner_radius = duct_radius + wall_thickness + neck_length;
outer_radius = inner_radius + max_depth + wall_thickness;
body_length = cavity_length + 2 * wall_thickness;
total_length = body_length + 2 * pipe_extension;
z0 = -body_length / 2;
pipe_z0 = -total_length / 2;
neck_overlap = max(1.5 * max_neck_radius, wall_thickness + 0.5);

function t_unit(i) = unit_count <= 1 ? 0 : i / (unit_count - 1);
function unit_depth(i) = min_depth + (max_depth - min_depth) * t_unit(i);
function unit_neck_radius(i) = min_neck_radius + (max_neck_radius - min_neck_radius) * t_unit(i);
function unit_angle(i) = i * cell_angle;
function sector_area(inner_r, outer_r, angle) = PI * (pow(outer_r, 2) - pow(inner_r, 2)) * angle / 360;
function unit_volume_mm3(i) = sector_area(inner_radius, inner_radius + unit_depth(i), cavity_angle) * cavity_length;
function unit_freq(i) =
    let(
        v = unit_volume_mm3(i) / 1000000000,
        a = PI * pow(unit_neck_radius(i), 2) / 1000000,
        le = (neck_length + 1.7 * unit_neck_radius(i)) / 1000
    )
    (sound_speed / (2 * PI)) * sqrt(a / (v * le));

echo("====================");
echo("频率范围低端 =", round(min(unit_freq(0), unit_freq(unit_count - 1)) * 10) / 10, "Hz");
echo("频率范围高端 =", round(max(unit_freq(0), unit_freq(unit_count - 1)) * 10) / 10, "Hz");
echo("====================");

function polar_point(r, a) = [r * cos(a), r * sin(a)];
function arc_points(r, a0, a1, n) = [for (i = [0:n]) polar_point(r, a0 + (a1 - a0) * i / n)];
function reverse_arc_points(r, a0, a1, n) = [for (i = [0:n]) polar_point(r, a1 - (a1 - a0) * i / n)];

module annular_sector_2d(inner_r, outer_r, center_angle, span_angle, steps = 8) {
    a0 = center_angle - span_angle / 2;
    a1 = center_angle + span_angle / 2;
    polygon(points = concat(
        arc_points(outer_r, a0, a1, steps),
        reverse_arc_points(inner_r, a0, a1, steps)
    ));
}

module cavity_void(i) {
    translate([0, 0, z0 + wall_thickness])
        linear_extrude(height = cavity_length, convexity = 8)
            annular_sector_2d(inner_radius, inner_radius + unit_depth(i), unit_angle(i), cavity_angle, max(4, ceil(cavity_angle / 4)));
}

module neck_void(i) {
    rotate([0, 0, unit_angle(i)])
        translate([duct_radius - neck_overlap, 0, 0])
            rotate([0, 90, 0])
                cylinder(h = neck_length + wall_thickness + neck_overlap + 0.2, r = unit_neck_radius(i), center = false);
}

module all_voids() {
    for (i = [0:unit_count - 1]) {
        cavity_void(i);
        neck_void(i);
    }
}

module annular_solid(z_start, z_len, r_outer, r_inner) {
    difference() {
        translate([0, 0, z_start])
            cylinder(h = z_len, r = r_outer, center = false);
        translate([0, 0, z_start - 0.5])
            cylinder(h = z_len + 1, r = r_inner, center = false);
    }
}

module body_solid() {
    difference() {
        union() {
            translate([0, 0, z0])
                cylinder(h = body_length, r = outer_radius, center = false);
            annular_solid(pipe_z0, total_length, duct_radius + wall_thickness, duct_radius);
        }

        translate([0, 0, pipe_z0 - 0.5])
            cylinder(h = total_length + 1, r = duct_radius, center = false);
        all_voids();
    }
}

module body_cutaway() {
    difference() {
        body_solid();
        translate([-outer_radius - 1, -outer_radius - 1, pipe_z0 - 1])
            cube([2 * outer_radius + 2, outer_radius + 1, total_length + 2], center = false);
    }
}

module cutaway_volume() {
    color("DarkOrange", 0.45)
        intersection() {
            all_voids();
            translate([-outer_radius - 1, -outer_radius - 1, z0 - 1])
                cube([2 * outer_radius + 2, outer_radius + 1, body_length + 2], center = false);
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
    f_hi = max(unit_freq(0), unit_freq(unit_count - 1));
    f_lo = min(unit_freq(0), unit_freq(unit_count - 1));
    freq_text = str(round(f_lo), "-", round(f_hi), " Hz");
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
        cutaway_volume();
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
