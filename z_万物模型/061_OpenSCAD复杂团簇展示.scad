/*
    复杂分形图案展示

    这是一个纯 OpenSCAD 参数化分形模型：
    - 递归分枝形成三维“晶体树冠”
    - Fibonacci 球面点阵形成外层星云
    - Sierpinski 四面体形成中心镂空晶核
    - 多层 rotate_extrude 环带形成声学/波纹骨架

    F5 预览即可；F6 渲染时可把 fractal_depth 调低一点。
*/

$fn = 28;

fractal_depth = 5;         // 推荐 3~5，越大越复杂
branch_count = 6;
nebula_points = 108;
overall_scale = 1.0;

show_nebula = true;
show_tree = true;
show_core = true;
show_wave_rings = true;

golden_angle = 137.507764;

function mix(a, b, t) = a * (1 - t) + b * t;
function clamp(v, lo, hi) = min(max(v, lo), hi);
function fib_point(i, n, r) =
    let(
        z = 1 - 2 * (i + 0.5) / n,
        ring = sqrt(max(0, 1 - z * z)),
        a = i * golden_angle
    )
    [r * ring * cos(a), r * ring * sin(a), r * z];

module capsule_between(a, b, r1, r2) {
    hull() {
        translate(a)
            sphere(r = r1);
        translate(b)
            sphere(r = r2);
    }
}

module tapered_branch(len, r) {
    hull() {
        sphere(r = r);
        translate([0, 0, len])
            sphere(r = r * 0.55);
    }
}

module fractal_branch(depth, len, r, twist = 0) {
    color([
        mix(0.12, 0.75, depth / max(1, fractal_depth)),
        mix(0.35, 0.92, depth / max(1, fractal_depth)),
        mix(0.95, 0.38, depth / max(1, fractal_depth)),
        1
    ])
        tapered_branch(len, r);

    translate([0, 0, len])
        sphere(r = r * 0.9);

    if (depth > 0) {
        translate([0, 0, len * 0.88])
            for (i = [0 : 2]) {
                rotate([
                    28 + depth * 6 + i * 5,
                    0,
                    twist + i * 120 + depth * 19
                ])
                    fractal_branch(
                        depth - 1,
                        len * 0.66,
                        r * 0.62,
                        twist + 31
                    );
            }
    }
}

module fractal_tree_crown() {
    for (i = [0 : branch_count - 1]) {
        rotate([58 + 8 * sin(i * 73), 0, i * 360 / branch_count])
            translate([0, 0, 12])
                fractal_branch(fractal_depth, 24, 3.2, i * 17);
    }
}

module sierpinski_tetra(depth, size) {
    if (depth <= 0) {
        polyhedron(
            points = [
                [ size,  size,  size],
                [-size, -size,  size],
                [-size,  size, -size],
                [ size, -size, -size]
            ],
            faces = [
                [0, 1, 2],
                [0, 3, 1],
                [0, 2, 3],
                [1, 3, 2]
            ]
        );
    } else {
        for (p = [
            [ size / 2,  size / 2,  size / 2],
            [-size / 2, -size / 2,  size / 2],
            [-size / 2,  size / 2, -size / 2],
            [ size / 2, -size / 2, -size / 2]
        ]) {
            translate(p)
                sierpinski_tetra(depth - 1, size / 2);
        }
    }
}

module hollow_fractal_core() {
    color([0.98, 0.76, 0.18, 1])
        difference() {
            rotate([0, 0, 45])
                sierpinski_tetra(3, 24);

            sphere(r = 10);

            for (i = [0 : 5])
                rotate([0, 90, i * 60])
                    cylinder(h = 80, r = 2.4, center = true);
        }
}

module nebula_node(i) {
    p = fib_point(i, nebula_points, 54 + 7 * sin(i * 29));
    s = 1.2 + 1.6 * abs(sin(i * 41));

    color([
        0.52 + 0.34 * sin(i * 11),
        0.72 + 0.22 * sin(i * 17 + 80),
        0.96,
        0.62
    ])
        translate(p)
            sphere(r = s);
}

module fractal_nebula() {
    for (i = [0 : nebula_points - 1]) {
        nebula_node(i);

        if (i < nebula_points - 13 && i % 3 == 0) {
            color([0.42, 0.68, 0.96, 0.35])
                capsule_between(
                    fib_point(i, nebula_points, 52),
                    fib_point(i + 13, nebula_points, 52),
                    0.42,
                    0.24
                );
        }
    }
}

module wave_ring(radius, tube, z, tilt, phase) {
    color([0.88, 0.90, 0.96, 0.42])
        rotate([tilt, 0, phase])
            translate([0, 0, z])
                rotate_extrude(convexity = 8)
                    translate([radius, 0, 0])
                        scale([1.0, 0.55])
                            circle(r = tube);
}

module recursive_wave_rings(level, radius, tube, z = 0) {
    wave_ring(radius, tube, z, 62 - level * 7, level * 29);

    if (level > 0) {
        recursive_wave_rings(level - 1, radius * 0.74, tube * 0.72, z + 4.2);
        recursive_wave_rings(level - 1, radius * 0.74, tube * 0.72, z - 4.2);
    }
}

module radial_spines() {
    color([0.08, 0.10, 0.13, 1])
        for (i = [0 : 17]) {
            a = i * 20;
            b = i * 37;
            rotate([64 + 16 * sin(b), 0, a])
                capsule_between(
                    [0, 0, 8],
                    [0, 0, 68 + 6 * sin(a)],
                    1.15,
                    0.25
                );
        }
}

module fractal_pattern() {
    scale([overall_scale, overall_scale, overall_scale])
        union() {
            if (show_wave_rings)
                recursive_wave_rings(3, 42, 1.15);

            radial_spines();

            if (show_core)
                hollow_fractal_core();

            if (show_tree)
                fractal_tree_crown();

            if (show_nebula)
                fractal_nebula();
        }
}

fractal_pattern();
