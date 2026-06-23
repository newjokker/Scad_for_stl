// 轴向叠片式径向多腔海姆霍兹管道结构。
// 结构理解：中心为直通管道，外侧由多个盘片单元沿轴向叠加。
// 每个单元由两片带中心孔的端盖和一片径向隔板 spacer 组成；
// spacer 中的径向腔道连通中心管道，端盖负责封闭腔体。

$fn = 120;

// ---------------- 可调参数 ----------------
// 中心管道外半径 pi，单位 mm
pipe_radius = 15;             // [6:1:50]
// 中心管道壁厚，单位 mm
pipe_wall_thickness = 1.2;    // [0.6:0.1:5]
// 中心管与盘片中心孔之间的装配间隙，单位 mm
pipe_clearance = 0.15;        // [0:0.05:1]
// 外部盘片半径，单位 mm
outer_radius = 42;            // [18:1:100]
// 叠片单元数量
unit_count = 10;              // [1:1:30]
// 单片端盖厚度 t，单位 mm
plate_thickness = 1.4;        // [0.6:0.1:5]
// 中间 spacer 高度 h，单位 mm
spacer_height = 4.0;          // [1.5:0.1:16]
// 外圈壁厚，单位 mm
outer_wall = 1.6;             // [0.8:0.1:6]
// 中心环壁厚，单位 mm
hub_wall = 2.2;               // [0.8:0.1:8]
// 折返隔板数量
rib_count = 6;                // [3:1:16]
// 折返隔板切向宽度，单位 mm
rib_width = 3.0;              // [0.8:0.1:10]
// 隔板端部连通缺口，单位 mm
turn_gap = 5.0;               // [1:0.5:20]
// 唯一入口角度，0 表示 x 正方向，单位度
inlet_angle = 180;            // [0:1:359]
// 唯一入口切向宽度，单位 mm
inlet_width = 5.0;            // [1:0.1:16]
// 中心管道两端伸出长度，单位 mm
pipe_extension = 28;          // [0:1:100]

// 显示模式：solid 为完整体，cutaway 为剖视，exploded 为单元爆炸图，print_set 为端盖和 spacer 排布
display_mode = "cutaway";     // [solid, cutaway, exploded, print_set]
// exploded/print_set 模式下零件间距，单位 mm
part_gap = 10;                // [2:1:40]
// 是否显示估算频率
show_frequency = true;
// 频率文字大小
frequency_text_size = 3.2;    // [1:0.1:10]
// 文字浮雕高度
text_emboss_height = 0.4;     // [0.1:0.1:2]
// 声速，单位 m/s
sound_speed = 343;

// ---------------- 派生尺寸 ----------------
unit_pitch = 2 * plate_thickness + spacer_height;
body_length = unit_count * unit_pitch;
pipe_length = body_length + 2 * pipe_extension;
z0 = -body_length / 2;
pipe_z0 = -pipe_length / 2;
pipe_inner_radius = max(0.1, pipe_radius - pipe_wall_thickness);
hole_radius = pipe_radius + pipe_clearance;
hub_outer_radius = hole_radius + hub_wall;
ring_inner_radius = outer_radius - outer_wall;
overlap = 0.03;
rib_inner_radius = hub_outer_radius - overlap;
rib_outer_radius = ring_inner_radius + overlap;
open_area_factor = 0.72;
cavity_area_mm2 =
    open_area_factor * PI * (pow(ring_inner_radius, 2) - pow(hub_outer_radius, 2));
cavity_volume_mm3 = max(1, cavity_area_mm2 * spacer_height);
neck_area_mm2 = max(1, inlet_width * spacer_height);
effective_neck_length_mm = hub_wall + 1.7 * spacer_height / 2;
estimated_frequency =
    (sound_speed / (2 * PI))
    * sqrt((neck_area_mm2 / 1000000) / ((cavity_volume_mm3 / 1000000000) * (effective_neck_length_mm / 1000)));

echo("====================");
echo("叠片式径向多腔估算频率 =", round(estimated_frequency * 10) / 10, "Hz");
echo("单元总长度 H =", body_length, "mm");
echo("====================");

// ---------------- 基础形状 ----------------
module annular_solid(z_start, z_len, r_outer, r_inner) {
    difference() {
        translate([0, 0, z_start])
            cylinder(h = z_len, r = r_outer, center = false);

        translate([0, 0, z_start - 0.5])
            cylinder(h = z_len + 1, r = r_inner, center = false);
    }
}

module center_pipe() {
    color("LightGray")
        annular_solid(pipe_z0, pipe_length, pipe_radius, pipe_inner_radius);
}

module cover_plate(z_start) {
    annular_solid(z_start - overlap, plate_thickness + 2 * overlap, outer_radius, hole_radius);
}

