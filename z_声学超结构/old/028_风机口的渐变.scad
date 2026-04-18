include <BOSL2/std.scad>
include <BOSL2/structs.scad>

$fn = 128;

// ================= 参数 =================
wall_thickness = 2;

rect_length = 55 - wall_thickness * 2;                               // 矩形长边
rect_width  = 46.5 - wall_thickness *2;                             // 矩形短边
diameter    = 120 - wall_thickness * 2;         // 圆管内径

rect_stub_h  = 30;   // 底部矩形直段高度
blend_height = 100;  // 过渡段高度
round_stub_h = 40;   // 顶部圆管直段高度

corner_r = 12;       // 矩形圆角半径，建议 8~15


// ================= 圆角矩形截面 =================
module rounded_rect_2d(l=100, w=50, r=8) {
    r_use = min(r, l/2 - 0.01, w/2 - 0.01);
    offset(r = r_use)
        square([l - 2*r_use, w - 2*r_use], center=true);
}


// ================= 单层流道外形/内形 =================
module pip_transformer(
    rect_length = 205,
    rect_width  = 100,
    diameter    = 156,
    rect_stub_h = 20,
    blend_height = 145,
    round_stub_h = 60,
    corner_r = 12
) {
    union() {
        // 1) 底部矩形直段
        linear_extrude(height = rect_stub_h)
            rounded_rect_2d(rect_length, rect_width, corner_r);

        // 2) 渐变段
        hull() {
            translate([0, 0, rect_stub_h])
                linear_extrude(height = 0.01)
                    rounded_rect_2d(rect_length, rect_width, corner_r);

            translate([0, 0, rect_stub_h + blend_height])
                linear_extrude(height = 0.01)
                    circle(d = diameter);
        }

        // 3) 顶部圆管直段
        translate([0, 0, rect_stub_h + blend_height])
            cylinder(h = round_stub_h, d = diameter, center = false);
    }
}

// ================= 中空转换器 =================
difference() {
    // 外轮廓
    pip_transformer(
        rect_length  = rect_length + 2*wall_thickness,
        rect_width   = rect_width  + 2*wall_thickness,
        diameter     = diameter    + 2*wall_thickness,
        rect_stub_h  = rect_stub_h,
        blend_height = blend_height,
        round_stub_h = round_stub_h,
        corner_r     = corner_r + wall_thickness
    );

    // 内流道
    pip_transformer(
        rect_length  = rect_length,
        rect_width   = rect_width,
        diameter     = diameter,
        rect_stub_h  = rect_stub_h,
        blend_height = blend_height,
        round_stub_h = round_stub_h,
        corner_r     = corner_r
    );
}


// ===================== 参数 =====================
cell_r      = 8;     // 六边形“外接圆半径”，也可理解为单元尺寸
wall_t      = 0.8;   // 蜂窝壁厚
rows        = 35;     // 行数
cols        = 35;     // 列数
height      = 12.7;    // 蜂窝高度

// ===================== 基本六边形 =====================
module hex2d(r=10) {
    polygon(points=[
        for (i=[0:5]) [r*cos(60*i), r*sin(60*i)]
    ]);
}

// 单个蜂窝壁
module honeycomb_cell_3d(r=10, t=1, h=10) {
    rotate([0, 0, 30])
        linear_extrude(height=h)
            difference() {
                hex2d(r);
                offset(delta=-t) hex2d(r);
            }
}

// 蜂窝阵列（带盖子）
module honeycomb_core(r=10, t=1, rows=5, cols=6,  h=10) {
    dx = sqrt(3) * (r - t/2);        // 同列中心的 x 间距
    dy = 1.5 * (r - t/2);            // 行间距

    union() {
        for (row = [0:rows-1]) {
            for (col = [0:cols-1]) {
                x = col * dx + (row % 2) * dx / 2;
                y = row * dy;
                translate([x, y, 0])
                    honeycomb_cell_3d(r, wall_t, h);
            }
        }
    }
}


thick = 2;
r = 120/2;


translate([0, 0, 170])
{
    difference(){
        cylinder(r=r, h=height, center=false);
        translate([0, 0, -0.01])
        cylinder(r=r - thick , h=height + 0.02, center=false);
    }

    intersection(){
        translate([-100, -100, 0])
            honeycomb_core(r=cell_r, t=wall_t, rows=rows, cols=cols, h=height);
        
        cylinder(r=r, h=height, center=false);
    }
}


