include <BOSL2/std.scad>


module phone_holder(
    total_span = 450,
    assembled = false,
    display_gap = 20
) {

    // 手机尺寸
    phone_length = 152;
    phone_width  = 75;

    // 手机盒参数
    wall_thick = 2;
    phone_gap = 1;
    box_height = 12;

    box_length = phone_length + 2 * wall_thick + 2 * phone_gap;
    box_width  = phone_width  + 2 * wall_thick + 2 * phone_gap;

    inner_length = phone_length + 2 * phone_gap;
    inner_width  = phone_width  + 2 * phone_gap;

    // 连接耳参数
    tab_width  = 25;
    tab_length = 20;
    tab_thick  = 2.5;

    tab_x_offset = box_length / 2 - 30;

    // 延伸板参数
    arm_width = 25;
    arm_thick = 5;

    // 装配状态下总跨度为450mm
    arm_length = total_span / 2 - box_width / 2;

    slot_depth = tab_thick;
    slot_clearance = 0.25;

    // 螺丝孔参数
    screw_diameter = 3.3;
    screw_radius = screw_diameter / 2;
    hole_offset = 6;

    eps = 0.01;

    // 展示时只沿Y方向移动
    display_offset = assembled ? 0 : display_gap;


    // =========================================================
    // 手机盒
    // =========================================================
    module phone_box() {

        difference() {

            cuboid(
                [box_length, box_width, box_height],
                anchor = BOTTOM
            );

            // 手机内部空间
            translate([0, 0, wall_thick])
                cuboid(
                    [
                        inner_length,
                        inner_width,
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

        tab_y = side * (
            box_width / 2 +
            tab_length / 2
        );

        difference() {

            translate([x_pos, tab_y, 0])
                cuboid(
                    [tab_width, tab_length, tab_thick],
                    anchor = BOTTOM
                );

            for (x_hole = [-hole_offset, hole_offset]) {

                translate([
                    x_pos + x_hole,
                    tab_y,
                    -eps
                ])
                    cylinder(
                        h = tab_thick + 2 * eps,
                        r = screw_radius,
                        $fn = 48
                    );
            }
        }
    }


    // =========================================================
    // 延伸板
    // side = 1：向上移动
    // side = -1：向下移动
    // X方向不发生任何变化
    // =========================================================
    module extension_arm(x_pos, side) {

        assembled_arm_y = side * (
            box_width / 2 +
            arm_length / 2
        );

        // 只改变Y坐标
        display_arm_y =
            assembled_arm_y +
            side * display_offset;

        // 凹槽在延伸板靠近手机盒的一端
        slot_local_y =
            -side * (
                arm_length / 2 -
                tab_length / 2
            );

        difference() {

            // 延伸板主体
            translate([
                x_pos,
                display_arm_y,
                0
            ])
                cuboid(
                    [arm_width, arm_length, arm_thick],
                    anchor = BOTTOM
                );

            // 连接耳安装槽
            translate([
                x_pos,
                display_arm_y + slot_local_y,
                -eps
            ])
                cuboid(
                    [
                        tab_width + slot_clearance,
                        tab_length + slot_clearance,
                        slot_depth + eps
                    ],
                    anchor = BOTTOM
                );

            // 螺丝孔
            for (x_hole = [-hole_offset, hole_offset]) {

                translate([
                    x_pos + x_hole,
                    display_arm_y + slot_local_y,
                    -eps
                ])
                    cylinder(
                        h = arm_thick + 2 * eps,
                        r = screw_radius,
                        $fn = 48
                    );
            }
        }
    }


    // 手机盒
    phone_box();

    // 四个连接耳和四根延伸板
    for (x_pos = [-tab_x_offset, tab_x_offset]) {

        for (side = [-1, 1]) {

            connection_tab(x_pos, side);

            extension_arm(x_pos, side);
        }
    }
}


// 爆炸展示：上面的板向上，下面的板向下
phone_holder(
    total_span = 350,
    assembled = false,
    display_gap = 40
);



