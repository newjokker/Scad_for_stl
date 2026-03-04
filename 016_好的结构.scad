/****************************************************
 * Helical Strip + Reference Shell + Quarter Cutout
 * Refactor / Standardized Version
 * --------------------------------------------------
 * - All key parameters are collected in params()
 * - Clear module responsibilities
 * - Avoid coplanar artifacts using eps
 ****************************************************/

$fn = 90;   // 圆形分段数：越大越圆，但渲染越慢

// =========================
// Global small epsilon
// =========================
eps = 0.01; // 用于避免差集共面/重合导致的“闪面/破面”


// =========================
// Parameter Center
// 只改这里即可驱动整体结构
// =========================
module params(){
    // 主体高度
    H_main = 50;

    // 外壳尺寸（参考圆筒）
    D_outer = 100;   // 外径（外圆柱）
    D_outer_inner = 99;  // 外圆柱的内径（形成薄壁）

    // 内孔尺寸（中心孔）
    D_inner = 46;    // 内圆柱外径（形成一个内环壳）
    D_inner_hole = 44; // 内圆柱内径（镂空）

    // 螺旋参数
    turns   = 2;      // 螺旋圈数
    strip_t = 1;      // 螺旋带厚度（切向方向）
    strip_w = (D_outer - D_inner_hole) / 2; // 你的写法保留：沿半径方向宽度
    R_helix = 36;     // 螺旋带截面中心离原点的半径

    // 四分之一圆环切除体（C）
    ring_h  = 3;
    ring_od = 50;
    ring_id = 40;

    // “只保留 1/4” 的裁剪方块
    cutter_size_xy = 60;  // 方块边长（越大越保险）
    cutter_size_z  = 50;
    cutter_rot_z   = -25; // 你原来是 -25 度
}


// =========================
// Module: Helical Strip
// - linear_extrude + twist
// - square is 2D profile
// =========================
module helix_strip(H, turns, R, strip_w, strip_t, twist_dir = -1, slices = 300){
    // twist_dir: -1 逆/顺由你决定；这里默认沿用你原来的负方向
    linear_extrude(
        height = H,
        twist  = twist_dir * 360 * turns,
        slices = slices
    )
    translate([R, 0])
        square([strip_w, strip_t], center = true);
}


// =========================
// Module: Reference Shell
// - Two hollow cylinders (inner ring + outer ring)
// - Used as a "housing" to visualize where helix sits
// =========================
module shell_reference(H, D_outer, D_outer_inner, D_inner, D_inner_hole){
    color([1, 0.5, 0.5, 0.5]) {

        // ---- Inner ring shell (around 44~46)
        difference(){
            cylinder(h = H, d = D_inner, center = false);
            translate([0,0,-2]) cylinder(h = H + 10, d = D_inner_hole, center = false);
        }

        // ---- Outer ring shell (around 99~100) with center hole cleared
        difference(){
            cylinder(h = H, d = D_outer, center = false);

            // hollow wall
            translate([0,0, 2]) cylinder(h = H + 20, d = D_outer_inner, center = false);

            // clear center hole fully (avoid leaving inner material)
            translate([0,0,-20]) cylinder(h = H + 60, d = D_inner_hole, center = false);
        }
    }
}


// =========================
// Module: Quarter Ring (as a cutter volume)
// - Generates a ring and keeps only 1/4 (by intersection with a cube)
// - Intended to be SUBTRACTED from the shell
// =========================
module quarter_ring_cutter(ring_h, ring_od, ring_id, cutter_size_xy, cutter_size_z, cutter_rot_z){
    color([1, 1, 0, 0.5]) {

        intersection(){
            // ---- ring body
            translate([0,0,1])  // 沿用你原来的 Z 偏移
            difference(){
                cylinder(h = ring_h, d = ring_od, center = false);
                translate([0,0,-2]) cylinder(h = ring_h + 10, d = ring_id, center = false);
            }

            // ---- keep only one quadrant using a cube (X>0, Y>0 region)
            // 注意：cube 默认从角点开始（非 center），所以放在原点即可保留“第一象限”
            rotate([0,0,cutter_rot_z])
            translate([0,0,-10])
                cube([cutter_size_xy, cutter_size_xy, cutter_size_z], center = false);
        }
    }
}


// =========================
// Scene Assembly
// - shell minus quarter_ring_cutter
// - plus helix strip
// =========================
module scene(){
    // 读取参数（用局部变量接收，方便传参）
    // OpenSCAD 没有真正的“返回值”，这里用同名变量约定即可。
    params();

    // 你可以在这里快速调整：显示/隐藏参考壳
    show_shell = true;
    show_helix = true;
    do_cutout  = true;

    // 1) Outer/Inner shell
    if(show_shell){
        difference(){
            shell_reference(H_main, D_outer, D_outer_inner, D_inner, D_inner_hole);

            // 2) subtract the quarter ring cutout
            if(do_cutout){
                // eps 用在 Z 方向略扩展，避免差集边界“贴面”
                translate([0,0,-eps])
                    quarter_ring_cutter(ring_h + 2*eps, ring_od, ring_id,
                                        cutter_size_xy, cutter_size_z, cutter_rot_z);
            }
        }
    }

    // 3) helix strip
    if(show_helix){
        helix_strip(H_main, turns, R_helix, strip_w, strip_t, twist_dir = -1, slices = 300);
    }
}


// =========================
// Run
// =========================
scene();