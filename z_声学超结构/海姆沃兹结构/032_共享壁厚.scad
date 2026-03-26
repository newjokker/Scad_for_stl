include <BOSL2/std.scad>
include <BOSL2/structs.scad>

$fn = 50;

// =========================
// 参数
// =========================
t = 0.8;
L = 45;
cols = 3;

// lu, l1, du, dd, W, Lu, H, l2
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

// =========================
// 工具函数
// =========================

// 每一行高度（X方向尺寸 H）
function row_h(r) = params[r*cols][6];

// 某一行原始总宽（不考虑共享壁时）
function row_total_w_raw(r) =
    sum([for (c = [0:cols-1]) params[r*cols + c][4]]);

// 共享壁后某一行总宽
function row_total_w_shared(r) =
    row_total_w_raw(r) - (cols - 1) * t;

// 总高度（X方向）
function total_h_shared() =
    sum([for (r = [0:2]) row_h(r)]) - (3 - 1) * t;

// 总宽度（Y方向）
// 这里 3 行的总宽理论上一样；稳妥起见取最大值
function total_w_shared() =
    max([
        row_total_w_shared(0),
        row_total_w_shared(1),
        row_total_w_shared(2)
    ]);

// 第 r 行起始 X（左边界）
function row_x_start(r) =
    sum([for (rr = [0:r-1]) row_h(rr)]) - r * t;

// 第 r 行第 c 列起始 Y（下边界）
function cell_y_start(r, c) =
    sum([for (cc = [0:c-1]) params[r*cols + cc][4]]) - c * t;

// 单元中心 X
function cell_cx(r) =
    row_x_start(r) + row_h(r) / 2;

// 单元中心 Y
function cell_cy(r, c) =
    cell_y_start(r, c) + params[r*cols + c][4] / 2;


// =========================
// 单元：只生成“外壳实体”
// =========================
module dnehr_outer(lu, l1, du, dd, W, Lu, H, l2) {
    cuboid([H, W, L], anchor=[0, 0, -1]);
}

// =========================
// 单元：内部需要被挖掉的空间
// =========================
module dnehr_cutouts(lu, l1, du, dd, W, Lu, H, l2) {
    Ld = L - Lu - 3*t;

    // 主腔体
    translate([0,0,t])
        cuboid([H - 2*t, W - 2*t, L - 2*t], anchor=[0, 0, -1]);

    // 顶部开口
    translate([0, 0, L - 2*t])
        cuboid([du, du, t*3], anchor=[0, 0, -1]);
}

// =========================
// 单元：内部结构（加回去）
// =========================
module dnehr_inner_features(lu, l1, du, dd, W, Lu, H, l2) {
    Ld = L - Lu - 3*t;

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

// =========================
// 共享壁一体化 3×3 阵列
// =========================
module DNEHR_shared_array() {

    totalX = total_h_shared();
    totalY = total_w_shared();

    // 整体居中到原点
    translate([-totalX/2, -totalY/2, 0]) {

        union() {
            // ---------------------------------
            // 1) 先做整体外壳（通过各单元外形重叠 t 实现共享壁）
            // ---------------------------------
            difference() {
                union() {
                    for (r = [0:2]) {
                        for (c = [0:2]) {
                            i = r * cols + c;
                            p = params[i];

                            translate([cell_cx(r), cell_cy(r, c), 0])
                                dnehr_outer(
                                    lu = p[0],
                                    l1 = p[1],
                                    du = p[2],
                                    dd = p[3],
                                    W  = p[4],
                                    Lu = p[5],
                                    H  = p[6],
                                    l2 = p[7]
                                );
                        }
                    }
                }

                // 挖掉每个单元自己的内部空腔和顶开口
                for (r = [0:2]) {
                    for (c = [0:2]) {
                        i = r * cols + c;
                        p = params[i];

                        translate([cell_cx(r), cell_cy(r, c), 0])
                            dnehr_cutouts(
                                lu = p[0],
                                l1 = p[1],
                                du = p[2],
                                dd = p[3],
                                W  = p[4],
                                Lu = p[5],
                                H  = p[6],
                                l2 = p[7]
                            );
                    }
                }
            }

            // ---------------------------------
            // 2) 再加回每个单元自己的内部结构
            // ---------------------------------
            for (r = [0:2]) {
                for (c = [0:2]) {
                    i = r * cols + c;
                    p = params[i];

                    translate([cell_cx(r), cell_cy(r, c), 0])
                        dnehr_inner_features(
                            lu = p[0],
                            l1 = p[1],
                            du = p[2],
                            dd = p[3],
                            W  = p[4],
                            Lu = p[5],
                            H  = p[6],
                            l2 = p[7]
                        );
                }
            }
        }
    }
}

// =========================
// 渲染
// =========================
DNEHR_shared_array();