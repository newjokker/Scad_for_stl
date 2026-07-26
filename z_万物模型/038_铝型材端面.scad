include <../NopSCADlib/lib.scad>
include <BOSL2/std.scad>

/* [端盖尺寸 / End Cap Size] */

// 插入铝型材端面的深度，单位 mm
insert_depth = 7;          // [1:0.5:20]

// 端盖露出型材外的深度（可见厚度），单位 mm
exposed_depth = 8;         // [1:0.5:20]

// 单边安装公差；正值使配合更松。
fit_clearance_per_side = 0.10; // [0:0.05:0.3]

/* [Hidden] */

// 以下项目为模型固定设置；在拓竹 Customizer 中不显示。
extrusion_type = E2020;
corner_rounding = 1.2;
model_resolution = 128;

$fn = model_resolution;
cap_total_thickness = insert_depth + exposed_depth;

assert(insert_depth > 0, "插入深度必须大于 0");
assert(exposed_depth > 0, "露出深度必须大于 0");

// 插入型材槽、中心孔等位置的凸台截面。
module insert_profile_2d() {
    difference() {
        square([extrusion_width(extrusion_type), extrusion_height(extrusion_type)], center=true);
        extrusion_cross_section(extrusion_type);
    }
}

// 对插入凸台做负偏置（二维“腐蚀”），形成固定的安装公差。
module eroded_insert_profile_2d() {
    offset(delta=-fit_clearance_per_side)
        insert_profile_2d();
}

// 端盖外观尺寸跟随 E2020 截面；总深度由“插入深度 + 露出深度”自动计算。
module aluminium_cap() {
    difference() {
        cuboid(
            [extrusion_width(extrusion_type), extrusion_height(extrusion_type), cap_total_thickness],
            anchor=[0, 0, -1],
            rounding=corner_rounding,
            edges=[LEFT + FRONT, RIGHT + FRONT, LEFT + BACK, RIGHT + BACK, TOP]
        );

        // 保持外观不变，只对插入型材的前 insert_depth mm 生成配合结构。
        extrusion(extrusion_type, insert_depth, center=false);

        // 移除“腐蚀”前后多出的材料：外侧与槽内凸台都会退让 0.10 mm。
        linear_extrude(height=insert_depth, convexity=8)
            difference() {
                insert_profile_2d();
                eroded_insert_profile_2d();
            }
    }
}

aluminium_cap();
