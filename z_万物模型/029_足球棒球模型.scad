// ============================================
//  可拆装足球棒球模型
//  Printable ball-and-stick soccer ball kit
//
//  足球几何：截角二十面体
//  需要零件：60 个三孔球节点 + 90 根等长棒
//
//  模式：
//  - assembled_preview：组装完成后的足球骨架
//  - kit_preview：一个三孔球 + 一根棒，方便看配件
//  - print_all_parts：排出全部 60 个球和 90 根棒
//  - single_ball / single_rod：单独导出一个零件
// ============================================

$fn = 30;

/* [显示模式] */
view_mode = "kit_preview";  // ["assembled_preview":组装预览, "kit_preview":配件预览, "print_all_parts":全部配件排版, "single_ball":单个球, "single_rod":单根棒]

/* [整体尺寸] */
outer_radius = 62;          // 球节点中心到模型中心的半径
ball_diameter = 12.5;       // 球节点直径
rod_diameter = 3.8;         // 棒直径

/* [插接参数] */
socket_clearance = 0.35;    // 孔径 = 棒直径 + 这个余量，FDM 建议 0.25~0.45
socket_depth = 5.0;         // 每根棒插入球里的深度
rod_end_gap = 0.25;         // 每端预留一点空隙，避免插到底后顶死

/* [零件打印辅助] */
add_ball_print_flat = true; // 给单独打印的球切一个很浅的底平面
ball_flat_height = 0.8;     // 底部削平高度
rod_print_orientation = "vertical"; // ["vertical":竖排棒, "horizontal":横放棒]

/* [排版参数] */
parts_show_identical_balls = true; // true：排版里所有球用同一个三孔节点；实际可打印 1 个后复制 60 份
sample_ball_index = 0;             // 展示哪个顶点的孔方向
parts_ball_spacing = 19;
parts_rod_spacing = 7;
parts_rod_cols = 15;

/* [组装预览辅助] */
lift_to_plate = true;
add_preview_base = false;
assembled_show_sockets = false; // true 会显示每个球的真实孔，但 60 个球布尔会明显变慢
preview_base_diameter = 92;
preview_base_height = 3.0;
preview_post_diameter = 5.0;

phi = (1 + sqrt(5)) / 2;
raw_radius = sqrt(1 + 9 * phi * phi);
raw_edge_length = 2;
edge_tolerance_ratio = 0.03;
football_ball_count = 60;
football_rod_count = 90;

// ---------- 基础向量 ----------

function dist(a, b) =
    sqrt(
        pow(a[0] - b[0], 2) +
        pow(a[1] - b[1], 2) +
        pow(a[2] - b[2], 2)
    );

function v_add(a, b) = [a[0] + b[0], a[1] + b[1], a[2] + b[2]];
function v_sub(a, b) = [a[0] - b[0], a[1] - b[1], a[2] - b[2]];
function v_mul(a, s) = [a[0] * s, a[1] * s, a[2] * s];
function v_len(a) = sqrt(a[0] * a[0] + a[1] * a[1] + a[2] * a[2]);
function v_unit(a) = let(l = v_len(a)) [a[0] / l, a[1] / l, a[2] / l];
function unit_between(a, b) = v_unit(v_sub(b, a));

function scale_point(p, s) = [p[0] * s, p[1] * s, p[2] * s];
function scale_points(points, s) = [for (p = points) scale_point(p, s)];
function min_z(points) = min([for (p = points) p[2]]);

// 偶置换：(a,b,c), (b,c,a), (c,a,b)
function even_perms(v) = [
    [v[0], v[1], v[2]],
    [v[1], v[2], v[0]],
    [v[2], v[0], v[1]]
];

