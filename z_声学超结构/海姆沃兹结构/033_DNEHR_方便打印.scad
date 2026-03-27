include <BOSL2/std.scad>
include <BOSL2/structs.scad>

$fn = 50;

// =====================================================
// 原始完整单元
// =====================================================
module DNEHR_full(lu, l1, du, dd, W, Lu, H, l2){

    t = 0.8;
    Ld = 45 - Lu - 3*t;   
    L = 45;
    
    // 外壳
    difference(){
        cuboid([H, W, L], anchor=[0, 0, -1]);
        translate([0,0,t])
            cuboid([H - 2*t, W - 2*t, L - 2*t], anchor=[0, 0, -1]);
        translate([0, 0, L - 2*t])
            cuboid([du, du, t*3], anchor=[0, 0, -1]);
    }

    // 上颈
    translate([0,0,L - lu])
        difference(){
            cuboid([du + 2*t, du + 2*t, lu], anchor=[0, 0, -1]);
            translate([0,0,-t])
                cuboid([du, du, lu + 2*t], anchor=[0, 0, -1]);
        }

    // 中间隔板
    difference(){
        translate([0, 0, Ld + t])
            cuboid([H, W, t], anchor=[0, 0, -1]);
        translate([0, 0, Ld + t])
            cuboid([dd, dd, 2*t], anchor=[0, 0, -1]);
    }

    // 下颈
    translate([0,0,Ld - l2 + t])
        difference(){
            cuboid([dd + 2*t, dd + 2*t, l1 + l2 + t], anchor=[0, 0, -1]);
            translate([0,0,-t])
                cuboid([dd, dd, l1 + l2 + t + 2*t], anchor=[0, 0, -1]);
        }
}


// =====================================================
// 从隔板处分出来的上半部分
// cut_z = 隔板中面附近
// =====================================================
module DNEHR_top(lu, l1, du, dd, W, Lu, H, l2){
    t = 0.8;
    Ld = 45 - Lu - 3*t;

    cut_z = Ld + 1.5*t;   // 取在隔板中上方一点

    intersection() {
        DNEHR_full(lu, l1, du, dd, W, Lu, H, l2);
        translate([0,0,cut_z])
            cuboid([200, 200, 200], anchor=[0,0,-1]);
    }
}


// =====================================================
// 从隔板处分出来的下半部分
// =====================================================
module DNEHR_bottom(lu, l1, du, dd, W, Lu, H, l2){
    t = 0.8;
    Ld = 45 - Lu - 3*t;

    cut_z = Ld + 1.5*t;   // 和上半保持同一切面

    intersection() {
        DNEHR_full(lu, l1, du, dd, W, Lu, H, l2);
        translate([0,0,-200])
            cuboid([200, 200, cut_z + 200], anchor=[0,0,-1]);
    }
}


// =====================================================
// 参数
// =====================================================
params = [
    [9.9, 4.5,  6.8,  2.2, 24.5, 37.3, 10.8,  2.8],
    [2.1, 2.2,  6.7,  3.6, 10.7, 20.2, 10.8, 17.0],
    [2.7, 0.0,  6.6,  5.2, 10.6, 24.7, 10.8,  6.8],

    [3.6, 0.2,  8.5,  7.1, 16.1, 17.9, 14.8, 20.0],
    [2.6, 7.7, 10.8,  5.0, 14.8, 17.3, 14.8, 23.0],
    [1.0, 0.1, 10.5, 10.8, 14.9, 41.8, 14.8,  0.0],

    [5.6, 3.2,  8.7,  7.0, 12.7, 10.3, 20.0, 28.1],
    [1.0,12.9, 11.0,  3.2, 15.0, 32.6, 20.0,  8.0],
    [1.0, 5.7, 10.0,  8.6, 18.1, 27.3, 20.0, 13.5],
];

cols = 3;
rows = 3;

function row_total_width(r) =
    sum([for (c = [0:cols-1]) params[r*cols + c][4]]);

function prev_rows_height(r) =
    sum([for (rr = [0:r-1]) params[rr*cols][6]]);

function prev_cols_width(r, c) =
    sum([for (cc = [0:c-1]) params[r*cols + cc][4]]);

total_w = row_total_width(0);
total_h = sum([for (r = [0:rows-1]) params[r*cols][6]]);
gap_between_groups = 35;


// 左边：上半
for (r = [0:rows-1]) {
    for (c = [0:cols-1]) {
        i = r * cols + c;
        p = params[i];

        cell_w = p[4];
        cell_h = p[6];

        x_center = -total_h/2 + prev_rows_height(r) + cell_h/2;
        y_center = -total_w/2 + prev_cols_width(r, c) + cell_w/2;

        translate([x_center, y_center - total_w/2 - gap_between_groups/2, 0])
            DNEHR_top(
                lu = p[0], l1 = p[1], du = p[2], dd = p[3],
                W = p[4], Lu = p[5], H = p[6], l2 = p[7]
            );
    }
}


// 右边：下半
for (r = [0:rows-1]) {
    for (c = [0:cols-1]) {
        i = r * cols + c;
        p = params[i];

        cell_w = p[4];
        cell_h = p[6];

        x_center = -total_h/2 + prev_rows_height(r) + cell_h/2;
        y_center = -total_w/2 + prev_cols_width(r, c) + cell_w/2;

        translate([x_center, y_center + total_w/2 + gap_between_groups/2, 0])
            DNEHR_bottom(
                lu = p[0], l1 = p[1], du = p[2], dd = p[3],
                W = p[4], Lu = p[5], H = p[6], l2 = p[7]
            );
    }
}