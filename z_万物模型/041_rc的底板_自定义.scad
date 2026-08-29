// R1四驱车底盘安装孔位 - 由 DWG 孔位图转换
// 来源: R1四驱小车板件孔位【孔位图】.dwg
// 坐标基准: B版视图中心近似为 [1324.272, 252.067]，单位按 DWG 毫米处理。

plate_thickness = 2.5;      // [1:0.5:6] 底板厚度
$fn = 72;

motor_hole_radius = 1.6;
motor_bracket_length = 64;
motor_bracket_width = 17;
motor_bracket_y_distance = 108;
front_bracket_y =55;
rear_bracket_y = front_bracket_y - motor_bracket_y_distance;

// 四个穿线孔共用的尺寸参数。
wire_hole_length = 20;       // [10:1:50] 长孔总长度
wire_hole_width = 7;         // [3:0.5:15] 长孔总宽度
wire_hole_corner_radius = 2; // [0.5:0.5:3.5] 圆角半径

// 左右两个竖直穿线孔的位置（关于 Y 轴对称）。
vertical_wire_hole_x = 40;   // 孔中心到 Y 轴的距离
vertical_wire_hole_y = -5;  // 两个竖孔的中心 Y 坐标

// 底部两个水平穿线孔的位置（关于 Y 轴对称）。
horizontal_wire_hole_x = 15; // 孔中心到 Y 轴的距离
horizontal_wire_hole_y = -71;// 两个横孔的中心 Y 坐标

// B版底板外轮廓。曲边由 DWG 折线化，保留可编辑坐标。
outline_points = [
    [-29.069, 90.000], [29.070, 90.000], [49.930, 72.278],
    [46.834, 34.364], [59.166, 11.212], [58.127, 3.414],
    [50.774, -40.586], [50.139, -44.957], [49.607, -49.727],
    [49.240, -54.513], [49.041, -59.308], [49.008, -64.108],
    [49.141, -68.906], [49.441, -73.696], [49.907, -78.473],
    [50.540, -83.235], [38.259, -90.000], [0.000, -83.235],
    [-38.259, -90.000], [-50.540, -83.235], [-49.948, -78.825],
    [-49.470, -74.049], [-49.157, -69.259], [-49.012, -64.462],
    [-49.032, -59.662], [-49.220, -54.866], [-49.574, -50.079],
    [-50.094, -45.308], [-50.779, -40.557], [-59.089, 10.737],
    [-46.834, 34.364], [-49.928, 72.278]
];

module r1_4wd_base_plate() {
    difference() {
        linear_extrude(plate_thickness)
            polygon(points = outline_points);

        motor_bracket_holes();
        wire_holes();
    }
}

// 前后两个电机/轮胎支架，每个支架四个贯穿孔。
module motor_bracket_holes() {
    for (bracket_y = [front_bracket_y, rear_bracket_y])
        for (x = [-motor_bracket_length / 2, motor_bracket_length / 2])
            for (y = [-motor_bracket_width / 2, motor_bracket_width / 2])
                translate([x, bracket_y + y, -0.1])
                    cylinder(
                        h = plate_thickness + 0.2,
                        r = motor_hole_radius
                    );
}

// 尺寸精确为 wire_hole_length × wire_hole_width 的圆角长孔。
module wire_hole_2d() {
    offset(r = wire_hole_corner_radius)
        square([
            wire_hole_length - 2 * wire_hole_corner_radius,
            wire_hole_width - 2 * wire_hole_corner_radius
        ], center = true);
}

module wire_holes() {
    // 左右两个竖孔。
    for (x = [-vertical_wire_hole_x, vertical_wire_hole_x])
        translate([x, vertical_wire_hole_y, -0.1])
            linear_extrude(plate_thickness + 0.2)
                rotate(90)
                    wire_hole_2d();

    // 底部两个横孔。
    for (x = [-horizontal_wire_hole_x, horizontal_wire_hole_x])
        translate([x, horizontal_wire_hole_y, -0.1])
            linear_extrude(plate_thickness + 0.2)
                wire_hole_2d();
}

r1_4wd_base_plate();
