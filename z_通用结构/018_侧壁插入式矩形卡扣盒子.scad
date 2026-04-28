include <BOSL2/std.scad>

$fn = 48;

box_size = [72, 46, 22];     // 下盒外尺寸
lid_size = [72, 46, 10];     // 上盖外尺寸
wall = 2.4;                  // 壁厚
gap = 0.25;                  // 配合间隙

latch_w = 12;                // 卡扣宽度
latch_t = 1.6;               // 弹片厚度
latch_l = 18;                // 插入长度
latch_hook = 2.4;            // 倒钩高度
slot_h = 5.6;                // 插槽高度

spacing = 92;


// ===== 左侧：上下分开展示；右侧：扣合状态 =====
xdistribute(spacing=spacing) {
    exploded_box();
    assembled_box();
}


module exploded_box() {
    color("gainsboro")
    bottom_box();

    color("orange")
    up(box_size.z + 18)
    lid_with_side_latches();
}


module assembled_box() {
    color("gainsboro")
    bottom_box();

    color("orange")
    up(box_size.z - 2)
    lid_with_side_latches();
}


module bottom_box() {
    difference() {
        cuboid(box_size, rounding=1.2, edges="Z", anchor=BOTTOM);

        // 挖空盒子内部
        up(wall)
        cuboid([
            box_size.x - 2 * wall,
            box_size.y - 2 * wall,
            box_size.z
        ], anchor=BOTTOM);

        // 左右侧壁插槽
        xflip_copy()
        right(box_size.x / 2 - wall / 2)
        up(box_size.z - 9)
        side_socket_cut();
    }

    // 插槽后方的止退台阶，给弹片倒钩扣住
    xflip_copy()
    right(box_size.x / 2 - wall - 0.35)
    up(box_size.z - 11)
    side_catch_block();
}


module lid_with_side_latches() {
    union() {
        lid_shell();

        // 左右两侧插入式弹片
        xflip_copy()
        right(lid_size.x / 2 - wall - latch_t / 2)
        up(1.2)
        side_latch();
    }
}


module lid_shell() {
    difference() {
        cuboid(lid_size, rounding=1.2, edges="Z", anchor=BOTTOM);

        down(0.01)
        cuboid([
            lid_size.x - 2 * wall,
            lid_size.y - 2 * wall,
            lid_size.z - wall + 0.02
        ], anchor=BOTTOM);
    }

    // 下插裙边，用来套入下盒内侧定位
    down(5)
    difference() {
        cuboid([
            lid_size.x - 2 * wall - 2 * gap,
            lid_size.y - 2 * wall - 2 * gap,
            7
        ], anchor=BOTTOM);

        down(0.01)
        cuboid([
            lid_size.x - 4 * wall - 2 * gap,
            lid_size.y - 4 * wall - 2 * gap,
            7.02
        ], anchor=BOTTOM);
    }
}


// 侧壁插槽切除体。沿 X 方向穿透侧壁，Y 方向为卡扣宽度。
module side_socket_cut() {
    cuboid([
        wall + 0.8,
        latch_w + 2 * gap,
        slot_h
    ], anchor=CENTER);
}


// 止退台阶，位于插槽内侧；弹片倒钩越过后扣住这里。
module side_catch_block() {
    cuboid([
        1.4,
        latch_w + 3,
        latch_hook
    ], anchor=CENTER);
}


// 侧壁插入式矩形弹片。弹片在 X 方向插入下盒侧壁，末端带楔形倒钩。
module side_latch() {
    union() {
        // 悬臂弹片
        translate([-latch_l, -latch_w / 2, 0])
        cube([latch_l, latch_w, latch_t]);

        // 根部加厚，连接在上盖侧壁上
        translate([-2, -latch_w / 2, -1.4])
        cube([4, latch_w, latch_t + 2.8]);

        // 末端导入斜坡倒钩
        translate([-latch_l, 0, 0])
        latch_wedge(w=latch_w, hook_l=5, hook_h=latch_hook, t=latch_t);
    }
}


module latch_wedge(w=12, hook_l=5, hook_h=2.4, t=1.6) {
    y0 = -w / 2;
    y1 = w / 2;
    x0 = 0;
    x1 = hook_l;
    z0 = t;
    z1 = t + hook_h;

    polyhedron(
        points=[
            [x0, y0, z0], [x1, y0, z0], [x1, y0, z1],
            [x0, y1, z0], [x1, y1, z0], [x1, y1, z1]
        ],
        faces=[
            [0, 1, 2],
            [3, 5, 4],
            [0, 3, 4, 1],
            [1, 4, 5, 2],
            [0, 2, 5, 3]
        ]
    );
}
