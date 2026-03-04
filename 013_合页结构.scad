// =======================================
// Print-in-place Butt Hinge (like photo)
// - Rounded leaves
// - 2 holes per leaf
// - 3 knuckles (2+1 interleaved)
// - Built-in pin (no separate metal pin)
// =======================================
$fn = 96;

// ---------- Main size ----------
leaf_L = 28;          // 合页总长度（沿轴向）
leaf_W = 18;          // 单片叶宽（从轴到外侧）
leaf_T = 2.6;         // 叶片厚度
corner_R = 3.0;       // 叶片圆角半径

// ---------- Hinge barrel / pin ----------
barrel_OD  = 7.0;     // 合页筒外径
pin_D      = 3.2;     // 内置销轴直径
gap_radial = 0.30;    // 销轴与筒孔径向间隙（防卡）
gap_axial  = 0.45;    // 筒段之间轴向间隙（防粘）
end_margin = 1.0;     // 两端留边
knuckle_n  = 3;       // 3 段：2+1 交错（跟图一致）

// ---------- Screw holes ----------
hole_D = 3.4;
hole_x_from_axis = 12.0;   // 孔中心离轴线距离（调到接近图里位置）
hole_y_offset = 7.2;       // 孔距端面

// ---------- View ----------
show_photo_pose = true;    // true: 立起来看像照片；false: 平放更适合打印

// ---------- Derived ----------
barrel_R = barrel_OD/2;
pin_R    = pin_D/2;
hole_R   = pin_R + gap_radial;

usable_L  = leaf_L - 2*end_margin;
knuckle_L = (usable_L - (knuckle_n-1)*gap_axial)/knuckle_n;

// ---------- Utility: rounded rectangle plate ----------
module rounded_plate(w, l, t, r){
    // plate in XY, thickness in Z
    // axis edge at x=0, outward to x=w
    // length along y: 0..l
    hull(){
        translate([r,     r,     0]) cylinder(h=t, r=r);
        translate([w-r,   r,     0]) cylinder(h=t, r=r);
        translate([r,     l-r,   0]) cylinder(h=t, r=r);
        translate([w-r,   l-r,   0]) cylinder(h=t, r=r);
    }
}

// ---------- Leaf with two holes ----------
module leaf(side=0){
    // side=0: left leaf (x<0), side=1: right leaf (x>0)
    x0 = (side==0) ? -leaf_W : 0;

    difference(){
        translate([x0, 0, 0])
            rounded_plate(leaf_W, leaf_L, leaf_T, corner_R);

        // 2 holes
        for (yy = [hole_y_offset, leaf_L - hole_y_offset]){
            translate([ (side==0) ? (x0 + (leaf_W - (leaf_W - hole_x_from_axis))) : (0 + (leaf_W - (leaf_W - hole_x_from_axis))),
                        yy, -0.2])
                cylinder(h=leaf_T + 0.4, r=hole_D/2);
        }
    }
}

// ---------- Built-in pin (solid rod) ----------
module built_in_pin(){
    // Pin axis along Y at x=0, centered in thickness
    translate([0, leaf_L/2, leaf_T/2])
        rotate([90,0,0])
            cylinder(h=leaf_L, r=pin_R, center=true);
}

// ---------- One knuckle segment (hollow sleeve) ----------
module knuckle_segment(y0, len, side=0){
    // Hollow barrel around the pin
    // side=0: attach to left leaf (x<0)
    // side=1: attach to right leaf (x>0)
    translate([0, y0 + len/2, leaf_T/2])
    difference(){
        rotate([90,0,0])
            cylinder(h=len, r=barrel_R, center=true);
        rotate([90,0,0])
            cylinder(h=len+0.3, r=hole_R, center=true);
    }

    // Small bridge to connect knuckle to leaf plate
    // (otherwise it just "touches" and is weak)
    bridge_w = 2.2; // along X
    if (side==0){
        // connect to left leaf
        translate([-bridge_w, y0, 0])
            cube([bridge_w, len, leaf_T], center=false);
    } else {
        // connect to right leaf
        translate([0, y0, 0])
            cube([bridge_w, len, leaf_T], center=false);
    }
}

// ---------- Assembly ----------
module butt_hinge_print_in_place(){
    difference(){
        union(){
            // Leaves
            leaf(0);
            leaf(1);

            // Pin (solid, no extra parts)
            built_in_pin();

            // 3 knuckles interleaved (2+1 like the photo)
            // i=0,2 -> left ; i=1 -> right
            for (i=[0:knuckle_n-1]){
                y0 = end_margin + i*(knuckle_L + gap_axial);
                if (i==1)
                    knuckle_segment(y0, knuckle_L, 1);
                else
                    knuckle_segment(y0, knuckle_L, 0);
            }
        }

        // (可选) 让两叶片在轴附近留一点点“避空”，降低粘连风险
        // 你如果发现很容易粘，可以把这段打开，并把 relief 调大一点。
        
        relief = 0.15;
        translate([-relief, -1, -1])
            cube([2*relief, leaf_L+2, leaf_T+2], center=false);
        
    }
}

// ---------- Render ----------
if (show_photo_pose){
    // 立起来展示（看起来像你图片里的摆放）
    rotate([90, 0, 0])
        butt_hinge_print_in_place();
} else {
    // 平放（更适合直接切片打印）
    butt_hinge_print_in_place();
}