// 截角二十面体标准坐标，原始边长为 2，共 60 个顶点。
function football_raw_vertices() =
    concat(
        [
            for (s1 = [-1, 1])
                for (s2 = [-1, 1])
                    for (p = even_perms([0, s1 * 1, s2 * 3 * phi]))
                        p
        ],
        [
            for (s1 = [-1, 1])
                for (s2 = [-1, 1])
                    for (s3 = [-1, 1])
                        for (p = even_perms([s1 * 1, s2 * (2 + phi), s3 * 2 * phi]))
                            p
        ],
        [
            for (s1 = [-1, 1])
                for (s2 = [-1, 1])
                    for (s3 = [-1, 1])
                        for (p = even_perms([s1 * phi, s2 * 2, s3 * (2 * phi + 1)]))
                            p
        ]
    );

function football_scale() = outer_radius / raw_radius;
function football_vertices() = scale_points(football_raw_vertices(), football_scale());
function edge_length() = raw_edge_length * football_scale();
function ball_radius() = ball_diameter / 2;
function socket_diameter() = rod_diameter + socket_clearance;
function socket_inner_offset() = ball_radius() - socket_depth + rod_end_gap;
function rod_part_length() = edge_length() - 2 * socket_inner_offset();

// ---------- 通用圆柱方向 ----------

module cylinder_between(p1, p2, d, fn_count = 22) {
    v = v_sub(p2, p1);
    l = v_len(v);

    translate(p1)
        if (abs(v[0]) < 0.001 && abs(v[1]) < 0.001)
            rotate([v[2] < 0 ? 180 : 0, 0, 0])
                cylinder(d = d, h = l, $fn = fn_count);
        else
            rotate(a = acos(v[2] / l), v = [-v[1], v[0], 0])
                cylinder(d = d, h = l, $fn = fn_count);
}

// ---------- 可打印组件 ----------

module socket_hole(center, dir) {
    p_inner = v_add(center, v_mul(dir, ball_radius() - socket_depth));
    p_outer = v_add(center, v_mul(dir, ball_radius() + 0.9));

    cylinder_between(p_inner, p_outer, socket_diameter(), 22);
}

module bottom_flat_cut(center) {
    top_z = center[2] - ball_radius() + ball_flat_height;

    translate([center[0], center[1], top_z - 20])
        cube([ball_diameter * 2.2, ball_diameter * 2.2, 40], center = true);
}

module connector_ball(vertex_index = 0, center = [0, 0, 0], points = football_vertices(), print_flat = false) {
    source = points[vertex_index];
    tolerance = edge_length() * edge_tolerance_ratio;

    difference() {
        translate(center)
            sphere(d = ball_diameter, $fn = 30);

        for (j = [0 : len(points) - 1])
            if (vertex_index != j && abs(dist(source, points[j]) - edge_length()) < tolerance)
                socket_hole(center, unit_between(source, points[j]));

        if (print_flat)
            bottom_flat_cut(center);
    }
}

module rod_along_z(length = rod_part_length()) {
    chamfer = min(1.0, length / 5);

    union() {
        cylinder(d1 = rod_diameter * 0.82, d2 = rod_diameter, h = chamfer, $fn = 20);

        translate([0, 0, chamfer])
            cylinder(d = rod_diameter, h = length - chamfer * 2, $fn = 20);

        translate([0, 0, length - chamfer])
            cylinder(d1 = rod_diameter, d2 = rod_diameter * 0.82, h = chamfer, $fn = 20);
    }
}

module rod_horizontal(length = rod_part_length()) {
    translate([0, 0, rod_diameter / 2])
        rotate([0, 90, 0])
            rod_along_z(length);
}

module rod_for_print(length = rod_part_length()) {
    if (rod_print_orientation == "horizontal")
        rod_horizontal(length);
    else
        rod_along_z(length);
}

// ---------- 组装预览 ----------

module assembled_rod(p1, p2) {
    dir = unit_between(p1, p2);
    p_start = v_add(p1, v_mul(dir, socket_inner_offset()));
    p_end = v_add(p2, v_mul(dir, -socket_inner_offset()));

    cylinder_between(p_start, p_end, rod_diameter, 20);
}

module all_assembled_rods(points) {
    tolerance = edge_length() * edge_tolerance_ratio;

