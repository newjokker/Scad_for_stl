include <BOSL2/std.scad>

$fn = 256;

module phone_holder() {

    // =========================================================
    // 手机尺寸
    // =========================================================

    // 手机长度，X方向尺寸，单位：mm
    phone_length = 152;

    // 手机宽度，Y方向尺寸，单位：mm
    phone_width = 75;


    // =========================================================
    // 手机盒参数
    // =========================================================

    // 手机盒壁厚
    wall_thick = 2;

    // 手机与手机盒内壁之间的单边间隙
    // 适当留出间隙，方便手机放入和取出
    phone_gap = 1;

    // 手机盒整体高度
    box_height = 12;

    // 手机盒外部长度
    box_length =
        phone_length +
        2 * (wall_thick + phone_gap);

    // 手机盒外部宽度
    box_width =
        phone_width +
        2 * (wall_thick + phone_gap);


    // =========================================================
    // 连接耳参数
    // =========================================================

    // 每个连接耳在X方向上的宽度
    tab_width = 25;

    // 左右两组连接耳在X方向上的位置
    // 数值越大，两组连接耳之间的距离越大
    tab_x_offset = box_length / 2 - 35;

    // 连接耳从手机盒向外伸出的长度
    tab_length = 24;

    // 连接耳厚度
    tab_thick = 5;


    // =========================================================
    // 孔位参数
    // =========================================================

    // 所有螺丝孔的直径
    // 3.5mm可作为M3螺丝的间隙孔
    screw_diameter = 3.5;

    // 两个孔圆心距离手机盒边缘的距离
    // 该值必须小于 tab_length
    connection_hole_inset = 12;

    // 两个孔相对于连接耳中心线的X方向偏移
    // 两孔圆心间距 = 2 * connection_hole_x_offset
    connection_hole_x_offset = 6;


    // =========================================================
    // 其他参数
    // =========================================================

    // 布尔运算使用的微小余量
    // 防止切孔时出现共面或残留薄片
    eps = 0.01;


    // =========================================================
    // 手机盒
    // =========================================================

    module phone_box() {

        difference() {

            // 手机盒主体
            cuboid(
                [
                    box_length,
                    box_width,
                    box_height
                ],
                anchor = BOTTOM
            );

            // 手机内部空间
            translate([
                0,
                0,
                wall_thick
            ])
                cuboid(
                    [
                        phone_length + 2 * phone_gap,
                        phone_width + 2 * phone_gap,
                        box_height + eps
                    ],
                    anchor = BOTTOM
                );

            // 取手机缺口
            translate([
                box_length / 2 - 25,
                0,
                -eps
            ])
                cylinder(
                    h = box_height + 2 * eps,
                    r = 20,
                    $fn = 96
                );
        }
    }


    // =========================================================
    // 连接耳
    // =========================================================

    module connection_tab(x_pos, side) {

        // 连接耳主体的Y方向中心位置
        tab_y = side * (
            box_width / 2 +
            tab_length / 2
        );

        // 连接耳上两个孔的Y坐标
        tab_hole_y = side * (
            box_width / 2 +
            connection_hole_inset
        );

        difference() {

            // 连接耳主体
            translate([
                x_pos,
                tab_y,
                0
            ])
                cuboid(
                    [
                        tab_width,
                        tab_length,
                        tab_thick
                    ],
                    anchor = BOTTOM
                );

            // 连接耳上的两个螺丝孔
            for (
                x_hole = [
                    -connection_hole_x_offset,
                    connection_hole_x_offset
                ]
            ) {

                translate([
                    x_pos + x_hole,
                    tab_hole_y,
                    -eps
                ])
                    cylinder(
                        h = tab_thick + 2 * eps,
                        d = screw_diameter,
                        $fn = 48
                    );
            }
        }
    }


    // =========================================================
    // 模型组合
    // =========================================================

    // 中间手机盒
    phone_box();

    // 左右两组连接耳
    for (
        x_pos = [
            -tab_x_offset,
            tab_x_offset
        ]
    ) {

        // 手机盒上下两侧
        for (side = [-1, 1]) {

            connection_tab(
                x_pos,
                side
            );
        }
    }
}


// =============================================================
// 模型调用
// =============================================================

phone_holder();
