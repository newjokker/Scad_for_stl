include <BOSL2/std.scad>

$fn = 60;

L = 100;
W = 50;
a = 3;    // 外墙厚
b = 5;    // 唇边高度

// ======= 工具：生成均匀分布坐标（避开两端 margin） =======
function spread_positions(n, len, margin) =
    (n <= 1) ? [len/2] :
    [ for (i=[0:n-1]) margin + i*(len-2*margin)/(n-1) ];



// ======= 卡点：根据长宽自动决定哪条是长边 =======
module bumps_auto(L, W, H, a, b, n_long=4, n_short=2, r=undef, margin=undef)
{
    rr = (r == undef) ? (a/3) : r;
    mg = (margin == undef) ? max(2*a, 2*rr) : margin;

    zc = H + b/2;               // 卡点中心高度（靠近唇边）
    y_front = a/2;              // 前边靠内一点
    y_back  = W - a/2;          // 后边靠内一点
    x_left  = a/2;
    x_right = L - a/2;

    // 判断：L>=W 时，沿 X 分布的是“长边卡点”（前/后两条边）
    if (L >= W) {
        xs = spread_positions(n_long, L, mg);
        ys = spread_positions(n_short, W, mg);

        // 长边：前/后（每条 n_long 个）
        for (x = xs) {
            translate([x, y_front, zc]) sphere(r=rr);
            translate([x, y_back,  zc]) sphere(r=rr);
        }

        // 短边：左/右（每条 n_short 个）
        for (y = ys) {
            translate([x_left,  y, zc]) sphere(r=rr);
            translate([x_right, y, zc]) sphere(r=rr);
        }
    }
    // 否则 W>L：沿 Y 分布的是“长边卡点”（左/右两条边）
    else {
        ys = spread_positions(n_long, W, mg);
        xs = spread_positions(n_short, L, mg);

        // 长边：左/右（每条 n_long 个）
        for (y = ys) {
            translate([x_left,  y, zc]) sphere(r=rr);
            translate([x_right, y, zc]) sphere(r=rr);
        }

        // 短边：前/后（每条 n_short 个）
        for (x = xs) {
            translate([x, y_front, zc]) sphere(r=rr);
            translate([x, y_back,  zc]) sphere(r=rr);
        }
    }
}

module box_down(L, W, H, a, b){
    difference(){
        // 外壳
        cuboid(size=[L, W, H + b], anchor=[-1, -1, -1]);

        // 掏空（暴力掏穿，保证一定扣掉）
        translate([a, a, a])
            cuboid(size=[L-2*a, W-2*a, H*2], anchor=[-1, -1, -1]);

        // 唇边（形成台阶）
        translate([a/2, a/2, H])
            cuboid(size=[L-a, W-a, H*2], anchor=[-1, -1, -1]);
    }

    // 多卡点（长边 4、短边 2，自动随 L/W 调整）
    bumps_auto(L, W, H, a, b, n_long=4, n_short=3);
}

module box_up(L, W, H, a, b){
    difference(){
        // 外壳
        cuboid(size=[L, W, H*2], anchor=[-1, -1, -1]);

        // 内腔
        translate([a, a, a])
            cuboid(size=[L-2*a, W-2*a, H*2 - 2*a], anchor=[-1, -1, -1]);

        // 用下盒当“负模”扣掉（会自动生成对应的卡点凹位）
        box_down(L, W, H, a, b);
    }
}

// ====== 展示：上盖 + 下盒 ======
box_up(L, W, 10, a, b);

translate([0, 0, -50])
    box_down(L, W, 20, a, b);