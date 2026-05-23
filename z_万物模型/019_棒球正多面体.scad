// ============================================
//  可拆装棒球正多面体
//  Printable ball-and-stick Platonic solid kit
//
//  模式：
//  - assembled_preview：看组装完成后的正多面体
//  - kit_preview：看需要打印的“带孔球 + 棒”配件
//  - print_all_parts：把全部球和棒排出来，方便直接切片
//  - single_ball / single_rod：单独导出一个零件
// ============================================

$fn = 32;

/* [选择模型] */
solid_type = "icosahedron"; // ["icosahedron":正二十面体, "cube":立方体, "tetrahedron":正四面体, "octahedron":正八面体]
view_mode = "kit_preview";  // ["assembled_preview":组装预览, "kit_preview":配件预览, "print_all_parts":全部配件排版, "single_ball":单个球, "single_rod":单根棒]

/* [整体尺寸] */
outer_radius = 48;          // 顶点球中心到模型中心的半径
ball_diameter = 13.0;       // 球节点直径，五孔二十面体建议 >= 12
rod_diameter = 4.0;         // 棒直径

/* [插接参数] */
socket_clearance = 0.35;    // 孔径比棒直径大多少，FDM 建议 0.25~0.45
socket_depth = 5.2;         // 棒插入球内的深度
rod_end_gap = 0.25;         // 每端预留一点空隙，避免顶死

/* [排版参数] */
parts_show_identical_balls = true; // true：全部球按同一种节点方向排版；正多面体节点可互相旋转通用
sample_ball_index = 0;             // 配件预览时展示哪个顶点的孔方向
parts_ball_spacing = 22;
parts_rod_spacing = 7;
parts_rod_cols = 10;

/* [预览辅助] */
lift_to_plate = true;       // 组装预览时抬高，让最低球接触打印平台
add_base = false;           // 仅组装预览使用；加一个细底座方便观察
base_diameter = 70;
base_height = 3.2;
support_post_diameter = 5.0;

phi = (1 + sqrt(5)) / 2;
edge_tolerance_ratio = 0.035;

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

// ---------- 顶点 ----------

function cube_vertices() =
    let(s = outer_radius / sqrt(3))
    scale_points([
        [-1, -1, -1], [ 1, -1, -1], [ 1,  1, -1], [-1,  1, -1],
        [-1, -1,  1], [ 1, -1,  1], [ 1,  1,  1], [-1,  1,  1]
    ], s);

function tetrahedron_vertices() =
    let(s = outer_radius / sqrt(3))
    scale_points([
        [ 1,  1,  1],
        [-1, -1,  1],
        [-1,  1, -1],
        [ 1, -1, -1]
    ], s);

function octahedron_vertices() =
    scale_points([
        [ 1,  0,  0], [-1,  0,  0],
        [ 0,  1,  0], [ 0, -1,  0],
        [ 0,  0,  1], [ 0,  0, -1]
    ], outer_radius);

function icosahedron_vertices() =
    let(s = outer_radius / sqrt(1 + phi * phi))
    scale_points([
        [0, -1, -phi], [0,  1, -phi], [0, -1,  phi], [0,  1,  phi],
        [-1, -phi, 0], [ 1, -phi, 0], [-1,  phi, 0], [ 1,  phi, 0],
        [-phi, 0, -1], [ phi, 0, -1], [-phi, 0,  1], [ phi, 0,  1]
    ], s);

function selected_vertices() =
    solid_type == "cube" ? cube_vertices() :
    solid_type == "tetrahedron" ? tetrahedron_vertices() :
    solid_type == "octahedron" ? octahedron_vertices() :
    icosahedron_vertices();

function selected_edge_length() =
    solid_type == "cube" ? 2 * outer_radius / sqrt(3) :
    solid_type == "tetrahedron" ? 2 * sqrt(2) * outer_radius / sqrt(3) :
    solid_type == "octahedron" ? sqrt(2) * outer_radius :
    2 * outer_radius / sqrt(1 + phi * phi);

function selected_edge_count() =
    solid_type == "cube" ? 12 :
    solid_type == "tetrahedron" ? 6 :
    solid_type == "octahedron" ? 12 :
    30;

function ball_radius() = ball_diameter / 2;
function socket_diameter() = rod_diameter + socket_clearance;
function socket_inner_offset() = ball_radius() - socket_depth + rod_end_gap;
function rod_part_length(edge_len) = edge_len - 2 * socket_inner_offset();

// ---------- 通用圆柱方向 ----------

module cylinder_between(p1, p2, d, fn_count = 24) {
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

// ---------- 可打印零件 ----------

module socket_hole(center, dir) {
    p_inner = v_add(center, v_mul(dir, ball_radius() - socket_depth));
    p_outer = v_add(center, v_mul(dir, ball_radius() + 0.8));

    cylinder_between(p_inner, p_outer, socket_diameter(), 24);
}

module connector_ball(vertex_index = 0, center = [0, 0, 0], points = selected_vertices(), edge_len = selected_edge_length()) {
    source = points[vertex_index];
    tolerance = edge_len * edge_tolerance_ratio;

