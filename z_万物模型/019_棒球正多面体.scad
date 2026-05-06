// ============================================
//  棒球正多面体
//  Ball-and-stick Platonic Solid
//  默认：正八面体；可切换成立方体/正四面体/正二十面体
// ============================================

$fn = 36;

/* [选择模型] */
solid_type = "icosahedron"; // ["icosahedron":正二十面体, "cube":立方体, "tetrahedron":正四面体, "octahedron":正八面体]

/* [尺寸] */
outer_radius = 48;          // 顶点到中心的半径
ball_diameter = 9.5;        // 顶点球直径
rod_diameter = 4.0;         // 棍棒直径

/* [打印辅助] */
lift_to_plate = true;       // 自动抬高，让最低球接触打印平台
add_base = false;            // 添加简洁底座，更方便 FDM 打印
base_diameter = 70;
base_height = 3.2;
support_post_diameter = 5.0;

phi = (1 + sqrt(5)) / 2;

function dist(a, b) =
    sqrt(
        pow(a[0] - b[0], 2) +
        pow(a[1] - b[1], 2) +
        pow(a[2] - b[2], 2)
    );

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

// ---------- 组件 ----------

module ball(p) {
    translate(p)
        sphere(d = ball_diameter, $fn = 28);
}

module stick(p1, p2) {
    v = [
        p2[0] - p1[0],
        p2[1] - p1[1],
        p2[2] - p1[2]
    ];
    l = dist(p1, p2);

    translate(p1)
        if (abs(v[0]) < 0.001 && abs(v[1]) < 0.001)
            rotate([v[2] < 0 ? 180 : 0, 0, 0])
                cylinder(d = rod_diameter, h = l, $fn = 18);
        else
            rotate(a = acos(v[2] / l), v = [-v[1], v[0], 0])
                cylinder(d = rod_diameter, h = l, $fn = 18);
}

module all_balls(points) {
    for (p = points)
        ball(p);
}

module all_sticks(points, edge_len) {
    tolerance = edge_len * 0.035;

    for (i = [0 : len(points) - 2])
        for (j = [i + 1 : len(points) - 1])
            if (abs(dist(points[i], points[j]) - edge_len) < tolerance)
                stick(points[i], points[j]);
}

module simple_base(z_offset) {
    if (add_base) {
        translate([0, 0, base_height / 2])
            cylinder(d = base_diameter, h = base_height, center = true, $fn = 48);

        translate([0, 0, base_height])
            cylinder(d1 = base_diameter * 0.42, d2 = support_post_diameter, h = z_offset - base_height, $fn = 24);
    }
}

module ball_and_stick_polyhedron() {
    raw_points = selected_vertices();
    z_offset = lift_to_plate ? (-min_z(raw_points) + ball_diameter / 2 + (add_base ? base_height : 0)) : 0;
    points = [for (p = raw_points) [p[0], p[1], p[2] + z_offset]];
    edge_len = selected_edge_length();

    union() {
        simple_base(z_offset);
        all_sticks(points, edge_len);
        all_balls(points);
    }
}

ball_and_stick_polyhedron();
