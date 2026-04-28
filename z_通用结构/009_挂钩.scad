include <BOSL2/std.scad>
include <BOSL2/hooks.scad>

$fn = 64;



scale([0.5, 0.5, 0.5])
    // 简单环形挂钩
    ring_hook(
        base_size = [50, 10],  // 底座宽度、厚度
        hole_z    = 25,        // 孔中心离底座的高度
        or        = 25,        // 外圆半径
        ir        = 15,        // 内孔半径
        rounding  = 2,         // 外边圆角
        fillet    = 2,         // 底部过渡圆角
        hole_rounding = 1      // 孔边圆角
    );

cuboid([50, 30, 2], anchor=[0, 0, 1]);