    for (i = [0 : len(points) - 2])
        for (j = [i + 1 : len(points) - 1])
            if (abs(dist(points[i], points[j]) - edge_length()) < tolerance)
                assembled_rod(points[i], points[j]);
}

module all_connector_balls(points, raw_points) {
    for (i = [0 : len(points) - 1])
        if (assembled_show_sockets)
            connector_ball(i, points[i], raw_points, false);
        else
            translate(points[i])
                sphere(d = ball_diameter, $fn = 24);
}

module preview_base(z_offset) {
    if (add_preview_base) {
        translate([0, 0, preview_base_height / 2])
            cylinder(d = preview_base_diameter, h = preview_base_height, center = true, $fn = 48);

        translate([0, 0, preview_base_height])
            cylinder(
                d1 = preview_base_diameter * 0.34,
                d2 = preview_post_diameter,
                h = z_offset - preview_base_height,
                $fn = 24
            );
    }
}

module assembled_preview() {
    raw_points = football_vertices();
    z_offset = lift_to_plate ? (-min_z(raw_points) + ball_radius() + (add_preview_base ? preview_base_height : 0)) : 0;
    points = [for (p = raw_points) [p[0], p[1], p[2] + z_offset]];

    union() {
        preview_base(z_offset);
        all_assembled_rods(points);
        all_connector_balls(points, raw_points);
    }
}

// ---------- 配件预览 / 排版 ----------

module kit_preview() {
    points = football_vertices();

    union() {
        translate([-24, 0, ball_radius()])
            connector_ball(sample_ball_index, [0, 0, 0], points, add_ball_print_flat);

        translate([2, 0, 0])
            rod_horizontal(rod_part_length());
    }
}

module print_all_parts() {
    points = football_vertices();
    ball_cols = 10;
    ball_rows = ceil(football_ball_count / ball_cols);
    rod_y0 = ball_rows * parts_ball_spacing + 18;
    rod_step_y = rod_print_orientation == "horizontal" ? parts_rod_spacing * 1.4 : parts_rod_spacing;
    rod_step_x = rod_print_orientation == "horizontal" ? rod_part_length() + 6 : parts_rod_spacing;

    union() {
        for (i = [0 : football_ball_count - 1]) {
            idx = parts_show_identical_balls ? sample_ball_index : i;
            x = (i % ball_cols) * parts_ball_spacing - (ball_cols - 1) * parts_ball_spacing / 2;
            y = floor(i / ball_cols) * parts_ball_spacing;

            translate([x, y, ball_radius()])
                connector_ball(idx, [0, 0, 0], points, add_ball_print_flat);
        }

        for (k = [0 : football_rod_count - 1]) {
            x = (k % parts_rod_cols) * rod_step_x - (parts_rod_cols - 1) * rod_step_x / 2;
            y = rod_y0 + floor(k / parts_rod_cols) * rod_step_y;

            translate([x, y, 0])
                rod_for_print(rod_part_length());
        }
    }
}

module single_ball() {
    points = football_vertices();

    translate([0, 0, ball_radius()])
        connector_ball(sample_ball_index, [0, 0, 0], points, add_ball_print_flat);
}

module single_rod() {
    rod_for_print(rod_part_length());
}

// ---------- 输出 ----------

echo("soccer ball = truncated icosahedron");
echo(str("balls = ", football_ball_count, " pcs"));
echo(str("rods = ", football_rod_count, " pcs"));
echo(str("node degree = 3 holes per ball"));
echo(str("edge_length(center-to-center) = ", edge_length(), " mm"));
echo(str("rod_length = ", rod_part_length(), " mm"));
echo(str("socket_diameter = ", socket_diameter(), " mm"));
echo(str("socket_depth = ", socket_depth, " mm"));

if (view_mode == "assembled_preview")
    assembled_preview();
else if (view_mode == "print_all_parts")
    print_all_parts();
else if (view_mode == "single_ball")
    single_ball();
else if (view_mode == "single_rod")
    single_rod();
else
    kit_preview();
