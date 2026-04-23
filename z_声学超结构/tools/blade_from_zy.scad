$fn = 80;

// NACA 四位数半厚度分布
function naca_thickness(x, t) =
    5 * t * (
        0.2969 * sqrt(x)
      - 0.1260 * x
      - 0.3516 * x * x
      + 0.2843 * x * x * x
      - 0.1036 * x * x * x * x
    );

// 中弧线 yc
function camber_y(x, m, p) =
    (x <= p)
    ? m / (p * p) * (2 * p * x - x * x)
    : m / ((1 - p) * (1 - p)) * ((1 - 2 * p) + 2 * p * x - x * x);

// 中弧线斜率 dyc/dx
function camber_dy(x, m, p) =
    (x <= p)
    ? 2 * m / (p * p) * (p - x)
    : 2 * m / ((1 - p) * (1 - p)) * (p - x);

// 上表面单点
function airfoil_upper_pt(x, m, p, t, chord) =
    let(
        yc = camber_y(x, m, p),
        dyc = camber_dy(x, m, p),
        yt = naca_thickness(x, t),
        theta = atan(dyc),
        xu = x - yt * sin(theta),
        yu = yc + yt * cos(theta)
    )
    [xu * chord, yu * chord];

// 下表面单点
function airfoil_lower_pt(x, m, p, t, chord) =
    let(
        yc = camber_y(x, m, p),
        dyc = camber_dy(x, m, p),
        yt = naca_thickness(x, t),
        theta = atan(dyc),
        xl = x + yt * sin(theta),
        yl = yc - yt * cos(theta)
    )
    [xl * chord, yl * chord];

// 中弧线单点
function airfoil_camber_pt(x, m, p, chord) =
    [x * chord, camber_y(x, m, p) * chord];

// 上表面点集：前缘 -> 尾缘
function airfoil_upper_points(m, p, t, num_points, chord) =
    [ for (i = [0 : num_points])
        airfoil_upper_pt(i / num_points, m, p, t, chord)
    ];

// 下表面点集：尾缘 -> 前缘
function airfoil_lower_points_rev(m, p, t, num_points, chord) =
    [ for (i = [num_points : -1 : 0])
        airfoil_lower_pt(i / num_points, m, p, t, chord)
    ];

// 封闭翼型点集
function airfoil_polygon_points(m, p, t, num_points, chord) =
    concat(
        airfoil_upper_points(m, p, t, num_points, chord),
        airfoil_lower_points_rev(m, p, t, num_points, chord)
    );

// 中弧线点集
function airfoil_camber_points(m, p, num_points, chord) =
    [ for (i = [0 : num_points])
        airfoil_camber_pt(i / num_points, m, p, chord)
    ];



// =======================================================
// 子模块
// =======================================================

// 2D 截面
module airfoil_2d_profile(
    m = 0.06,
    p = 0.40,
    t = 0.12,
    num_points = 180,
    chord = 100
) {
    polygon(points = airfoil_polygon_points(m, p, t, num_points, chord));
}

// 2D 中弧线（用小圆点表示）
module airfoil_2d_camber_line(
    m = 0.06,
    p = 0.40,
    num_points = 180,
    chord = 100,
    dot_r = 0.35
) {
    pts = airfoil_camber_points(m, p, num_points, chord);
    for (pt = pts) {
        translate(pt) circle(r = dot_r);
    }
}

// 3D 拉伸版本
module airfoil_3d_profile(
    m = 0.06,
    p = 0.40,
    t = 0.12,
    num_points = 180,
    chord = 100,
    width = 20,
    center = true
) {
    linear_extrude(height = width, center = center)
        airfoil_2d_profile(
            m = m,
            p = p,
            t = t,
            num_points = num_points,
            chord = chord
        );
}



// =======================================================
// 主模块
// mode:
//   "2d"      -> 只画二维截面
//   "2d+c"    -> 画二维截面 + 中弧线
//   "3d"      -> 拉伸成三维
// =======================================================
module centrifugal_blade_airfoil(
    m = 0.06,
    p = 0.40,
    t = 0.12,
    num_points = 180,
    chord = 100,
    mode = "2d+c",
    width = 20,
    camber_dot_r = 0.35,
    center_3d = true
) {
    if (mode == "2d") {
        airfoil_2d_profile(
            m = m,
            p = p,
            t = t,
            num_points = num_points,
            chord = chord
        );
    }
    else if (mode == "2d+c") {
        airfoil_2d_profile(
            m = m,
            p = p,
            t = t,
            num_points = num_points,
            chord = chord
        );

        airfoil_2d_camber_line(
            m = m,
            p = p,
            num_points = num_points,
            chord = chord,
            dot_r = camber_dot_r
        );
    }
    else if (mode == "3d") {
        airfoil_3d_profile(
            m = m,
            p = p,
            t = t,
            num_points = num_points,
            chord = chord,
            width = width,
            center = center_3d
        );
    }
}


color("silver")
    centrifugal_blade_airfoil(
        m = 0.06,
        p = 0.40,
        t = 0.12,
        num_points = 200,
        chord = 28,
        mode = "3d",
        width = 2,
        center_3d = false
    );
