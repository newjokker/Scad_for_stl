// 管道内衬式海姆霍兹共振器。
// 中央为通风圆管，外圈为沿周向排列的环形扇区腔体。
// 每个单元都是一个封闭扇形腔，并通过一根径向颈管连通到中心管道。

$fn = 200;

// ---------------- 可调参数 ----------------
// 中心管道半径 RD，单位 mm
duct_radius = 34;             // [15:1:80]
// 周向海姆霍兹单元数量
unit_count = 18;              // [6:1:48]

// 腔体径向深度，单位 mm
cavity_radial_depth = 22;     // [8:1:60]
// 腔体轴向长度 HC，单位 mm
cavity_axial_length = 24;     // [6:1:110]
// 颈管径向长度 TN，单位 mm
neck_length = 7;              // [2:0.5:30]
// 颈管半径 RN，单位 mm
neck_radius = 2.6;            // [0.8:0.1:8]
// 壁厚，单位 mm
wall_thickness = 1.2;         // [0.6:0.1:5]

// 显示模式：solid 为实体，transparent 为透明，cutaway 为剖视
display_mode = "cutaway";     // [solid, transparent, cutaway]
// 是否在端面显示估算共振频率
show_frequency = true;
// 频率文字大小
frequency_text_size = 3.2;    // [1:0.1:10]
// 文字浮雕高度
text_emboss_height = 0.5;     // [0.1:0.1:2]
// 声速，单位 m/s
sound_speed = 343;

// ---------------- 派生尺寸 ----------------
cell_pitch_angle = 360 / unit_count;
cavity_inner_radius = duct_radius + wall_thickness + neck_length;
cavity_outer_radius = cavity_inner_radius + cavity_radial_depth;
// 按腔体内侧半径换算周向隔板角度，使隔板最薄处等于 wall_thickness。
partition_angle = 2 * asin(min(0.95, wall_thickness / (2 * cavity_inner_radius)));
cavity_span_angle = max(0.1, cell_pitch_angle - partition_angle);
outer_radius = cavity_outer_radius + wall_thickness;
body_length = cavity_axial_length + 2 * wall_thickness;
cavity_z0 = wall_thickness;
cavity_z_mid = body_length / 2;
neck_overlap_into_duct = max(neck_radius * 1.5, wall_thickness + 0.5);

design_frequency = pipe_helmholtz_frequency(
    cavity_inner_radius,
    cavity_outer_radius,
    cavity_span_angle,
    cavity_axial_length,
    neck_length,
    neck_radius,
    sound_speed
);

echo("====================");
echo("管道海姆霍兹单元频率 =", round(design_frequency * 10) / 10, "Hz");
echo("单元中心角 =", cell_pitch_angle, "deg");
echo("隔板角度 =", partition_angle, "deg");
echo("腔体角度 =", cavity_span_angle, "deg");
echo("====================");

// ---------------- 数学辅助函数 ----------------
function polar_point(r, a) = [r * cos(a), r * sin(a)];

function arc_points(r, a0, a1, n) =
    [for (i = [0:n]) polar_point(r, a0 + (a1 - a0) * i / n)];

function reverse_arc_points(r, a0, a1, n) =
    [for (i = [0:n]) polar_point(r, a1 - (a1 - a0) * i / n)];

function annular_sector_area(inner_r, outer_r, span_angle) =
    PI * (outer_r * outer_r - inner_r * inner_r) * span_angle / 360;

function pipe_helmholtz_frequency(
    cavity_inner_r,
    cavity_outer_r,
    span_angle,
    axial_length,
    neck_len,
    neck_r,
    c = 343
) =
    let(
        cavity_volume_mm3 =
            annular_sector_area(cavity_inner_r, cavity_outer_r, span_angle) * axial_length,
        cavity_volume_m3 = cavity_volume_mm3 / 1000000000,
        neck_area_mm2 = PI * neck_r * neck_r,
        neck_area_m2 = neck_area_mm2 / 1000000,
        effective_length_m = (neck_len + 1.7 * neck_r) / 1000
    )
    (c / (2 * PI)) * sqrt(neck_area_m2 / (cavity_volume_m3 * effective_length_m));

// ---------------- 形状模块 ----------------
module annular_sector_2d(inner_r, outer_r, center_angle, span_angle, steps = 10) {
    a0 = center_angle - span_angle / 2;
    a1 = center_angle + span_angle / 2;
    polygon(points = concat(
        arc_points(outer_r, a0, a1, steps),
        reverse_arc_points(inner_r, a0, a1, steps)
    ));
}

module cavity_void(angle) {
    translate([0, 0, cavity_z0])
        linear_extrude(height = cavity_axial_length, convexity = 8)
            annular_sector_2d(
                cavity_inner_radius,
                cavity_outer_radius,
                angle,
                cavity_span_angle,
                max(4, ceil(cavity_span_angle / 4))
            );
}

module neck_void(angle) {
    // 径向圆柱孔，用于连接中心管道和单个腔体。
    // 切孔会向中心管内多伸入一段，保证出口是完整圆孔。
    rotate([0, 0, angle])
        translate([duct_radius - neck_overlap_into_duct, 0, cavity_z_mid])
            rotate([0, 90, 0])
                cylinder(
                    h = neck_length + wall_thickness + neck_overlap_into_duct + 0.15,
                    r = neck_radius,
                    center = false
                );
}

module all_cavity_voids() {
    for (i = [0:unit_count - 1]) {
        angle = i * cell_pitch_angle;
        cavity_void(angle);
        neck_void(angle);
    }
}

module pipe_body_solid() {
    difference() {
        cylinder(h = body_length, r = outer_radius, center = false);

        translate([0, 0, -0.5])
            cylinder(h = body_length + 1, r = duct_radius, center = false);

        all_cavity_voids();
    }
}

module frequency_text_emboss() {
    freq_text = str(round(design_frequency * 10) / 10, " Hz");
    linear_extrude(height = text_emboss_height, center = false)
        text(
            text = freq_text,
            size = frequency_text_size,
            font = "Arial:style=Bold",
            halign = "center",
            valign = "center"
        );
}

module front_frequency_label() {
    if (show_frequency) {
        translate([0, -outer_radius * 0.72, -0.01])
            rotate([180, 0, 0])
                frequency_text_emboss();
    }
}

module transparent_air_volume() {
    color("LightSkyBlue", 0.28)
        translate([0, 0, -0.25])
            cylinder(h = body_length + 0.5, r = duct_radius, center = false);

    color("Orange", 0.42)
        all_cavity_voids();
}

module pipe_body_cutaway() {
    difference() {
        pipe_body_solid();

        translate([-outer_radius - 1, 0, -1])
            cube([2 * outer_radius + 2, outer_radius + 1, body_length + 2], center = false);
    }
}

module helmholtz_pipe(display = display_mode) {
    if (display == "transparent") {
        color("Gainsboro", 0.34)
            pipe_body_solid();
        transparent_air_volume();
        color("Black")
            front_frequency_label();
    } else if (display == "cutaway") {
        color("Gainsboro")
            pipe_body_cutaway();
        transparent_air_volume();
    } else {
        union() {
            pipe_body_solid();
            color("Black")
                front_frequency_label();
        }
    }
}

helmholtz_pipe(display_mode);
