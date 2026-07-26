include <../NopSCADlib/lib.scad>
include <BOSL2/std.scad>

$fn=256;

// ===== 铝型材端盖参数 =====
fit_clearance_per_side = 0.1;
extrusion_type = E2020;
insert_depth = 7;
cap_total_thickness = 15;


assert(insert_depth > 0 && insert_depth < cap_total_thickness, "插入深度应介于 0 和端盖总厚度之间");

// 端盖在插入深度内原本会留下的实体（即型材槽、中心孔等位置的插入凸台）。
module insert_profile_2d() {
    difference() {
        square([extrusion_width(extrusion_type), extrusion_height(extrusion_type)], center=true);
        extrusion_cross_section(extrusion_type);
    }
}

// 对插入实体作负偏置，等同于二维“腐蚀”：
// 外轮廓向内退让，同时槽/孔周围的凸台也会缩小，避免只放大凹槽而使凸台变紧。
module eroded_insert_profile_2d(clearance) {
    offset(delta=-clearance)
        insert_profile_2d();
}

// 生成一个端盖。clearance 为单边公差：正数更松，负数更紧。
module aluminium_cap(clearance=fit_clearance_per_side) {
    assert(clearance >= -0.20 && clearance <= 0.50,
           "单边公差建议保持在 -0.20 至 0.50 mm 之间");
    if (clearance >= 0) {
        difference() {
            cuboid([20, 20, cap_total_thickness], anchor=[0, 0, -1], rounding=1.2, edges=[LEFT + FRONT, RIGHT + FRONT, LEFT + BACK, RIGHT + BACK, TOP]);

            // 保持端盖外观尺寸不变，先生成原始型材配合腔。
            extrusion(extrusion_type, insert_depth, center=false);

            // 仅移除插入部分“腐蚀”前后多出的材料；顶部外观端面不受影响。
            // 安装单边间隙为 0 时，此差集为空，得到原始严丝合缝尺寸。
            linear_extrude(height=insert_depth, convexity=8)
                difference() {
                    insert_profile_2d();
                    eroded_insert_profile_2d(clearance);
                }
        }
    } else {
        // 负数用于测试更紧的配合：把插入凸台向外扩张。
        union() {
            difference() {
                cuboid([20, 20, cap_total_thickness], anchor=[0, 0, -1], rounding=1.2, edges=[LEFT + FRONT, RIGHT + FRONT, LEFT + BACK, RIGHT + BACK, TOP]);
                extrusion(extrusion_type, insert_depth, center=false);
            }
            linear_extrude(height=insert_depth, convexity=8)
                eroded_insert_profile_2d(clearance);
        }
    }
}


aluminium_cap();