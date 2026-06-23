// 多层嵌套环形海姆霍兹管道结构。
// 结构理解：同一段中心管外侧套叠多个环形腔，不同半径层通过不同位置的入口连通管道。
// 多层腔体共享轴向长度，适合在较短管段内实现多个共振阶次。

$fn = 180;

// ---------------- 可调参数 ----------------
// 中心管道半径，单位 mm
duct_radius = 28;             // [10:1:80]
// 嵌套腔体层数
layer_count = 4;              // [2:1:7]
// 壳体轴向长度，单位 mm
body_length = 56;             // [24:1:140]
// 单层腔体径向宽度，单位 mm
channel_width = 5.5;          // [2:0.1:16]
// 壁厚，单位 mm
wall_thickness = 1.4;         // [0.8:0.1:5]
// 每层入口轴向宽度，单位 mm
neck_width = 3.2;             // [1:0.1:12]
// 管道两端伸出长度，单位 mm
pipe_extension = 24;          // [0:1:100]

// 显示模式：solid 为完整实体，cutaway 为剖视，print_set 为开口主体与盖板排布
display_mode = "cutaway";     // [solid, cutaway, print_set]
// print_set 模式下主体和盖板间距，单位 mm
print_part_gap = 8;           // [2:1:40]
// 是否显示估算频率范围
show_frequency = true;
// 频率文字大小
frequency_text_size = 2.6;    // [1:0.1:8]
// 文字浮雕高度
text_emboss_height = 0.4;     // [0.1:0.1:2]
// 声速，单位 m/s
sound_speed = 343;

// ---------------- 派生尺寸 ----------------
pitch = channel_width + wall_thickness;
inner_radius = duct_radius + wall_thickness;
outer_radius = inner_radius + layer_count * channel_width + (layer_count - 1) * wall_thickness + wall_thickness;
total_length = body_length + 2 * pipe_extension;
z0 = -body_length / 2;
pipe_z0 = -total_length / 2;

function layer_inner_r(i) = inner_radius + i * pitch;
function layer_outer_r(i) = layer_inner_r(i) + channel_width;
function layer_neck_z(i) = z0 + wall_thickness + neck_width / 2 + i * ((body_length - 2 * wall_thickness - neck_width) / max(1, layer_count - 1));
function layer_volume_mm3(i) = PI * (pow(layer_outer_r(i), 2) - pow(layer_inner_r(i), 2)) * (body_length - 2 * wall_thickness);
function layer_neck_area_mm2(i) = 2 * PI * duct_radius * neck_width;
function layer_freq(i) =
    let(
        v = layer_volume_mm3(i) / 1000000000,
        a = layer_neck_area_mm2(i) / 1000000,
        le = (wall_thickness + i * pitch + 1.7 * neck_width) / 1000
    )
    (sound_speed / (2 * PI)) * sqrt(a / (v * le));

echo("====================");
for (i = [0:layer_count - 1])
    echo(str("第 ", i + 1, " 层频率 = "), round(layer_freq(i) * 10) / 10, "Hz");
echo("====================");

module annular_solid(z_start, z_len, r_outer, r_inner) {
    difference() {
        translate([0, 0, z_start])
            cylinder(h = z_len, r = r_outer, center = false);
        translate([0, 0, z_start - 0.5])
            cylinder(h = z_len + 1, r = r_inner, center = false);
    }
}

module layer_void(i) {
    difference() {
        translate([0, 0, z0 + wall_thickness])
            cylinder(h = body_length - 2 * wall_thickness, r = layer_outer_r(i), center = false);
        translate([0, 0, z0 + wall_thickness - 0.5])
            cylinder(h = body_length - 2 * wall_thickness + 1, r = layer_inner_r(i), center = false);
    }
}

module neck_void(i) {
    translate([0, 0, layer_neck_z(i) - neck_width / 2])
        cylinder(h = neck_width, r = layer_outer_r(i) + 0.02, center = false);
}

module all_voids() {
    for (i = [0:layer_count - 1]) {
        layer_void(i);
        neck_void(i);
    }
}

module body_solid() {
    difference() {
        union() {
            translate([0, 0, z0])
                cylinder(h = body_length, r = outer_radius, center = false);
            annular_solid(pipe_z0, total_length, inner_radius, duct_radius);
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
    color("MediumSeaGreen", 0.45)
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
    freq_text = str(round(layer_freq(layer_count - 1)), "-", round(layer_freq(0)), " Hz");
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
