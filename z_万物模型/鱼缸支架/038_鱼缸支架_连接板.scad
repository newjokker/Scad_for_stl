include <BOSL2/std.scad>


// =============================================================
// 独立延伸板模块
// =============================================================

module extension_arm_standalone(
    // ---------------------------------------------------------
    // 基本尺寸
    // ---------------------------------------------------------
    arm_width = 25,              // 延伸板宽度，X方向
    arm_length = 150,            // 延伸板总长度，Y方向
    arm_thickness = 5,           // 延伸板完整区域厚度，Z方向

    // ---------------------------------------------------------
    // 端部削减参数
    // ---------------------------------------------------------
    reduce_mode = "none",        // 削减模式：
                                 // "none"  = 两端均不削减
                                 // "inner" = 仅内端削减
                                 // "outer" = 仅外端削减
                                 // "both"  = 两端均削减

    reduce_length = 25,          // 从端面向内削减的长度
    reduced_thickness = 2.5,     // 削减区域剩余厚度

    // ---------------------------------------------------------
    // 安装孔公共参数
    // ---------------------------------------------------------
    screw_diameter = 3.5,        // 所有螺丝通孔直径

    // ---------------------------------------------------------
    // 内端双孔参数
    // ---------------------------------------------------------
    inner_hole_inset = 10,       // 内端双孔中心距离内端面的距离
    inner_hole_x_offset = 6,     // 内端每个孔相对X中心线的偏移
                                 // 两孔中心距 = 2 * inner_hole_x_offset

    // ---------------------------------------------------------
    // 外端双孔参数
    // ---------------------------------------------------------
    outer_hole_inset = 10,       // 外端双孔中心距离外端面的距离
    outer_hole_x_offset = 6,     // 外端每个孔相对X中心线的偏移
                                 // 两孔中心距 = 2 * outer_hole_x_offset

    // ---------------------------------------------------------
    // 连接间隙
    // ---------------------------------------------------------
    end_gap = 0.5,               // 延伸板两端分别向内缩进的间隙
                                 // 实际长度 = arm_length - 2 * end_gap

    // ---------------------------------------------------------
    // 模型显示参数
    // ---------------------------------------------------------
    anchor = BOTTOM,             // 当前保留接口，模型主体以底面为Z=0
    hole_fn = 48                 // 圆孔分段数，越大圆孔越光滑
) {

    eps = 0.01;


    // =========================================================
    // 模式判断
    // =========================================================

    reduce_inner =
        reduce_mode == "inner" ||
        reduce_mode == "both";

    reduce_outer =
        reduce_mode == "outer" ||
        reduce_mode == "both";


    // =========================================================
    // 尺寸和坐标计算
    // =========================================================

    // 减去两端间隙后的实际长度
    effective_length =
        arm_length - 2 * end_gap;

    // 延伸板内端和外端的Y坐标
    inner_end_y =
        -effective_length / 2;

    outer_end_y =
        effective_length / 2;

    // 内端削减区域结束位置
    inner_reduce_end_y =
        inner_end_y + reduce_length;

    // 外端削减区域开始位置
    outer_reduce_start_y =
        outer_end_y - reduce_length;

    // 中间完整厚度区域起点
    full_start_y =
        reduce_inner
            ? inner_reduce_end_y
            : inner_end_y;

    // 中间完整厚度区域终点
    full_end_y =
        reduce_outer
            ? outer_reduce_start_y
            : outer_end_y;

    // 中间完整厚度区域长度
    full_length =
        full_end_y - full_start_y;

    // 内端孔中心Y坐标
    inner_hole_y =
        inner_end_y + inner_hole_inset;

    // 外端孔中心Y坐标
    outer_hole_y =
        outer_end_y - outer_hole_inset;

    // 内端孔需要切除的深度
    inner_hole_depth =
        reduce_inner
            ? reduced_thickness
            : arm_thickness;

    // 外端孔需要切除的深度
    outer_hole_depth =
        reduce_outer
            ? reduced_thickness
            : arm_thickness;


    // =========================================================
    // 参数检查
    // =========================================================

    assert(
        arm_width > 0,
        "错误：arm_width 必须大于0。"
    );

    assert(
        arm_length > 0,
        "错误：arm_length 必须大于0。"
    );

    assert(
        arm_thickness > 0,
        "错误：arm_thickness 必须大于0。"
    );

    assert(
        screw_diameter > 0,
        "错误：screw_diameter 必须大于0。"
    );

    assert(
        end_gap >= 0,
        "错误：end_gap 不能小于0。"
    );

    assert(
        effective_length > 0,
        "错误：arm_length 必须大于两倍的 end_gap。"
    );

    assert(
        reduce_length >= 0,
        "错误：reduce_length 不能小于0。"
    );

    assert(
        reduced_thickness > 0 &&
        reduced_thickness <= arm_thickness,
        "错误：reduced_thickness 必须大于0且不能超过 arm_thickness。"
    );

    assert(
        reduce_mode == "none"  ||
        reduce_mode == "inner" ||
        reduce_mode == "outer" ||
        reduce_mode == "both",
        str(
            "错误：无效的 reduce_mode：",
            reduce_mode
        )
    );

    assert(
        inner_hole_inset >= 0,
        "错误：inner_hole_inset 不能小于0。"
    );

    assert(
        outer_hole_inset >= 0,
        "错误：outer_hole_inset 不能小于0。"
    );

    assert(
        inner_hole_inset <= effective_length,
        "错误：inner_hole_inset 超出了延伸板有效长度。"
    );

    assert(
        outer_hole_inset <= effective_length,
        "错误：outer_hole_inset 超出了延伸板有效长度。"
    );

    assert(
        inner_hole_x_offset >= 0,
        "错误：inner_hole_x_offset 不能小于0。"
    );

    assert(
        outer_hole_x_offset >= 0,
        "错误：outer_hole_x_offset 不能小于0。"
    );

    // 检查内端孔是否超出板宽
    assert(
        inner_hole_x_offset + screw_diameter / 2
            <= arm_width / 2,
        str(
            "错误：内端孔超出板宽。inner_hole_x_offset=",
            inner_hole_x_offset,
            "，screw_diameter=",
            screw_diameter,
            "，arm_width=",
            arm_width
        )
    );

    // 检查外端孔是否超出板宽
    assert(
        outer_hole_x_offset + screw_diameter / 2
            <= arm_width / 2,
        str(
            "错误：外端孔超出板宽。outer_hole_x_offset=",
            outer_hole_x_offset,
            "，screw_diameter=",
            screw_diameter,
            "，arm_width=",
            arm_width
        )
    );

    // 当内端被削减时，要求内端孔位于削减区域内
    assert(
        !(reduce_inner && inner_hole_inset > reduce_length),
        str(
            "错误：内端孔不在削减区域内。inner_hole_inset=",
            inner_hole_inset,
            "，reduce_length=",
            reduce_length
        )
    );

    // 当外端被削减时，要求外端孔位于削减区域内
    assert(
        !(reduce_outer && outer_hole_inset > reduce_length),
        str(
            "错误：外端孔不在削减区域内。outer_hole_inset=",
            outer_hole_inset,
            "，reduce_length=",
            reduce_length
        )
    );

    assert(
        full_length >= 0,
        "错误：两端削减区域总长度超过了延伸板有效长度。"
    );


    // =========================================================
    // 构建延伸板
    // =========================================================

    difference() {

        union() {

            // -------------------------------------------------
            // 中间完整厚度区域
            // -------------------------------------------------
            if (full_length > 0) {
                translate([
                    0,
                    (full_start_y + full_end_y) / 2,
                    0
                ])
                    cuboid(
                        [
                            arm_width,
                            full_length,
                            arm_thickness
                        ],
                        anchor = BOTTOM
                    );
            }


            // -------------------------------------------------
            // 内端区域
            // -------------------------------------------------
            translate([
                0,
                inner_end_y + reduce_length / 2,
                0
            ])
                cuboid(
                    [
                        arm_width,
                        reduce_length,
                        reduce_inner
                            ? reduced_thickness
                            : arm_thickness
                    ],
                    anchor = BOTTOM
                );


            // -------------------------------------------------
            // 外端区域
            // -------------------------------------------------
            translate([
                0,
                outer_end_y - reduce_length / 2,
                0
            ])
                cuboid(
                    [
                        arm_width,
                        reduce_length,
                        reduce_outer
                            ? reduced_thickness
                            : arm_thickness
                    ],
                    anchor = BOTTOM
                );
        }


        // =====================================================
        // 内端双孔
        // =====================================================

        for (
            x_hole = [
                -inner_hole_x_offset,
                 inner_hole_x_offset
            ]
        ) {
            translate([
                x_hole,
                inner_hole_y,
                -eps
            ])
                cylinder(
                    h = inner_hole_depth + 2 * eps,
                    d = screw_diameter,
                    $fn = hole_fn
                );
        }


        // =====================================================
        // 外端双孔
        // =====================================================

        for (
            x_hole = [
                -outer_hole_x_offset,
                 outer_hole_x_offset
            ]
        ) {
            translate([
                x_hole,
                outer_hole_y,
                -eps
            ])
                cylinder(
                    h = outer_hole_depth + 2 * eps,
                    d = screw_diameter,
                    $fn = hole_fn
                );
        }
    }
}


