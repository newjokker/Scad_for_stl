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


// ======= 方案A：卡点形状改为“胶囊/圆角柱”（进出更对称，更好取出） =======
// r: 横向尺寸半径
// h: 沿 Z 的总高度（建议略大于 2*r）
module bump_capsule(r=1.2, h=2.2)
{
    // 防止 h < 2r 时几何异常：让中间圆柱高度不为负
    mid_h = max(0.01, h - 2*r);

    union() {
        // 中间圆柱
        translate([0,0,r]) cylinder(h=mid_h, r=r);

        // 底部半球
        translate([0,0,r]) sphere(r=r);

        // 顶部半球
        translate([0,0,h-r]) sphere(r=r);
    }
}


// ======= 卡点：根据长宽自动决定哪条是长边 =======
// bump_h: 卡点高度（沿Z）
// r:     卡点半径（横向尺寸）
module bumps_auto(L, W, H, a, b,
                  n_long=4, n_short=2,
                  r=undef, margin=undef,
                  bump_h=2.4)
{
    rr = (r == undef) ? (a/2.5) : r;
    mg = (margin == undef) ? max(2*a, 2*rr) : margin;

    zc = H + b/2;               // 卡点中心高度（靠近唇边）
    y_front = a/2;              // 前边靠内一点
    y_back  = W - a/2;          // 后边靠内一点
    x_left  = a/2;
    x_right = L - a/2;

    // 胶囊形是从 z=0 到 z=bump_h 的实体
    // 我们用 zc 作为“中心高度”，所以需要减去 bump_h/2
    z0 = zc - bump_h/2;

    // 判断：L>=W 时，沿 X 分布的是“长边卡点”（前/后两条边）
    if (L >= W) {
        xs = spread_positions(n_long, L, mg);
        ys = spread_positions(n_short, W, mg);

        // 长边：前/后（每条 n_long 个）
        for (x = xs) {
            translate([x, y_front, z0]) bump_capsule(r=rr, h=bump_h);
            translate([x, y_back,  z0]) bump_capsule(r=rr, h=bump_h);
        }

        // 短边：左/右（每条 n_short 个）
        for (y = ys) {
            translate([x_left,  y, z0]) bump_capsule(r=rr, h=bump_h);
            translate([x_right, y, z0]) bump_capsule(r=rr, h=bump_h);
        }
    }
    // 否则 W>L：沿 Y 分布的是“长边卡点”（左/右两条边）
    else {
        ys = spread_positions(n_long, W, mg);
        xs = spread_positions(n_short, L, mg);

        // 长边：左/右（每条 n_long 个）
        for (y = ys) {
            translate([x_left,  y, z0]) bump_capsule(r=rr, h=bump_h);
            translate([x_right, y, z0]) bump_capsule(r=rr, h=bump_h);
        }

        // 短边：前/后（每条 n_short 个）
        for (x = xs) {
            translate([x, y_front, z0]) bump_capsule(r=rr, h=bump_h);
            translate([x, y_back,  z0]) bump_capsule(r=rr, h=bump_h);
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

    // 多卡点（长边 4、短边 3，自动随 L/W 调整）
    // 方案A建议参数：
    // - bump_h: 2.0~2.6
    // - rr:     1.0~1.4 (看 a 和打印精度)
    bumps_auto(L, W, H, a, b,
               n_long=4, n_short=3,
               r=undef, margin=undef,
               bump_h=2.4);
}


module box_up(L, W, H, a, b){
    difference(){
        // 外壳
        union() {

            cuboid(size=[L, W, H*2], anchor=[-1, -1, -1]);
            
            // 加一个简单的把手，方便打开盒子
            r = 5;
            translate([L/2, r/4, H*2 - r/2])
                cylinder(h=r/2, r=r, center=false);
                
        }

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