include <BOSL2/std.scad>

$fn = 256;

module phone_holder(
    total_span = 450,
    assembled = false,
    display_gap = 20
) {

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
    // 延伸板参数
    // =========================================================

    // 每根延伸板在X方向上的宽度
    arm_width = 25;

    // 延伸板整体厚度
    arm_thick = 5;

    // 两组延伸板在X方向上的位置
    // 数值越大，两组延伸板之间的距离越大
    arm_x_offset = box_length / 2 - 35;

    // 每根延伸板的长度
    //
    // total_span 表示装配后，从最上端到最下端的总跨度
    // 因为上下各有一根延伸板，所以单根延伸板长度为：
    //
    // 总跨度的一半 - 手机盒宽度的一半
    arm_length =
        total_span / 2 -
        box_width / 2;


    // =========================================================
    // 连接耳参数
    // =========================================================

    // 连接耳从手机盒向外伸出的长度
    //
    // 这个长度应大于 connection_hole_inset，
    // 否则连接孔可能超出连接耳范围
    tab_length = 24;

    // 连接耳厚度
    //
    // 连接耳与延伸板通过螺丝叠放连接，
    // 因此连接耳可以比延伸板薄
    tab_thick = 5;


    // =========================================================
    // 孔位参数
    // =========================================================

    // 所有螺丝孔的直径
    //
    // 当前为3.3mm，通常可作为M3螺丝的间隙孔
    screw_diameter = 3.5;


    // ---------------------------------------------------------
    // 靠近手机盒一端的两个连接孔
    // ---------------------------------------------------------

    // 两个连接孔距离延伸板内端的距离
    //
    // “延伸板内端”指靠近手机盒的一端。
    //
    // 例如设置为12：
    // 两个孔的圆心距离延伸板内端为12mm。
    //
    // 为了保证连接耳上的孔与延伸板上的孔对齐，
    // 连接耳上的两个孔也使用这个参数。
    connection_hole_inset = 12;

    // 两个连接孔相对于延伸板中心线的X方向偏移
    //
    // 实际两个孔的位置分别为：
    // X = -connection_hole_x_offset
    // X = +connection_hole_x_offset
    //
    // 因此两个孔圆心之间的距离为该参数的2倍。
    //
    // 当前设置为6mm，
    // 所以两个孔圆心距离为12mm。
    connection_hole_x_offset = 6;


    // ---------------------------------------------------------
    // 远离手机盒一端的两个安装孔  <-- 修改说明：参数名和注释更新
    // ---------------------------------------------------------

    // 两个孔距离延伸板外端的距离
    //
    // “延伸板外端”指远离手机盒的一端。
    //
    // 数值越大，孔越向延伸板中间移动；
    // 数值越小，孔越靠近延伸板末端。
    outer_hole_inset = 11;

    // 远离手机盒一端的两个孔相对于延伸板中心线的X方向偏移  <-- 新增参数
    //
    // 实际两个孔的位置分别为：
    // X = -outer_hole_x_offset
    // X = +outer_hole_x_offset
    //
    // 因此两个孔圆心之间的距离为该参数的2倍。
    outer_hole_x_offset = 5;  // 与连接孔使用相同的偏移量，保持视觉统一


    // =========================================================
    // 其他参数
    // =========================================================

    // 布尔运算使用的微小余量
    // 防止切孔时出现共面或残留薄片
    eps = 0.01;

    // 爆炸展示时延伸板沿Y方向移动的距离
    //
    // assembled = true：
    // 延伸板处于装配位置，不移动
    //
    // assembled = false：
    // 上方延伸板向上移动，
    // 下方延伸板向下移动
    display_offset =
        assembled ? 0 : display_gap;


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
        //
        // 手机盒边缘位置为 box_width / 2，
        // 再向连接耳内部移动 connection_hole_inset。
        //
        // side = 1 时向Y正方向移动；
        // side = -1 时向Y负方向移动。
        tab_hole_y = side * (
            box_width / 2 +
            connection_hole_inset
        );

        difference() {

            // 连接耳主体
            //
            // 连接耳宽度直接使用 arm_width，
            // 保证连接耳与延伸板宽度一致。
            translate([
                x_pos,
                tab_y,
                0
            ])
                cuboid(
                    [
                        arm_width,
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
    // 延伸板
    //
    // side = 1：
    // 位于手机盒上方，向Y正方向延伸
    //
    // side = -1：
    // 位于手机盒下方，向Y负方向延伸
    // =========================================================

    module extension_arm(x_pos, side) {

        // 装配状态下，延伸板的Y方向中心位置
        assembled_arm_y = side * (
            box_width / 2 +
            arm_length / 2
        );

        // 当前显示状态下，延伸板的Y坐标
        //
        // 装配状态时等于 assembled_arm_y；
        // 爆炸状态时继续沿side方向移动。
        arm_y =
            assembled_arm_y +
            side * display_offset;


        // -----------------------------------------------------
        // 靠近手机盒一端的两个孔的位置
        // -----------------------------------------------------

        // 延伸板内端的Y坐标为：
        //
        // arm_y - side * arm_length / 2
        //
        // 从内端向延伸板内部移动
        // connection_hole_inset 后，得到连接孔位置。
        connection_hole_y =
            arm_y -
            side * (
                arm_length / 2 -
                connection_hole_inset
            );


        // -----------------------------------------------------
        // 远离手机盒一端的两个孔的位置  <-- 修改说明：从单孔改为双孔
        // -----------------------------------------------------

        // 延伸板外端的Y坐标为：
        //
        // arm_y + side * arm_length / 2
        //
        // 从外端向延伸板内部移动
        // outer_hole_inset 后，得到外侧孔位置。
        outer_hole_y =
            arm_y +
            side * (
                arm_length / 2 -
                outer_hole_inset
            );


        difference() {

            // 延伸板主体
            //
            // 整块延伸板厚度一致，
            // 与连接耳重合的位置不再削减厚度。
            translate([
                x_pos,
                arm_y,
                0
            ])
                cuboid(
                    [
                        arm_width,
                        arm_length,
                        arm_thick
                    ],
                    anchor = BOTTOM
                );


            // -------------------------------------------------
            // 靠近手机盒一端的两个孔
            // -------------------------------------------------

            for (
                x_hole = [
                    -connection_hole_x_offset,
                    connection_hole_x_offset
                ]
            ) {

                translate([
                    x_pos + x_hole,
                    connection_hole_y,
                    -eps
                ])
                    cylinder(
                        h = arm_thick + 2 * eps,
                        d = screw_diameter,
                        $fn = 48
                    );
            }


            // -------------------------------------------------
            // 远离手机盒一端的两个孔  <-- 修改说明：从单个居中孔改为两个对称孔
            // -------------------------------------------------

            for (
                x_hole = [
                    -outer_hole_x_offset,
                    outer_hole_x_offset
                ]
            ) {

                translate([
                    x_pos + x_hole,
                    outer_hole_y,
                    -eps
                ])
                    cylinder(
                        h = arm_thick + 2 * eps,
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

    // 左右两组位置
    for (
        x_pos = [
            -arm_x_offset,
            arm_x_offset
        ]
    ) {

        // 上下两个方向
        for (side = [-1, 1]) {

            // 与手机盒连接的连接耳
            connection_tab(
                x_pos,
                side
            );

            // 延伸板
            extension_arm(
                x_pos,
                side
            );
        }
    }
}


// =============================================================
// 模型调用
// =============================================================

// 爆炸展示：
// 上方延伸板向上移动，
// 下方延伸板向下移动。
phone_holder(
    total_span = 350,
    assembled = false,
    display_gap = 40
);