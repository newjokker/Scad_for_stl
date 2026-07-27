/*
  铝型材端盖（NopSCADlib 版）
  依赖同级目录中的 ../NopSCADlib 与 OpenSCAD 库路径中的 BOSL2。
*/
include <../NopSCADlib/lib.scad>
include <BOSL2/std.scad>

/* [端盖尺寸 / End Cap Size] */

// 铝型材规格（NopSCADlib 内置的全部常用型号）
extrusion_profile = "E2020"; // [Makerbeam, MakerbeamXL, E1515, E2020, E2020t, E2040, E2060, E2080, E3030, E3060, E4040, E4040t, E4080]

// 插入铝型材端面的深度，单位 mm
insert_depth = 5;             // [1:0.5:30]

// 端盖露出型材外的深度（可见厚度），单位 mm
exposed_depth = 5;            // [1:0.5:30]

// 溃缩尺寸 mm 
fit_clearance_per_side = 0.10;  // [0:0.05:0.3]

// 圆角弧度
corner_rounding = 1;  // [0:0.5:4]

/* [Hidden] */

// 固定单边安装公差；正值使插入凸台缩小，更容易安装。
model_resolution = 128;

// 在端盖前侧凹刻实际使用的单边配合间隙，便于区分不同尺寸的打印件。
clearance_label_depth = 0.35;

// 根据上方下拉选项选择 NopSCADlib 中的铝型材数据。
extrusion_type =
    extrusion_profile == "Makerbeam"   ? Makerbeam :
    extrusion_profile == "MakerbeamXL" ? MakerbeamXL :
    extrusion_profile == "E1515"       ? E1515 :
    extrusion_profile == "E2020"       ? E2020 :
    extrusion_profile == "E2020t"      ? E2020t :
    extrusion_profile == "E2040"       ? E2040 :
    extrusion_profile == "E2060"       ? E2060 :
    extrusion_profile == "E2080"       ? E2080 :
    extrusion_profile == "E3030"       ? E3030 :
    extrusion_profile == "E3060"       ? E3060 :
    extrusion_profile == "E4040"       ? E4040 :
    extrusion_profile == "E4040t"      ? E4040t : E4080;

$fn = model_resolution;
cap_total_thickness = insert_depth + exposed_depth;
clearance_label = str(fit_clearance_per_side, " mm");
clearance_label_size = min(
    exposed_depth * 0.6,
    extrusion_width(extrusion_type) / 6.5
);

assert(insert_depth > 0, "插入深度必须大于 0");
assert(exposed_depth > 0, "露出深度必须大于 0");
assert(fit_clearance_per_side >= 0, "单边配合间隙不能小于 0");

// 端盖在插入深度内保留的实体：填入型材槽、中心孔等位置的凸台。
module insert_profile_2d() {
    difference() {
        square([extrusion_width(extrusion_type), extrusion_height(extrusion_type)], center=true);
        extrusion_cross_section(extrusion_type);
    }
}

// 对插入实体作负偏置（二维“腐蚀”）：外轮廓和槽内凸台都会缩小。
module eroded_insert_profile_2d() {
    offset(delta=-fit_clearance_per_side)
        insert_profile_2d();
}

// 在前侧外露段凹刻单边配合间隙，例如 “FIT 0.1 mm”。
module clearance_label_engraving() {
    translate([
        0,
        -extrusion_height(extrusion_type) / 2,
        insert_depth + exposed_depth / 2
    ])
        rotate([90, 0, 0])
            linear_extrude(height=clearance_label_depth, center=true, convexity=4)
                text(
                    clearance_label,
                    size=clearance_label_size,
                    halign="center",
                    valign="center"
                );
}

// 端盖外形与所选型材的宽、高自动匹配；总厚度 = 插入深度 + 露出深度。
module aluminium_cap() {
    difference() {
        cuboid(
            [extrusion_width(extrusion_type), extrusion_height(extrusion_type), cap_total_thickness],
            anchor=[0, 0, -1],
            rounding=corner_rounding,
            edges=[LEFT + FRONT, RIGHT + FRONT, LEFT + BACK, RIGHT + BACK, TOP]
        );

        // 原始型材配合腔。
        extrusion(extrusion_type, insert_depth, center=false);

        // 仅缩小插入部分，露出型材外的端盖外观尺寸不变。
        linear_extrude(height=insert_depth, convexity=8)
            difference() {
                insert_profile_2d();
                eroded_insert_profile_2d();
            }

        clearance_label_engraving();
    }
}

aluminium_cap();
