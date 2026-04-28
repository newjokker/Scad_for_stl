include <BOSL2/std.scad>
include <BOSL2/polyhedra.scad>

$fn = 32;

head_r = 18;
tail_len = 46;
tail_r = 5;
fiber_len = 34;


// ===== 噬菌体模型 =====
color("#8FE9FF")
capsid_head();

color("#DDE7F0")
neck_and_collar();

color("#B8C4D2")
tail_sheath();

color("#5FE0FF")
tail_core();

color("#2C3442")
baseplate();

color("#E8A94A")
tail_fibers();


module capsid_head() {
    up(72)
    union() {
        // 二十面体头壳，是噬菌体最有辨识度的部分。
        regular_polyhedron("icosahedron", or=head_r, facedown=false);

        // 轻微内嵌的小面，增强“病毒衣壳”的层次感。
        color("#C9F7FF")
        zrot_copies(n=5)
        yrot(63)
        up(head_r * 0.54)
            cyl(h=1.0, r=3.4, anchor=CENTER, $fn=5);
    }
}


module neck_and_collar() {
    up(50)
    union() {
        cyl(h=8, r1=7.2, r2=5.4, anchor=BOTTOM);

        up(8)
        cyl(h=4, r=8.2, anchor=BOTTOM, chamfer=0.7);

        up(12)
        cyl(h=6, r1=5.5, r2=8.5, anchor=BOTTOM);
    }
}


module tail_sheath() {
    up(8)
    union() {
        // 主尾鞘
        cyl(h=tail_len, r=tail_r, anchor=BOTTOM, chamfer=0.5);

        // 环状节段
        for (z = [4:6:tail_len - 2]) {
            up(z)
            cyl(h=1.2, r=tail_r + 1.0, anchor=CENTER);
        }

        // 纵向加强筋
        zrot_copies(n=6)
        right(tail_r + 0.65)
        up(tail_len / 2)
        cuboid([1.0, 1.0, tail_len - 4], anchor=CENTER);
    }
}


module tail_core() {
    // 中央尾针，从尾鞘中伸出。
    down(2)
    cyl(h=58, r=1.4, anchor=BOTTOM);

    down(9)
    cyl(h=10, r1=2.2, r2=0.7, anchor=BOTTOM);
}


module baseplate() {
    union() {
        cyl(h=5, r=12, anchor=CENTER, $fn=6);

        zrot_copies(n=6)
        right(12)
        cuboid([9, 4, 4], chamfer=0.5, anchor=CENTER);

        down(4)
        cyl(h=5, r1=4.5, r2=2.2, anchor=CENTER);
    }
}


module tail_fibers() {
    // 六根折线尾纤维，模拟抓附宿主细菌表面的支脚。
    for (i = [0:5]) {
        zrot(i * 60)
        one_fiber();
    }
}


module one_fiber() {
    p0 = [10, 0, -1];
    p1 = [18, 0, -8];
    p2 = [fiber_len, 0, -18];
    p3 = [fiber_len + 10, 0, -16];

    stroke([p0, p1, p2, p3], width=1.2, endcaps="round");

    translate(p3)
    scale([1.6, 0.8, 0.55])
    sphere(r=2.1, $fn=24);
}