    difference() {
        translate(center)
            sphere(d = ball_diameter, $fn = 32);

        for (j = [0 : len(points) - 1])
            if (vertex_index != j && abs(dist(source, points[j]) - edge_len) < tolerance)
                socket_hole(center, unit_between(source, points[j]));
    }
}

module rod_along_z(length) {
    chamfer = min(1.1, length / 5);

    union() {
        cylinder(d1 = rod_diameter * 0.82, d2 = rod_diameter, h = chamfer, $fn = 22);

        translate([0, 0, chamfer])
            cylinder(d = rod_diameter, h = length - chamfer * 2, $fn = 22);

        translate([0, 0, length - chamfer])
            cylinder(d1 = rod_diameter, d2 = rod_diameter * 0.82, h = chamfer, $fn = 22);
    }
}

module rod_horizontal(length) {
    translate([0, 0, rod_diameter / 2])
        rotate([0, 90, 0])
            rod_along_z(length);
}

// ---------- 组装预览 ----------

module assembled_rod(p1, p2) {
    dir = unit_between(p1, p2);
    p_start = v_add(p1, v_mul(dir, socket_inner_offset()));
    p_end = v_add(p2, v_mul(dir, -socket_inner_offset()));

    cylinder_between(p_start, p_end, rod_diameter, 22);
}

module all_connector_balls(points, raw_points, edge_len) {
    for (i = [0 : len(points) - 1])
        connector_ball(i, points[i], raw_points, edge_len);
}

module all_assembled_rods(points, edge_len) {
    tolerance = edge_len * edge_tolerance_ratio;

    for (i = [0 : len(points) - 2])
        for (j = [i + 1 : len(points) - 1])
            if (abs(dist(points[i], points[j]) - edge_len) < tolerance)
                assembled_rod(points[i], points[j]);
}

module simple_base(z_offset) {
    if (add_base) {
        translate([0, 0, base_height / 2])
            cylinder(d = base_diameter, h = base_height, center = true, $fn = 48);

        translate([0, 0, base_height])
            cylinder(d1 = base_diameter * 0.42, d2 = support_post_diameter, h = z_offset - base_height, $fn = 24);
    }
}

module assembled_preview() {
    raw_points = selected_vertices();
    edge_len = selected_edge_length();
    z_offset = lift_to_plate ? (-min_z(raw_points) + ball_radius() + (add_base ? base_height : 0)) : 0;
    points = [for (p = raw_points) [p[0], p[1], p[2] + z_offset]];

    union() {
        simple_base(z_offset);
        all_assembled_rods(points, edge_len);
        all_connector_balls(points, raw_points, edge_len);
    }
}

// ---------- 配件预览 / 排版 ----------

module kit_preview() {
    raw_points = selected_vertices();
    edge_len = selected_edge_length();
    rod_len = rod_part_length(edge_len);

    union() {
        translate([-26, 0, ball_radius()])
            connector_ball(sample_ball_index, [0, 0, 0], raw_points, edge_len);

        translate([4, 0, 0])
            rod_horizontal(rod_len);
    }
}

module print_all_parts() {
    raw_points = selected_vertices();
    edge_len = selected_edge_length();
    ball_count = len(raw_points);
    rod_count = selected_edge_count();
    rod_len = rod_part_length(edge_len);
    ball_cols = ceil(sqrt(ball_count));
    ball_rows = ceil(ball_count / ball_cols);
    rod_y0 = ball_rows * parts_ball_spacing + 18;

    union() {
        for (i = [0 : ball_count - 1]) {
            idx = parts_show_identical_balls ? sample_ball_index : i;
            x = (i % ball_cols) * parts_ball_spacing - (ball_cols - 1) * parts_ball_spacing / 2;
            y = floor(i / ball_cols) * parts_ball_spacing;

            translate([x, y, ball_radius()])
                connector_ball(idx, [0, 0, 0], raw_points, edge_len);
        }

        for (k = [0 : rod_count - 1]) {
            x = (k % parts_rod_cols) * parts_rod_spacing - (parts_rod_cols - 1) * parts_rod_spacing / 2;
            y = rod_y0 + floor(k / parts_rod_cols) * parts_rod_spacing;

            translate([x, y, 0])
                rod_along_z(rod_len);
        }
    }
}

module single_ball() {
    raw_points = selected_vertices();
    edge_len = selected_edge_length();

    translate([0, 0, ball_radius()])
        connector_ball(sample_ball_index, [0, 0, 0], raw_points, edge_len);
}

module single_rod() {
    rod_along_z(rod_part_length(selected_edge_length()));
}

// ---------- 输出 ----------

echo(str("solid_type = ", solid_type));
echo(str("balls = ", len(selected_vertices()), " pcs"));
echo(str("rods = ", selected_edge_count(), " pcs"));
echo(str("rod_length = ", rod_part_length(selected_edge_length()), " mm"));
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