// =============================================================
// 测试调用
// =============================================================

// 竖着底部连接板
translate([0, 0, 0]) 
    extension_arm_standalone(
        arm_width = 25,
        arm_length = 100,
        arm_thickness = 5,

        reduce_mode = "inner",
        reduce_length = 24,
        reduced_thickness = 2.5,

        screw_diameter = 3.5,

        inner_hole_inset = 12,
        inner_hole_x_offset = 5,

        outer_hole_inset = 15/2,
        outer_hole_x_offset = 5,

        end_gap = 0.5,
        hole_fn = 48
);

// 竖着顶端上部连接板
translate([-50, 0, 0]) 
    extension_arm_standalone(
        arm_width = 25,
        arm_length = 100,
        arm_thickness = 5,

        reduce_mode = "inner",
        reduce_length = 24,
        reduced_thickness = 2.5,

        screw_diameter = 3.5,

        inner_hole_inset = 12,
        inner_hole_x_offset = 5,

        outer_hole_inset = 12,
        outer_hole_x_offset = 5,

        end_gap = 0.5,
        hole_fn = 48
);

// 横过来的连接板
translate([-100, 0, 0]) 
    extension_arm_standalone(
        arm_width = 25,
        arm_length = 125,
        arm_thickness = 5,

        reduce_mode = "none",
        reduce_length = 24,
        reduced_thickness = 2.5,

        screw_diameter = 3.5,

        inner_hole_inset = 12,
        inner_hole_x_offset = 5,

        outer_hole_inset = 12,
        outer_hole_x_offset = 5,

        end_gap = 0.5,
        hole_fn = 48
);

// 竖着中间连接板
arm_lengths = [100, 150, 200, 250];
for (i = [0:len(arm_lengths)-1]) {
    translate([50 + (arm_lengths[i] - 100), 0, 0]) 
        extension_arm_standalone(
            arm_width = 25,
            arm_length = arm_lengths[i],
            arm_thickness = 5,

            reduce_mode = "both",
            reduce_length = 24,
            reduced_thickness = 2.5,

            screw_diameter = 3.5,

            inner_hole_inset = 12,
            inner_hole_x_offset = 5,

            outer_hole_inset = 12,
            outer_hole_x_offset = 5,

            end_gap = 0.5,
            hole_fn = 48
        );
}
