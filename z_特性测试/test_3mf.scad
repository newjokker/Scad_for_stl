// =============================================
// 3MF Export Feature Test - OpenSCAD
// 测试项: 多对象 / 颜色(RGB, name, HEX) / 文字 / 默认色
// 渲染(F6)后 Export as 3MF, 勾选 "Use colors from model"
// =============================================

$fn = 50;

// --- ① 红色立方体（RGB数组方式指定颜色）---
color([1, 0, 0])          // RGB red
  cube([10, 10, 5]);

// --- ② 蓝色圆柱（颜色名称方式）---
color("blue")
  translate([12, 0, 0])
    cylinder(h = 8, r = 4);

// --- ③ 绿色圆环（HEX 颜色）---
color("#00CC00")
  translate([24, 0, 0])
    rotate_extrude()
      translate([5, 0, 0])
        circle(r = 2);

// --- ④ 金色浮雕文字 ---
color([1, 0.84, 0])       // Gold RGB
  translate([0, 12, 0])
    linear_extrude(1.5)
      text("3MF", size = 6, halign = "left", valign = "bottom");

// --- ⑤ 无颜色默认件（测试 slicer 是否给白色/灰色）---
translate([0, -12, 0])
  difference() {
    cube([10, 10, 3]);
    translate([2, 2, -0.5])
      cylinder(h = 4, r = 1.5);
  }