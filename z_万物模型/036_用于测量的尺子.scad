include <BOSL2/std.scad>



include <BOSL2/std.scad>

// 第一个矩形：100 x 50 x 5
cuboid([100, 50, 5]) {
    // 在顶面中心添加尺寸文字
    position(TOP) 
        color("black")
        linear_extrude(height = 0.8)
            text("100x50x5", size = 6, halign = "center", valign = "center");
}

// 第二个矩形：50 x 30 x 4
translate([0, 100, 0]) {
    cuboid([50, 30, 4]) {
        position(TOP) 
            color("black")
            linear_extrude(height = 0.8)
                text("50x30x4", size = 4, halign = "center", valign = "center");
    }
}

// 第三个矩形：20 x 10 x 3
translate([0, 200, 0]) {
    cuboid([20, 10, 3]) {
        position(TOP) 
            color("black")
            linear_extrude(height = 0.8)
                text("20x10x3", size = 3, halign = "center", valign = "center");
    }
}