module radial_baffle(z_start, angle, idx) {
    is_inner_baffle = (idx % 2 == 0);
    r0 = is_inner_baffle ? hub_outer_radius - overlap : hub_outer_radius + turn_gap;
    r1 = is_inner_baffle ? ring_inner_radius - turn_gap : ring_inner_radius + overlap;
    rotate([0, 0, angle])
        translate([(r0 + r1) / 2, 0, z_start + spacer_height / 2])
            cube([
                max(0.1, r1 - r0),
                rib_width,
                spacer_height + 2 * overlap
            ], center = true);
}

module hub_inlet_void(z_start) {
    rotate([0, 0, inlet_angle])
        translate([(hole_radius + hub_outer_radius) / 2, 0, z_start + spacer_height / 2])
            cube([
                hub_wall + 2 * pipe_clearance + 2 * overlap,
                inlet_width,
                spacer_height + 4 * overlap
            ], center = true);
}

module spacer_disk(z_start) {
    difference() {
        union() {
            // 外圈环壁
            annular_solid(z_start - overlap, spacer_height + 2 * overlap, outer_radius, ring_inner_radius);

            // 中心环壁，入口会在后面切开
            annular_solid(z_start - overlap, spacer_height + 2 * overlap, hub_outer_radius, hole_radius);

            // 交错半隔板：中心侧、外圈侧交替伸出，端部留缺口形成连续折返通道。
            for (i = [0:rib_count - 1])
                radial_baffle(z_start, i * 360 / rib_count, i);
        }

        // 唯一入口，连通中心管道和外侧折返腔道。
        hub_inlet_void(z_start);
    }
}

module unit_solid(z_start) {
    cover_plate(z_start);
    spacer_disk(z_start + plate_thickness);
    cover_plate(z_start + plate_thickness + spacer_height);
}

module stacked_body() {
    union() {
        for (i = [0:unit_count - 1])
            unit_solid(z0 + i * unit_pitch);
    }
}

module cavity_volume_one(z_start) {
    difference() {
        translate([0, 0, z_start + plate_thickness])
            cylinder(h = spacer_height, r = ring_inner_radius, center = false);

        translate([0, 0, z_start + plate_thickness - 0.5])
            cylinder(h = spacer_height + 1, r = hub_outer_radius, center = false);

        for (i = [0:rib_count - 1])
            radial_baffle(z_start + plate_thickness, i * 360 / rib_count, i);
    }
}

module all_cavity_volumes() {
    for (i = [0:unit_count - 1])
        cavity_volume_one(z0 + i * unit_pitch);
}

module full_model() {
    union() {
        center_pipe();
        color("Sienna")
            stacked_body();
    }
}

module cutaway_model() {
    difference() {
        full_model();

        translate([-outer_radius - 1, -outer_radius - 1, pipe_z0 - 1])
            cube([2 * outer_radius + 2, outer_radius + 1, pipe_length + 2], center = false);
    }
}

module cutaway_cavities() {
    color("DarkOrange", 0.45)
        intersection() {
            all_cavity_volumes();

            translate([-outer_radius - 1, -outer_radius - 1, z0 - 1])
                cube([2 * outer_radius + 2, outer_radius + 1, body_length + 2], center = false);
        }
}

module exploded_unit() {
    center_pipe();

    color("Peru")
        translate([0, 0, -plate_thickness - spacer_height / 2 - part_gap])
            cover_plate(0);

    color("DarkOrange")
        translate([0, 0, -spacer_height / 2])
            spacer_disk(0);

    color("Peru")
        translate([0, 0, spacer_height / 2 + part_gap])
            cover_plate(0);
}

module print_set() {
    color("Peru")
        cover_plate(0);

    color("DarkOrange")
        translate([2 * outer_radius + part_gap, 0, 0])
            spacer_disk(0);
}

// ---------------- 频率文字 ----------------
module frequency_text_emboss() {
    freq_text = str(round(estimated_frequency * 10) / 10, " Hz");
    linear_extrude(height = text_emboss_height, center = false)
        text(
            text = freq_text,
            size = frequency_text_size,
            font = "Arial:style=Bold",
            halign = "center",
            valign = "center"
        );
}

module top_label() {
    if (show_frequency) {
        translate([0, -outer_radius * 0.58, body_length / 2 + 0.01])
            frequency_text_emboss();
    }
}

module model() {
    if (display_mode == "cutaway") {
        cutaway_model();
        cutaway_cavities();
        color("Black")
            top_label();
    } else if (display_mode == "exploded") {
        exploded_unit();
    } else if (display_mode == "print_set") {
        print_set();
    } else {
        full_model();
        color("Black")
            top_label();
    }
}

model();
