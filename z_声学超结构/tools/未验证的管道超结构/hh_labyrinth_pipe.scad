// 管道外置环形折叠迷宫共振器。
// 结构理解：中心为直通管道，外部为多层环形折返侧支通道。
// 声波从中心管道侧壁开口进入外侧迷宫通道，通过延长等效声程实现低频共振。

$fn = 180;

// ---------------- 可调参数 ----------------
// 中心通风管半径，单位 mm
duct_radius = 28;             // [10:1:70]
// 伸出外壳两侧的管道长度，单位 mm
pipe_extension = 28;          // [0:1:100]
// 外部共振器壳体轴向长度，单位 mm
chamber_length = 72;          // [30:1:180]
// 迷宫通道层数
fold_count = 5;               // [2:1:10]
// 迷宫通道宽度，单位 mm
channel_width = 4.2;          // [1.5:0.1:12]
// 壁厚，单位 mm
wall_thickness = 1.4;         // [0.8:0.1:5]
// 管道到第一层迷宫通道之间的间隔，单位 mm
inner_wall = 1.4;             // [0.8:0.1:8]
// 两端径向折返通道宽度，单位 mm
turn_width = 4.2;             // [1.5:0.1:12]
// 管壁声学入口的轴向宽度，单位 mm
port_width = 4.5;             // [1:0.1:16]

// 模型模式：solid 为完整实体，cutaway 为剖视，print_set 为开口主体和盖板排布
display_mode = "cutaway";     // [solid, cutaway, print_set]
// print_set 模式下主体和盖板间距，单位 mm
print_part_gap = 10;          // [2:1:40]
// 是否显示估算的四分之一波长频率
show_frequency = true;
// 频率文字大小
frequency_text_size = 4;      // [1:0.1:10]
// 文字浮雕高度
text_emboss_height = 0.5;     // [0.1:0.1:2]
// 声速，单位 m/s
sound_speed = 343;

// ---------------- 派生尺寸 ----------------
channel_pitch = channel_width + wall_thickness;
labyrinth_inner_radius = duct_radius + inner_wall;
labyrinth_outer_radius = labyrinth_inner_radius + fold_count * channel_width + (fold_count - 1) * wall_thickness;
outer_radius = labyrinth_outer_radius + wall_thickness;
body_length = chamber_length;
total_length = chamber_length + 2 * pipe_extension;
z_left = -chamber_length / 2;
z_right = chamber_length / 2;
pipe_z_left = -total_length / 2;
pipe_z_right = total_length / 2;
port_z = z_left + wall_thickness + port_width / 2;
turn_margin = wall_thickness + turn_width;
fold_shorten = max(2, (chamber_length - 2 * turn_margin) / (2 * fold_count + 2));
cutaway_gap = 0.03;

estimated_path_length = chamber_length * fold_count + turn_width * (fold_count - 1);
estimated_frequency = sound_speed * 1000 / (4 * estimated_path_length);

echo("====================");
echo("环形折叠迷宫估算频率 =", round(estimated_frequency * 10) / 10, "Hz");
echo("估算声程 =", round(estimated_path_length * 10) / 10, "mm");
echo("====================");

// ---------------- 基础形状 ----------------
module rz_rect(r0, r1, z0, z1) {
    polygon(points = [
        [r0, z0],
        [r1, z0],
        [r1, z1],
        [r0, z1]
    ]);
}

module rotate_rz() {
    rotate_extrude(convexity = 10)
        children();
}

module outer_housing() {
    translate([0, 0, z_left])
        cylinder(h = chamber_length, r = outer_radius, center = false);
}

module center_pipe_shell() {
    difference() {
        translate([0, 0, pipe_z_left])
            cylinder(h = total_length, r = labyrinth_inner_radius, center = false);

        translate([0, 0, pipe_z_left - 0.5])
            cylinder(h = total_length + 1, r = duct_radius, center = false);
    }
}

module labyrinth_path_2d() {
    union() {
        // 多层轴向环形通道，外层更长、内层更短，形成图中阶梯式折返。
        for (i = [0:fold_count - 1]) {
            r0 = labyrinth_inner_radius + i * channel_pitch;
            r1 = r0 + channel_width;
            z0 = z_left + turn_margin + i * fold_shorten;
            z1 = z_right - turn_margin - i * fold_shorten;
            rz_rect(r0, r1, z0, z1);
        }

        // 相邻层在左右端交替连通，形成连续折叠通道。
        for (i = [0:fold_count - 2]) {
            r0 = labyrinth_inner_radius + i * channel_pitch;
            r1 = r0 + channel_width + wall_thickness + channel_width;
            if (i % 2 == 0) {
                z0 = z_right - turn_margin - i * fold_shorten - turn_width;
                z1 = z_right - turn_margin - i * fold_shorten;
                rz_rect(r0, r1, z0, z1);
            } else {
                z0 = z_left + turn_margin + i * fold_shorten;
                z1 = z_left + turn_margin + i * fold_shorten + turn_width;
                rz_rect(r0, r1, z0, z1);
            }
        }

        // 第一层通道与中心管道之间的入口。
        rz_rect(
            duct_radius - cutaway_gap,
            labyrinth_inner_radius + channel_width,
            port_z - port_width / 2,
            port_z + port_width / 2
        );
    }
}

module labyrinth_void() {
    rotate_rz()
        labyrinth_path_2d();
}

module resonator_solid() {
    difference() {
        union() {
            outer_housing();
            center_pipe_shell();
        }

        translate([0, 0, pipe_z_left - 0.5])
            cylinder(h = total_length + 1, r = duct_radius, center = false);

        labyrinth_void();
    }
}

module cutaway_cavity_volume() {
    color("ForestGreen", 0.45)
        intersection() {
            labyrinth_void();
            translate([-outer_radius - 1, -outer_radius - 1, z_left - 1])
                cube([2 * outer_radius + 2, outer_radius + 1, chamber_length + 2], center = false);
        }
}

module resonator_cutaway() {
    difference() {
        resonator_solid();

        translate([-outer_radius - 1, -outer_radius - 1, pipe_z_left - 1])
            cube([2 * outer_radius + 2, outer_radius + 1, total_length + 2], center = false);
    }
}

module printable_body() {
    intersection() {
        resonator_solid();

        translate([-outer_radius - 1, -outer_radius - 1, pipe_z_left - 1])
            cube([
                2 * outer_radius + 2,
                2 * outer_radius + 2,
                total_length / 2 + chamber_length / 2 + 1 - wall_thickness
            ], center = false);
    }
}

module printable_lid() {
    difference() {
        translate([0, 0, z_left])
            cylinder(h = wall_thickness, r = outer_radius, center = false);

        translate([0, 0, z_left - 0.5])
            cylinder(h = wall_thickness + 1, r = duct_radius, center = false);
    }
}

module printable_set() {
    printable_body();

    translate([2 * outer_radius + print_part_gap, 0, -z_left])
        printable_lid();
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

module top_frequency_label() {
    if (show_frequency) {
        translate([0, -outer_radius * 0.58, z_right + 0.01])
            frequency_text_emboss();
    }
}

module model() {
    if (display_mode == "cutaway") {
        color("Gainsboro")
            resonator_cutaway();
        cutaway_cavity_volume();
        color("Black")
            top_frequency_label();
    } else if (display_mode == "print_set") {
        printable_set();
    } else {
        union() {
            resonator_solid();
            color("Black")
                top_frequency_label();
        }
    }
}

model();
